import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/mercadopago_helper.dart';
import 'package:app/pages/hero.dart';
import 'package:app/pages/open.dart';
import 'package:app/pages/splash.dart';
import 'package:app/providers/app.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import 'configure_nonweb.dart'
    if (dart.library.html) 'configure_web.dart';

//import 'dart:html' as html;

Map<String, String>? resultadoPagoPendiente;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    OneSignal.initialize(oneSignalAppIdAndroid);
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Conserva el retorno de Mercado Pago tanto con la app cerrada como abierta.
    // AppLinks.uriLinkStream entrega el enlace inicial y los enlaces posteriores.
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen(
      (Uri uri) {
        _procesarDeepLink(uri.toString());
      },
      onError: (_) {
        // Mantiene el comportamiento anterior: ignorar errores de deep link.
      },
    );
  } else {
    // Web: si quieres, puedes usar HTML para leer query params.
    _procesarWebQueryParams();
  }

  configureApp();

  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  runApp(MyApp());
}

void _procesarWebQueryParams() {
  /* final uri = Uri.parse(html.window.location.href);
  if (uri.queryParameters.isNotEmpty) {
    final params = uri.queryParameters;
    // Tu lógica adaptada para Web
    if (params.containsKey("status") && params.containsKey("preapproval_id")) {
      _procesarDeepLink(uri.toString());
    }
  }*/
}

void _procesarDeepLink(String link) {
  if (!link.startsWith('myapp://subscription')) return;

  final uri = Uri.parse(link);
  final status = uri.queryParameters['status'];
  final preapprovalId = uri.queryParameters['preapproval_id'];

  print("Deep link recibido: $link");

  // También chequea que preapproval_id exista.
  if (preapprovalId == null) {
    print("Deep link ignorado: preapproval_id inválido");
    return;
  }

  resultadoPagoPendiente = {
    "titulo": "Exitoso",
    "mensaje": "Pago completado correctamente. ¡Gracias!",
  };

  print(
    "Deep link válido procesado: status=$status, "
    "preapproval_id=$preapprovalId",
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AppProvider appChangeProvider = AppProvider();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return ChangeNotifierProvider.value(
      value: appChangeProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SaluMeD',

        // Esta línea bloquea el cambio de tamaño de texto del sistema.
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: const TextScaler.linear(0.9),
              boldText: false,
              highContrast: false,
            ),
            child: child!,
          );
        },

        onGenerateRoute: (settings) {
          if (kIsWeb) {
            final uriData = Uri.parse(settings.name ?? "");
            final params = uriData.queryParameters;
            if (params.isNotEmpty) {
              queryParams = params;
              if (queryParams.containsKey("action") &&
                  queryParams.containsKey("token")) {
                if ((queryParams["action"]?.isNotEmpty ?? false) &&
                    (queryParams["token"]?.isNotEmpty ?? false)) {
                  if (queryParams["action"] == "guest_prescription") {
                    tokenPrescription = queryParams["token"];
                    if (queryParams.containsKey("email")) {
                      if (queryParams["email"]?.isNotEmpty ?? false) {
                        emailPrescription = queryParams["email"];
                      }
                    }
                  }
                }
              }
            }
          }
          return null;
        },

        theme: ThemeData(
          fontFamily: 'Roboto',
          useMaterial3: false,
          brightness: Brightness.light,
          primaryColor: CustomColors.primary,
          primarySwatch: CustomColors.primary,
          textTheme: const TextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('fr'),
          Locale('zh'),
        ],

        home: HeroPage(),
      ),
    );
  }
}
