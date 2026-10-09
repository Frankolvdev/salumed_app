import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:app/models/app_preferences.dart';
import 'package:app/services/web_service.dart';

/// Configure the matching subscription IDs in Google Play Console / App Store Connect.
/// Trial eligibility and duration are defined in the stores, never locally.
class StorePurchaseHelper {
  StorePurchaseHelper(this.context);
  final BuildContext context;
  static const googleProductId = String.fromEnvironment('GOOGLE_PLAY_SUBSCRIPTION_PRODUCT_ID', defaultValue: '');
  static const appleProductId = String.fromEnvironment('APPLE_SUBSCRIPTION_PRODUCT_ID', defaultValue: '');
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _processing = false;

  Future<void> purchase({required VoidCallback onPremiumActivated}) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) throw StateError('Las compras de tienda solo están disponibles en Android o iOS');
    final productId = Platform.isAndroid ? googleProductId : appleProductId;
    if (productId.isEmpty) throw StateError('Configura el identificador de suscripción de la tienda');
    final store = InAppPurchase.instance;
    if (!await store.isAvailable()) throw StateError('La tienda no está disponible');
    final response = await store.queryProductDetails({productId});
    if (response.error != null || response.productDetails.isEmpty) throw StateError('No se encontró la suscripción en la tienda');
    await _subscription?.cancel();
    _subscription = store.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        if (purchase.productID != productId) continue;
        if ((purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) && !_processing) {
          _processing = true;
          try {
            final user = await AppPreferences().getUser();
            if (user.token == null || user.id == null) throw StateError('Inicia sesión para verificar la compra');
            final verified = await WebService(context).verifyStorePurchase(
              user.token!, Platform.isAndroid ? 'google_play' : 'apple', productId,
              purchase.verificationData.serverVerificationData,
            );
            if (verified['active'] == true) {
              onPremiumActivated();
              if (purchase.pendingCompletePurchase) await store.completePurchase(purchase);
            } else {
              _showError('La tienda todavía no confirmó una suscripción activa.');
            }
          } catch (error) { _showError('No se pudo verificar la compra: $error'); }
          finally { _processing = false; }
        } else if (purchase.status == PurchaseStatus.error) {
          _showError(purchase.error?.message ?? 'Error de compra');
        }
      }
    });
    final param = PurchaseParam(productDetails: response.productDetails.first);
    await store.buyNonConsumable(purchaseParam: param);
  }

  void _showError(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> dispose() async { await _subscription?.cancel(); }
}
