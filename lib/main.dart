import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/mercadopago_helper.dart';
import 'package:app/pages/hero.dart';
import 'package:app/pages/open.dart';
import 'package:app/pages/splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'providers/app.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';
import 'package:uni_links/uni_links.dart';
//import 'dart:html' as html;

Map<String, String>? resultadoPagoPendiente;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 if(!kIsWeb){
OneSignal.initialize(oneSignalAppIdAndroid);
OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

 } 


//PaymentMiddleware.initDeepLinkListener(); 
// ← Estas líneas nuevas (reemplazan o complementan tu initDeepLinkListener)

// 1. Detectar link inicial (app cerrada → abre con link)
  try {
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _procesarDeepLink(initialLink);
    }
  } catch (e) {
    // Ignorar
  }

  if (!kIsWeb) {
  // 2. Escuchar links mientras la app está viva (¡esto es lo que te faltaba!)
  uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      _procesarDeepLink(uri.toString());
    }
  });


      uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _procesarDeepLink(uri.toString());
      }
    });
  } else {
    // Web: si quieres, puedes usar HTML para leer query params
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

  Uri uri = Uri.parse(link);
  String? status = uri.queryParameters['status'];
  String? preapprovalId = uri.queryParameters['preapproval_id'];

print("Deep link recibido: $link");
 
  // Opcional: también chequea que preapproval_id no sea vacío o "0"
  if (preapprovalId == null) {
    print("Deep link ignorado: preapproval_id inválido");
    return;
  }


   resultadoPagoPendiente = {
      "titulo": "Exitoso",
      "mensaje": "Pago completado correctamente. ¡Gracias!",
    };

  print("Deep link válido procesado: status=$status, preapproval_id=$preapprovalId");
}

class MyApp extends StatelessWidget {
  final AppProvider appChangeProvider = AppProvider();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.light,
    ));

    return ChangeNotifierProvider.value(
      value: appChangeProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SaluMeD',

        // 👇 Esta línea bloquea el cambio de tamaño de texto del sistema
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaleFactor: 0.9, // siempre usa tamaño normal
              boldText: false, // desactiva texto en negrita
              highContrast: false,
            ),
            child: child!,
          );
        },

        onGenerateRoute: (settings) {
          if (kIsWeb) {
            Uri uriData = Uri.parse(settings.name ?? "");
            var params = uriData.queryParameters;
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
        },

        theme: ThemeData(
          fontFamily: 'Roboto', // Fuente base (la predeterminada de Flutter)
          useMaterial3: false,
          brightness: Brightness.light,
          primaryColor: CustomColors.primary,
          primarySwatch: CustomColors.primary,
          textTheme: const TextTheme(), // Respeta tus estilos locales
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
