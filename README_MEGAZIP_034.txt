MegaZIP 034

Deshabilita temporalmente la integración nativa de Facebook en Android.

Se eliminan únicamente del AndroidManifest:
- com.facebook.sdk.ApplicationId
- FacebookActivity
- CustomTabActivity

No se elimina el paquete Flutter ni el código Dart.
Más adelante podrás reactivar Facebook restaurando estas entradas y configurando
facebook_app_id y fb_login_protocol_scheme.
