# SaluMeD — preparación para Google Play (pruebas internas)

Este documento no garantiza que la aplicación esté lista para producción.

1. Confirmar `applicationId` `com.salumed.app` en `android/app/build.gradle.kts` y que coincide con Play Console.
2. Confirmar la clave de firma de subida correcta y `android/key.properties` (no subirlo a Git).
3. Configurar `GOOGLE_MAPS_API_KEY` en `android/local.properties`.
4. Ejecutar `flutter pub get` y `flutter analyze`. Resolver errores antes de subir.
5. Ejecutar `flutter build appbundle --release --dart-define=GOOGLE_PLAY_SUBSCRIPTION_PRODUCT_ID=salumed_premium_monthly` (sustituir ID cuando se cree).
6. El AAB suele quedar en `build/app/outputs/bundle/release/app-release.aab`.
7. Subir a **Pruebas internas**; NO publicar en producción.
8. Crear y activar la suscripción y su plan básico en Play Console, configurar cuenta de servicio del backend y probar compras con usuarios de prueba.

**Importante:** El backend verifica compras con Google; sin credenciales oficiales y producto real, la compra no puede otorgar Premium. No agregar secretos a Flutter ni al repositorio.

Apple permanece pendiente de cuenta de desarrollador, productos y validación oficial. PayPal live no se modifica en este paquete.
