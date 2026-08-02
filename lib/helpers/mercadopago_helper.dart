// mercadopago_helper.dart → NUEVO FLUJO: Usa init_point y url_launcher (diciembre 2025)
import 'dart:async';
import 'package:app/helpers/paypal_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Agrega esta dependencia en pubspec.yaml
import 'package:app/components/custom_dialog.dart';
import 'package:app/helpers/helpers.dart' hide launchUrl;
import 'package:app/models/app_preferences.dart';
import 'package:app/models/user.dart';
import 'package:app/services/web_service.dart';

import '../components/custom_dialog_payment.dart';

class MercadoPagoHelper {
  final BuildContext context;

  MercadoPagoHelper(this.context);
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

      final userId = user.id!;
      final userEmail = user.email!;
      final token = user.token!;

      dynamic sub =
          await WebService(context).getUserSubscription(userId, token);

      print("ESTADO SUSCRIPCIÓN: $sub");

      Navigator.pop(loadingContext);

      if (sub["active"] == true) {
        callback();
      } else {
        showSelectPayment(callback, callbackLogin);
      }
    } catch (e) {
      Navigator.pop(loadingContext);
      showErrorsDialog(context, e);
    } finally {
      // ✅ Libera el bloqueo SIEMPRE
      _isCheckingSubscription = false;
    }
  });
}

  Future<void> openMercadoPagoPay(
      {required Function() callback, callbackLogin}) async {
    simpleLoading(context, (BuildContext loadingContext) async {
      try {
        UserModel user = await AppPreferences().getUser();
        if (user.id == null) {
          Navigator.pop(loadingContext);
          _showNotLoggedDialog(callbackLogin);
          return;
        }

        final userId = user.id!;
        final userEmail = user.email!;
        final token = user.token!;
        // Solicita init_point al backend
        dynamic response = await WebService(context).createSubscription(
          userId,
          userEmail,
          token,
        );
        // Cierra loading antes de iniciar flujo

        if (response["success"]) {
          String initPoint = response["init_point"];
          print("INIT_POINT RECIBIDO: $initPoint");

          // Abre la URL en navegador externo
          await _launchMercadoPago(initPoint);
          Navigator.pop(loadingContext);
          // Después de redirigir, verifica estado (polling simple, o usa deep links)
          simpleLoading(context, (loading2) async {
            // Espera un poco para que el usuario complete
            await Future.delayed(
                Duration(seconds: 5)); // Ajusta o usa un loop de polling
            dynamic updatedSub =
                await WebService(context).getUserSubscription(userId, token);
            Navigator.pop(loading2);

            print("resultado: ");
            print(updatedSub);
            if (updatedSub["active"]) {
              showDialog(
                context: context,
                builder: (_) => CustomDialog(
                  "¡Suscripción activada!",
                  "Cobro mensual: \$199 MXN.",
                  "Ok",
                  () => callback(),
                  useBtnCancel: false,
                ),
              );
            } else {
              _showPaymentError(callback);
            }
          });
        } else {
          _showPaymentError(callback);
        }
      } catch (e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e);
      }
    });
  }

  showSelectPayment(callback,callbackLogin ) {
    showDialog(
      context: context,
      builder: (_) => CustomDialogPayment(
        "Selecciona un método de pago",
        "Por favor, elige tu método de pago preferido.",
        "Cerrar",
        (paymentMethod) {
          print("Método de pago seleccionado: $paymentMethod");

if("mercadopago"==paymentMethod){
            openMercadoPagoPay(callback: callback,callbackLogin: callbackLogin);

}else{
PaypalHelper(context).checkSubscription(callback:   callback,callbackLogin: callbackLogin);
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

  Future<void> _launchMercadoPago(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir la URL: $url');
    }
  }

  void _showPaymentError(callback) {
    /*  showDialog(
      context: context,
      builder: (_) => CustomDialog("Error", "No se pudo procesar el pago.", "Ok", () {}),
    );*/
//this.checkSubscription(callback:callback);
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
