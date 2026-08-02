import 'dart:async';
import 'dart:convert';
import 'package:app/components/fade_animation.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/app_preferences.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/featured.dart';
import 'package:app/pages/guest_prescription.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:app/constants/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HeroPage extends StatefulWidget {
  String messageAfter;
  HeroPage({Key? key, this.messageAfter = ""}) : super(key: key);
  @override
  State<HeroPage> createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage> {
  int lagSeconds = 2;
  bool endLoading = false;
  String dailyQuote = "La constancia vence al talento cuando el talento no se esfuerza."; // Default
  bool loadingQuote = true;


  // NUEVO FLAG: Cambia a true para generar nueva frase CADA vez que inicie la app (ignora fecha y saved). False = comportamiento original (una por día).
  final bool forceNewQuoteOnLaunch = false;

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      SystemChrome.setEnabledSystemUIOverlays([]);

     /* if(!kIsWeb){
  bool permission = await OneSignal.Notifications.permission;
if (!permission) {
   OneSignal.Notifications.requestPermission(true);
}
}*/
      _initProcess();
    });



  }

  _initProcess() async {
    print("Iniciando initProcess");
    final provider = Provider.of<AppProvider>(context, listen: false);
    Timer(Duration(seconds: lagSeconds), () async {
      try {
        UserModel user = await AppPreferences().getUser();
      

        dynamic config = await WebService(context).getConfig();
        provider.setConfig(jsonDecode(jsonEncode(config)));
        if (tokenPrescription != null) {
          try {
            dynamic dataGuest = await WebService(context).getGuestDoctorData(tokenPrescription);
            if (user.id == null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(child: GuestPrescription(() {}, dataGuest), type: PageTransitionType.slideInUp, duration: Duration(milliseconds: 250)),
                  (Route<dynamic> route) => false);
            } else {
              await provider.setUser(user);
              initProcess(context, user.token ?? "", () {
                goHome(context, provider.user.roles, dataGuest: dataGuest);
              });
            }
            return;
          } catch (e) {}
        }
        setState(() { endLoading = true; });
        await _getDailyQuote(); // Carga frase

        if (user.id == null) {
          // Tu lógica de login
        } else {
          // Tu lógica
        }
      } catch (e) {
        print("Error al cargar 1: $e");
      }
    });
  }

  Future<void> _getDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final today = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}"; // Formato fijo
    String? savedDate = prefs.getString('quote_date');
    String? savedQuote = prefs.getString('daily_quote');

    // NUEVA LÓGICA DEL FLAG:
    // Si forceNewQuoteOnLaunch es true, ignora lo guardado y fuerza nueva generación (útil para testing o modo debug).
    // Si false, comportamiento original: usa saved si es hoy.
    bool useSaved = !forceNewQuoteOnLaunch && savedDate == today && savedQuote != null && savedQuote.isNotEmpty;

    if (useSaved) {
      setState(() {
        dailyQuote = savedQuote;
        loadingQuote = false;
      });
      return;
    }

    // Si no usa saved (o flag true), genera nueva
    try {
      final newQuote = await _generateQuoteWithOpenAI();
      // Solo guarda si NO es force mode (para no spam storage en tests repetidos)
      if (!forceNewQuoteOnLaunch) {
        await prefs.setString('daily_quote', newQuote);
        await prefs.setString('quote_date', today);
      }
      setState(() {
        dailyQuote = newQuote;
        loadingQuote = false;
      });
    } catch (e) {
      print("Error en frase: $e");
      // Fallback local
      final fallbacks = [
        "La constancia vence al talento cuando el talento no se esfuerza.",
        "Cuida tu salud como el tesoro más valioso que posees.",
        "La mente tranquila conquista cualquier tormenta.",
        "Cada día es una oportunidad para superarte."
      ];
      final fallback = fallbacks[DateTime.now().day % fallbacks.length];
      if (!forceNewQuoteOnLaunch) {
        await prefs.setString('daily_quote', fallback);
        await prefs.setString('quote_date', today);
      }
      setState(() {
        dailyQuote = fallback;
        loadingQuote = false;
      });
    }
  }

  Future<String> _generateQuoteWithOpenAI() async {
    final temas = ['estoicismo', 'superación personal', 'salud mental', 'mindfulness']; // Temas precisos
    final tema = temas[(DateTime.now().day + DateTime.now().month) % temas.length]; // Determinístico por día

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept-Charset': 'utf-8', // Fuerza UTF-8 en request
        'Authorization': 'Bearer $openAiApiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [{
          "role": "system",
          "content": "Genera UNA frase inspiradora corta (máximo 15 palabras) en español latino neutro sobre '$tema'. Usa acentos correctos en UTF-8 (á é í ó ú ñ). Responde SOLO la frase exacta, sin comillas, sin extras, sin saltos de línea. Ejemplo para salud: 'La salud es el regalo más grande que puedes darte cada día.'"
        }],
        "max_tokens": 40, // Limita para frases cortas
        "temperature": 0.5, // Baja para consistencia
      }),
    );

    if (response.statusCode == 200) {
      // Decodificación FORZADA UTF-8 desde bytes raw: esto asegura acentos correctos
      final bodyString = utf8.decode(response.bodyBytes);
      final data = jsonDecode(bodyString);
      final rawQuote = data['choices'][0]['message']['content'].trim(); // Solo trim, sin más

      // Validación mínima: si vacía o muy corta, error (GPT rara vez falla)
      if (rawQuote.isEmpty || rawQuote.length < 10) {
        throw Exception('Respuesta inválida de API');
      }

      print("Frase generada: $rawQuote"); // Para debug, quítalo en prod
      return rawQuote;
    } else {
      // Error con decode UTF-8
      final errorBody = utf8.decode(response.bodyBytes);
      throw Exception('API error ${response.statusCode}: $errorBody');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          navigateToNext();
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < -100) {
            navigateToNext();
          }
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/hero2.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.1),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: Center(
                        child: FadeAnimation(
                          1,
                          Image.asset(
                            'assets/images/salumed_white.png',
                            width: 80,
                          ),
                        ),
                      ),
                    ),
                    // Frase dinámica
                    loadingQuote
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            dailyQuote,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                    const SizedBox(height: 20),
                    Text(
                      "Frase del día",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    (!endLoading)
                        ? JumpingDotsProgressIndicator(
                            fontSize: 50.0,
                            color: Colors.white,
                            numberOfDots: 4,
                            milliseconds: 150,
                          )
                        : Container(height: 75),
                  ],
                ),
              ),
            ),
            (endLoading)
                ? Positioned(
                    bottom: 15,
                    left: 0,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up,
                          color: Color.fromARGB(156, 255, 255, 255),
                          size: 50,
                        ),
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  navigateToNext() {
    if (!endLoading || loadingQuote) {
      return;
    }
    Navigator.push(
        context,
        PageTransition(
            child: FeaturedPage(),
            type: PageTransitionType.slideInUp,
            duration: Duration(milliseconds: 550)));
  }
}