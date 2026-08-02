// paypal_helper.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/components/custom_dialog.dart';
import 'package:app/helpers/helpers.dart' hide launchUrl;
import 'package:app/models/app_preferences.dart';
import 'package:app/models/user.dart';
import 'package:app/services/web_service.dart';

class PaypalHelper {
  final BuildContext context;

  PaypalHelper(this.context);

  Future<void> checkSubscription({
    required Function() callback,
    Function? callbackLogin,
  }) async {
    simpleLoading(context, (loadingContext) async {
      try {
        UserModel user = await AppPreferences().getUser();

        if (user.id == null) {
          Navigator.pop(loadingContext);
          _showNotLoggedDialog(callbackLogin);
          return;
        }

        final userId = user.id!;
        final email = user.email!;
        final token = user.token!;

        // 1️⃣ Revisar status (MISMO endpoint)
        dynamic sub =
            await WebService(context).getUserSubscription(userId, token);

        if (sub["active"] == true) {
          Navigator.pop(loadingContext);
          callback();
          return;
        }

        // 2️⃣ Crear suscripción PayPal
        dynamic response =
            await WebService(context).createPaypalSubscription(
          userId,
          email,
          token,
        );

        Navigator.pop(loadingContext);

        if (response["success"] == true) {
          String approvalUrl = response["init_point"];

          await _launchPaypal(approvalUrl);

          // 3️⃣ Polling simple (igual que MP)
          simpleLoading(context, (loading2) async {
            await Future.delayed(const Duration(seconds: 5));

            dynamic updated =
                await WebService(context).getUserSubscription(userId, token);

            Navigator.pop(loading2);

            if (updated["active"] == true) {
              showDialog(
                context: context,
                builder: (_) => CustomDialog(
                  "¡Suscripción activada!",
                  "Tu suscripción PayPal está activa.",
                  "Ok",
                  () => callback(),
                  useBtnCancel: false,
                ),
              );
            }else if(updated["status"] == "APPROVAL_PENDING"){
   showDialog(
                context: context,
                builder: (_) => CustomDialog(
                  "¡Suscripción!",
                  "Tu suscripción PayPal se esta validando, recarga la app.",
                  "Ok",
                  () => callback(),
                  useBtnCancel: false,
                ),
              );
            
            } else {
              _showPaymentError();
            }
          });
        } else {
          _showPaymentError();
        }
      } catch (e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e);
      }
    });
  }

  Future<void> _launchPaypal(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("No se pudo abrir PayPal");
    }
  }

  void _showPaymentError() {

    /*
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        "Pago no completado",
        "No se pudo activar la suscripción.",
        "Ok",
        () {},
      ),
    );

    */

      showDialog(
      context: context,
      builder: (_) => CustomDialog(
        "Pago no completado",
        "No se pudo activar la suscripción.",
        "Ok",
        () {},
      ),
    );
  }

  void _showNotLoggedDialog(Function? callbackLogin) {
    callbackLogin?.call();
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        "Inicia sesión",
        "Necesitas estar logueado.",
        "Ok",
        () {},
      ),
    );
  }
}
