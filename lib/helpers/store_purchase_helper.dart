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
  static const googleProductId = String.fromEnvironment('GOOGLE_PLAY_SUBSCRIPTION_PRODUCT_ID', defaultValue: 'salumed_premium_monthly');
  static const appleProductId = String.fromEnvironment('APPLE_SUBSCRIPTION_PRODUCT_ID', defaultValue: '');
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _processing = false;

  // Keep one listener alive while the purchase/restore flow is running.
  // Both operations use the same server-side verification and never grant
  // Premium merely because the store reports a successful transaction.
  Future<void> _listenForPurchases(String productId, VoidCallback onPremiumActivated) async {
    final store = InAppPurchase.instance;
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
            } else {
              _showError('La tienda todavía no confirmó una suscripción activa.');
            }
          } catch (error) {
            _showError('No se pudo verificar la compra: $error');
          } finally {
            if (purchase.pendingCompletePurchase) {
              try { await store.completePurchase(purchase); }
              catch (error) { _showError('No se pudo finalizar la transacción: $error'); }
            }
            _processing = false;
          }
        } else if (purchase.status == PurchaseStatus.error) {
          _showError(purchase.error?.message ?? 'Error de compra');
        }
      }
    });
  }

  String _productId() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      throw StateError('Las compras de tienda solo están disponibles en Android o iOS');
    }
    final productId = Platform.isAndroid ? googleProductId : appleProductId;
    if (productId.isEmpty) throw StateError('Configura el identificador de suscripción de la tienda');
    return productId;
  }

  Future<void> purchase({required VoidCallback onPremiumActivated}) async {
    final productId = _productId();
    final store = InAppPurchase.instance;
    if (!await store.isAvailable()) throw StateError('La tienda no está disponible');
    final response = await store.queryProductDetails({productId});
    if (response.error != null || response.productDetails.isEmpty) {
      throw StateError('No se encontró la suscripción en la tienda');
    }
    await _listenForPurchases(productId, onPremiumActivated);
    await store.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: response.productDetails.first));
  }

  /// Restores eligible purchases without opening a new checkout.
  /// Restoration always verifies ownership and status on the backend.
  Future<void> restorePurchases({required VoidCallback onPremiumActivated}) async {
    final productId = _productId();
    final store = InAppPurchase.instance;
    if (!await store.isAvailable()) throw StateError('La tienda no está disponible');
    await _listenForPurchases(productId, onPremiumActivated);
    await store.restorePurchases();
  }

  void _showError(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> dispose() async { await _subscription?.cancel(); }
}
