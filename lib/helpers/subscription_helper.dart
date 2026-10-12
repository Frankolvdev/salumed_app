import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart' show Platform;
import 'package:app/helpers/store_purchase_helper.dart';
// Unified subscription access for Google Play, Apple and PayPal.
import 'dart:async';
import 'package:app/helpers/paypal_helper.dart';
import 'package:flutter/material.dart';
import 'package:app/components/custom_dialog.dart';
import 'package:app/helpers/helpers.dart' hide launchUrl;
import 'package:app/models/app_preferences.dart';
import 'package:app/models/user.dart';
import 'package:app/services/web_service.dart';

import '../components/custom_dialog_payment.dart';

class SubscriptionHelper {
  // MEGAZIP SPECIAL FREE ACCESS:
  // Esta compilacion omite el cobro de suscripcion, pero conserva el requisito
  // de que exista un usuario autenticado. La version normal de Google Play no
  // se modifica.
  static const bool _specialFreeAccessBuild = false;

  final BuildContext context;

  SubscriptionHelper(this.context);
  static bool _isCheckingSubscription = false; // 👈 CLAVE


Future<void> checkSubscription({
  required Function() callback,
  callbackLogin,
}) async {
  // 🚫 Si ya está ejecutándose, no hace nada
  if (_isCheckingSubscription) return;

  _isCheckingSubscription = true;

  simpleLoading(context, (BuildContext loadingContext) async {
    try {
      UserModel user = await AppPreferences().getUser();

      if (user.id == null) {
        Navigator.pop(loadingContext);
        _showNotLoggedDialog(callbackLogin);
        return;
      }

      // Compilacion especial: si hay un usuario autenticado, permite el acceso
      // premium sin consultar ni abrir ningun flujo de pago.
      if (_specialFreeAccessBuild) {
        Navigator.pop(loadingContext);
        callback();
        return;
      }

      final userId = user.id!;
      final token = user.token!;

      dynamic sub =
          await WebService(context).getUserSubscription(userId, token);

      print("ESTADO SUSCRIPCIÓN: $sub");

      if (!loadingContext.mounted || !context.mounted) return;
      Navigator.pop(loadingContext);

      if (sub["active"] == true) {
        callback();
      } else {
        showSelectPayment(callback, callbackLogin);
      }
    } catch (e) {
      if (loadingContext.mounted) Navigator.pop(loadingContext);
      if (context.mounted) showErrorsDialog(context, e);
    } finally {
      // ✅ Libera el bloqueo SIEMPRE
      _isCheckingSubscription = false;
    }
  });
}

  showSelectPayment(callback,callbackLogin ) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      StorePurchaseHelper(context).purchase(onPremiumActivated: callback).catchError((error) {
        showErrorsDialog(context, [error.toString()]);
      });
      return;
    }
    showDialog(
      context: context,
      builder: (_) => CustomDialogPayment(
        "Selecciona un método de pago",
        "Por favor, elige tu método de pago preferido.",
        "Cerrar",
        (paymentMethod) {
          print("Método de pago seleccionado: $paymentMethod");

          if (paymentMethod == "paypal") {
            PaypalHelper(context).checkSubscription(callback: callback, callbackLogin: callbackLogin);
          }
          //Navigator.pop(context);
          //        Navigator.pop(context);
        },
        useBtnCancel: false,
      ),
    );
  }

  Future<bool> isSubscriptionActive() async {
    try {
      UserModel user = await AppPreferences().getUser();

      if (user.id == null || user.token == null) {
        return false;
      }

      if (_specialFreeAccessBuild) {
        return true;
      }

      final userId = user.id!;
      final token = user.token!;

      dynamic sub =
          await WebService(context).getUserSubscription(userId, token);

      print("ESTADO SUSCRIPCIÓN (solo check): $sub");

      return sub["active"] == true;
    } catch (e) {
      print('❌ Error verificando suscripción: $e');
      return false;
    }
  }

  void _showNotLoggedDialog(dynamic callbackLogin) {
    if (callbackLogin != null && callbackLogin is Function) {
      callbackLogin();
    }
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
          "Inicia sesión", "Necesitas estar logueado.", "Ok", () {}),
    );
  }
}
