import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/app_preferences.dart';
import 'package:app/models/role.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/admin/admin_edit_profile.dart';
import 'package:app/pages/biometrics_page.dart';
import 'package:app/pages/breathing_screen.dart';
import 'package:app/pages/client/client_edit_profile.dart';
import 'package:app/pages/delivery/delivery_edit_profile.dart';
import 'package:app/pages/doctor/doctor_edit_profile.dart';
import 'package:app/pages/ebooks_view.dart';
import 'package:app/pages/forgot_password.dart';
import 'package:app/pages/good_sleep_screen.dart';
import 'package:app/pages/gym_screen.dart';
import 'package:app/pages/health_chat_view.dart';
import 'package:app/pages/hospital_admin/hospital_admin_edit_profile.dart';
import 'package:app/pages/laboratory_admin/laboratory_admin_profile.dart';
import 'package:app/pages/meditation_screen.dart';
import 'package:app/pages/pharmacy_admin/pharmacy_admin_profile.dart';
import 'package:app/pages/register.dart';
import 'package:app/pages/relaxing_audios.dart';
import 'package:app/pages/serenity_screen.dart';
import 'package:app/pages/stress_screen.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:snack/snack.dart';

import '../components/answer_question_dialog.dart';
import '../components/custom_dialog.dart';
import '../constants/colors.dart';
import '../helpers/mercadopago_helper.dart';
import '../main.dart';
import '../models/question.dart';

import 'calm_screen.dart';
import 'mindfulness_screen.dart';

class StartPage extends StatefulWidget {
  bool isLogged = false;
  StartPage(this.isLogged, {super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin,WidgetsBindingObserver  {
  late AnimationController _controller;
  bool isOpen = false;

  final List<_RadialButtonData> buttons = [
    _RadialButtonData(icon: Icons.self_improvement, label: 'Mindfulness'),
    _RadialButtonData(icon: Icons.spa, label: 'Meditación'),
    _RadialButtonData(icon: Icons.air, label: 'Respiración'),
    _RadialButtonData(icon: Icons.book, label: 'eBooks'),
  ];

  GlobalKey _temasBottomBar = GlobalKey();
  GlobalKey _saludBottomBar = GlobalKey();
  GlobalKey _atajoBombilla = GlobalKey();
  GlobalKey _biometriaBottomBar = GlobalKey();
  GlobalKey _perfilBottomBar = GlobalKey();
  GlobalKey _salud2BottomBar = GlobalKey();

  GlobalKey _resumen = GlobalKey();

  // Variables para datos del dashboard
  String miPlan = 'Mi plan';
  String ultimaPractica = 'No hay prácticas';
  String duracionPractica = '0 min';
  String presion = 'No registrada';
  String frecuenciaCardiaca = 'No registrada';
  String imc = 'No calculado';
  String ultimaRespiracion = 'No hay sesiones';
  String duracionRespiracion = '0 seg';
  String progresoMindfulness = 'Sem. 1, Día 1';
  String progresoMeditacion = 'Sem. 1, Día 1';
  String ultimoAudio = 'No hay audios';
  String estresEstimado = 'No disponible';
  String iaRecomienda = 'Respiración hoy';
  String buenDormir = 'Prueba ahora';
  String serenidad = 'Escribe';
  String gestionEstres = 'Libera tensiones';
  String calmaInterior = 'Prueba ahora';
  String progresoGym = 'Inicia ahora';
 var timerPushService = null;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () async {
        final prefs = await SharedPreferences.getInstance();
        final show_case = prefs.getBool('show_case') ?? false;
        if (!show_case) {
          ShowCaseWidget.of(contextShowCase!).startShowCase([
            _saludBottomBar,
            _temasBottomBar,
            _atajoBombilla,
            _biometriaBottomBar,
            _perfilBottomBar,
            _salud2BottomBar,
            _resumen
          ]);
        }
        _loadDashboardData(); // Cargar datos del dashboard
      });
    });
    subscriptionStatus();
    if(mounted){ initPush(context);}
   
    //  _chequearPagoPendiente();

        timerPushService = Timer.periodic(Duration(seconds: 30), (Timer t) {
       if(mounted){ registerPushId(context);}
    });
  }

void initPush(BuildContext context) {
  final provider = Provider.of<AppProvider>(context, listen: false);

if(!kIsWeb){
OneSignal.Notifications.addForegroundWillDisplayListener((event) {
 
    event.notification.display();
  });

  // Cuando el usuario TOCA la notificación
  OneSignal.Notifications.addClickListener((event) {
    dynamic additionalData = event.notification.additionalData;

    if (additionalData != null && additionalData.containsKey("notification")) {
      simpleLoading(context, (BuildContext loadingContext) async {
        WebService(context)
            .getNotificationsById(
                additionalData["notification"], provider.user.token ?? "")
            .then((notificationTmp) {
          Navigator.pop(loadingContext);

          String type = getTypeUser(context);
          if (type == "client") {
            openNotificationClient(context, notificationTmp);
          }
        }).catchError((e) {
          Navigator.pop(loadingContext);
          print(e);
        });
      });
    }
  });
} 
  
}
    void registerPushId(BuildContext context) async {

      if(kIsWeb) return;
  final provider = Provider.of<AppProvider>(context, listen: false);

  print("registerPushId called");

  // En v5 el ID se obtiene así (más directo)
  String? onesignalUserId = OneSignal.User.pushSubscription.id;

  if (onesignalUserId == null) {
    print("OneSignal User ID aún no disponible");
    return;
  }
print("OneSignal User ID"+onesignalUserId);

  if (provider.user.one_signal_id == null || provider.user.one_signal_id!.trim() != onesignalUserId ) {

    print("Registrando nuevo OneSignal ID: $onesignalUserId");

    try {
      await WebService(context).updateTokenPushUser(
        (Theme.of(context).platform == TargetPlatform.android) ? "android" : "ios",
        onesignalUserId,
        provider.user.token ?? "",
      ).then((value) {
        provider.setUser(value);
      });
    } catch (e) {
      print("Error registrando push ID: $e");
    }
  }
}


  @override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    print("App regresó a primer plano");
    // ¡Aquí sí se ejecuta cuando regresa del navegador/MercadoPago!
    _chequearPagoPendiente();
  }
}

void _chequearPagoPendiente() {

  if (resultadoPagoPendiente != null && mounted){



  if (resultadoPagoPendiente != null) {
    // Mostramos la alerta
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextdialog) => CustomDialog(
        resultadoPagoPendiente!["titulo"]!,
        resultadoPagoPendiente!["mensaje"]!,
        "OK",
        () {
        
          resultadoPagoPendiente = null; // Limpiamos para no repetir
        },
      ),
    );
  }
  }
}

  Future<void> _loadDashboardData() async {
    print('DEPURACIÓN: _loadDashboardData ejecutado a las ${DateTime.now()}');
    final prefs = await SharedPreferences.getInstance();

    // Depuración: Mostrar valores de SharedPreferences
    print('DEPURACIÓN: calm_last_used: ${prefs.getString('calm_last_used')}');
    print('DEPURACIÓN: calm_duration: ${prefs.getInt('calm_duration')}');
    print('DEPURACIÓN: registros: ${prefs.getString('registros')}');
    print(
        'DEPURACIÓN: breathing_history: ${prefs.getString('breathing_history')}');
    print('DEPURACIÓN: mindfulness_week: ${prefs.getInt('mindfulness_week')}');
    print(
        'DEPURACIÓN: mindfulness_daycount: ${prefs.getInt('mindfulness_daycount')}');
    print('DEPURACIÓN: meditation_week: ${prefs.getInt('meditation_week')}');
    print(
        'DEPURACIÓN: meditation_daycount: ${prefs.getInt('meditation_daycount')}');
    print('DEPURACIÓN: last_audio: ${prefs.getString('last_audio')}');
    print('DEPURACIÓN: last_audio_time: ${prefs.getString('last_audio_time')}');
    print(
        'DEPURACIÓN: good_sleep_last_used: ${prefs.getString('good_sleep_last_used')}');
    print(
        'DEPURACIÓN: good_sleep_duration: ${prefs.getInt('good_sleep_duration')}');
    print(
        'DEPURACIÓN: serenity_last_thought: ${prefs.getString('serenity_last_thought')}');
    print(
        'DEPURACIÓN: serenity_last_used: ${prefs.getString('serenity_last_used')}');
    print(
        'DEPURACIÓN: serenity_duration: ${prefs.getInt('serenity_duration')}');
    print(
        'DEPURACIÓN: stress_last_used: ${prefs.getString('stress_last_used')}');
    print('DEPURACIÓN: stress_duration: ${prefs.getInt('stress_duration')}');

    // Pequeño retraso para asegurar que SharedPreferences termine de guardar
    await Future.delayed(Duration(milliseconds: 2000));

    // Biometrics
    final registrosJson = prefs.getString('registros');
    if (registrosJson != null && registrosJson.isNotEmpty) {
      final List<dynamic> registros = json.decode(registrosJson);
      if (registros.isNotEmpty) {
        final ultimo = registros.last as Map<String, dynamic>;
        presion = ultimo['presion'] ?? 'No registrada';
        frecuenciaCardiaca = '${ultimo['frecuencia'] ?? 'No'} bpm';
        imc = '${ultimo['imc']?.toStringAsFixed(2) ?? 'No calculado'}';
        // Estimar estrés basado en frecuencia
        final freq = ultimo['frecuencia'] as int? ?? 0;
        if (freq > 100) {
          estresEstimado = 'Alto';
        } else if (freq > 80) {
          estresEstimado = 'Medio';
        } else {
          estresEstimado = 'Bajo';
        }
      }
    }

    // Breathing
    final breathingJson = prefs.getString('breathing_history');
    if (breathingJson != null && breathingJson.isNotEmpty) {
      final List<dynamic> history = json.decode(breathingJson);
      if (history.isNotEmpty) {
        final ultimo = history.last as Map<String, dynamic>;
        ultimaRespiracion = ultimo['type'] ?? 'No hay sesiones';
        duracionRespiracion = ultimo['duration'] ?? '0 seg';
        ultimaPractica = 'Resp.: ${ultimo['type']}'; // Abreviado
        duracionPractica = ultimo['duration'].replaceAll(' segundos', ' seg');
      }
    }

    // Mindfulness
    final mindWeek = prefs.getInt('mindfulness_week') ?? 1;
    final mindDay = prefs.getInt('mindfulness_daycount') ?? 0;
    progresoMindfulness = 'Sem. $mindWeek, Día ${mindDay + 1}'; // Abreviado

    // Meditation
    final medWeek = prefs.getInt('meditation_week') ?? 1;
    final medDay = prefs.getInt('meditation_daycount') ?? 0;
    progresoMeditacion = 'Sem. $medWeek, Día ${mindDay + 1}'; // Abreviado

    // Relaxing Audios
    final lastAudio = prefs.getString('last_audio');
    final lastTime = prefs.getString('last_audio_time');
    if (lastAudio != null) {
      ultimoAudio = '$lastAudio ($lastTime)';
    }

    // Good Sleep
    final goodSleepLastUsed = prefs.getString('good_sleep_last_used');
    final goodSleepDuration = prefs.getInt('good_sleep_duration');
    if (goodSleepLastUsed != null) {
      final date = DateTime.parse(goodSleepLastUsed);
      buenDormir =
          '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)}';
      if (goodSleepDuration != null) {
        buenDormir +=
            ', ${goodSleepDuration ~/ 60}:${(goodSleepDuration % 60).toString().padLeft(2, '0')}';
      }
    }

    // Serenity
    final serenityThought = prefs.getString('serenity_last_thought');
    if (serenityThought != null && serenityThought.isNotEmpty) {
      serenidad =
          'Pens.: ${serenityThought.length > 15 ? serenityThought.substring(0, 12) + '...' : serenityThought}';
    } else {
      final serenityLastUsed = prefs.getString('serenity_last_used');
      if (serenityLastUsed != null) {
        final date = DateTime.parse(serenityLastUsed);
        serenidad =
            '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)}';
        final serenityDuration = prefs.getInt('serenity_duration');
        if (serenityDuration != null) {
          serenidad +=
              ', ${serenityDuration ~/ 60}:${(serenityDuration % 60).toString().padLeft(2, '0')}';
        }
      }
    }

    // Stress
    final stressLastUsed = prefs.getString('stress_last_used');
    final stressDuration = prefs.getInt('stress_duration');
    if (stressLastUsed != null) {
      final date = DateTime.parse(stressLastUsed);
      gestionEstres =
          '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)}';
      if (stressDuration != null) {
        gestionEstres +=
            ', ${stressDuration ~/ 60}:${(stressDuration % 60).toString().padLeft(2, '0')}';
      }
    }

    // Calm
    final calmLastUsed = prefs.getString('calm_last_used');
    final calmDuration = prefs.getInt('calm_duration');
    if (calmLastUsed != null) {
      final date = DateTime.parse(calmLastUsed);
      calmaInterior =
          '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)}';
      if (calmDuration != null) {
        calmaInterior +=
            ', ${calmDuration ~/ 60}:${(calmDuration % 60).toString().padLeft(2, '0')}';
      }
    }

// Gym (usa claves dinámicas basadas en tipo y nivel seleccionados)
    final trainingType = prefs.getString('training_type') ??
        'gym'; // Default 'gym' si no seleccionado
    final trainingLevel =
        prefs.getString('training_level'); // Puede ser null si no seleccionado

    String progresoGymValue =
        'No seleccionada'; // Si no hay nivel, muestra esto
    if (trainingLevel != null) {
      final gymWeekKey = '${trainingType}_${trainingLevel}_current_week';
      final gymDayKey = '${trainingType}_${trainingLevel}_current_day';
      final gymWeek = prefs.getInt(gymWeekKey) ?? 1;
      final gymDay = prefs.getInt(gymDayKey) ?? 0; // 0-based
      progresoGymValue =
          'Sem. ${gymWeek.toString().padLeft(2, '0')}, Día ${(gymDay + 1).toString().padLeft(2, '0')}';
    }
    progresoGym = progresoGymValue;

    print('DEPURACIÓN: calmaInterior establecido a: $calmaInterior');
    setState(() {
      print('DEPURACIÓN: setState ejecutado');
    }); // Actualizar UI
  }

  Future<void> seeShowCase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_case', true);
  }

  void _mostrarTipoUsuarioPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoginTypeDialog(
        onLogin: (email, pass) => processSignInEmailPassword(email, pass),
        onForgotPassword: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ForgotPassword()),
          ).then((_) => _loadDashboardData());
        },
        onSelectType: (type) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Register(type)),
          ).then((_) => _loadDashboardData());
        },
        onRefreshDashboard: _loadDashboardData, // Pass _loadDashboardData
      ),
    );
  }

  void processSignInEmailPassword(String email, String password) {
    simpleLoading(context, (BuildContext loadingContext) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      WebService(context).signIn(email, password).then((user) async {
        await provider.setUser(user);
        initProcess(context, user.token ?? "", () {
          Navigator.pop(loadingContext);
          goHome(context, provider.user.roles);
        });
      }).catchError((e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e);
      });
    });
  }

  void _toggleMenu() {
    setState(() {
      isOpen = !isOpen;
      if (isOpen)
        _controller.forward();
      else
        _controller.reverse();
    });
  }

  void _mostrarTemasBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Todos los temas',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      controller: controller,
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _temaItem(Icons.fitness_center, 'Ponte en Forma', () {

                          checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: GymScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });
                    
                        }),
                        _temaItem(Icons.self_improvement, 'Mindfulness', () {

                                 checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: MindfulnessScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });

                      
                        }),
                        _temaItem(Icons.spa, 'Meditación', () {

                              checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: MeditationScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });


                        
                        }),
                        _temaItem(Icons.air, 'Respiración', () {
                             checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: BreathingScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });

                        }),
                        _temaItem(Icons.sentiment_satisfied_alt, 'Calma', () {

                              checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: CalmScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });

                        
                        }),
                        _temaItem(Icons.water_drop, 'Serenidad', () {

                            checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: SerenityScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });

                        }),
                        _temaItem(Icons.nightlight_round, 'Dormir', () {

                             checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: GoodSleepScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });

                        
                        }),
                        _temaItem(Icons.bolt, 'Estrés', () {
                            checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: StressScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });


                        }),
                        _temaItem(Icons.music_note, 'Sonidos Relajantes', () {
                             checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: RelaxAudioView(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });


                    
                        }),
                        _temaItem(Icons.psychology, 'IA Recomienda', () {
                                checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: HealthChatView(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });


                         
                        }),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _temaItem(IconData icon, String label, Function callback) {
    return GestureDetector(
      onTap: () {
        callback();
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6F2F7),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF91C8E4)),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();

        try {
      if (timerPushService != null) timerPushService?.cancel();
      //socket.onDisconnect((_) => print('disconnect'));
      //socket.dispose();
    } catch (e) {}
    super.dispose();
  }

  Widget _buildRadialMenu({double verticalOffset = 0}) {
    final radius = 100.0;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !isOpen,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Transform.translate(
              offset: Offset(0, verticalOffset),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(buttons.length, (i) {
                    final angle = (2 * pi / buttons.length) * i - pi / 2;
                    final x = cos(angle) * radius;
                    final y = sin(angle) * radius;

                    return Transform.translate(
                      offset:
                          Offset(x * _controller.value, y * _controller.value),
                      child: Opacity(
                        opacity: _controller.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FloatingActionButton(
                              mini: true,
                              heroTag: buttons[i].label,
                              onPressed: () {
                                print("clic: ${buttons[i].label}");
                                if (buttons[i].label == 'Mindfulness') {

                                        checkSubscriptionAndRedirect((){
                        
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: MindfulnessScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });

                                } else if (buttons[i].label == 'Meditación') {
                                         checkSubscriptionAndRedirect((){
                         
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: MeditationScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });

                                
                                } else if (buttons[i].label == 'Respiración') {

                                       checkSubscriptionAndRedirect((){
                         
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: BreathingScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });
                              
                                } else if (buttons[i].label == 'eBooks') {

                                  
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      child: EbooksView(),
                                      type: PageTransitionType.slideInUp,
                                      duration: Duration(milliseconds: 250),
                                    ),
                                  ).then((_) => _loadDashboardData());
                                }
                              },
                              backgroundColor: const Color(0xFFA8D5BA),
                              child: Icon(buttons[i].icon, color: Colors.white),
                            ),
                            const SizedBox(height: 5),
                            Text(buttons[i].label,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (isOpen)
                    FloatingActionButton(
                      backgroundColor: const Color(0xFF91C8E4),
                      onPressed: _mostrarTemasBottomSheet,
                      elevation: 6,
                      child: const Icon(Icons.apps, color: Colors.white),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String isActivePlan = '...';
  subscriptionStatus() async {
    bool isActive = await MercadoPagoHelper(context).isSubscriptionActive();

    setState(() {
      isActivePlan = isActive ? "Activa" : "Inactiva";
    });
  }

  confirmCancel() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (contextDialog) {
          return CustomDialog(
            "¿Confirmar cancelación?",
            "Esta acción cancelará su suscripción y perderá acceso a los beneficios premium.",
            "Cancelar Suscripción",
            () {
              simpleLoading(context, (BuildContext loadingContext) async {
                final provider =
                    Provider.of<AppProvider>(context, listen: false);
              
        
                  await WebService(context)
                      .cancelSubscription(
                          provider.user.id ?? "", provider.user.token ?? "")
                      .then((value)async {
                    
                  //  Navigator.pop(loadingContext);

                        Navigator.pop(loadingContext);
                           
                            await  subscriptionStatus();
                               SnackBar(
                    content: Text("Su suscripción ha sido cancelada exitosamente.",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    elevation: 100,
                    duration: Duration(seconds: 2),
                    backgroundColor: CustomColors.primary)
                .show(context);
                 
                  }).catchError((e) {
                    Navigator.pop(loadingContext);
                    showErrorsDialog(context, e);
                  });
                
              });
            },
            useBtnCancel: true,
            textBtnCancel: "Permanecer Suscrito",
            image: '',
          );
        });
  }

   checkSubscriptionAndRedirect (Function callback)async {
     MercadoPagoHelper(context).checkSubscription(
                            callback: () {
                        callback();
                        },callbackLogin: (){
                          _mostrarTipoUsuarioPopup();
                        });
  }

  Widget _buildDashboard() {
    return Center(
      child: Wrap(spacing: 12, runSpacing: 12, children: [
        InkWell(
          onTap: () async{
            await  subscriptionStatus();
   final provider =
                    Provider.of<AppProvider>(context, listen: false);

if(provider.user.id == null){
      MercadoPagoHelper( context).checkSubscription(callback: (){
   
    });
    return;
}

            if(isActivePlan == "Activa"){
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (contextDialog) {
                  return CustomDialog(
                    "",
                    "¿Desea cancelar su suscripción?",
                    "Cancelar Suscripción",
                    () {
                      confirmCancel();
                    },
                    useBtnCancel: true,
                    textBtnCancel: "Permanecer Suscrito",
                    image: '',
                  );
                });
            }else{
    MercadoPagoHelper( context).checkSubscription(callback: ()async{
   await  subscriptionStatus();
    });
            }
          
          },
          child: _DashboardCard(
              icon: Icons.self_improvement,
              title: 'Mi plan',
              value: isActivePlan),
        ),
        _DashboardCard(
            icon: Icons.self_improvement,
            title: 'Práctica',
            value: ultimaPractica),
        _DashboardCard(
            icon: Icons.access_time,
            title: 'Tiempo Pract.',
            value: duracionPractica),
        _DashboardCard(icon: Icons.favorite, title: 'Presión', value: presion),
        _DashboardCard(
            icon: Icons.monitor_heart,
            title: 'Frec. Cardíaca',
            value: frecuenciaCardiaca),
        _DashboardCard(icon: Icons.monitor_weight, title: 'IMC', value: imc),
        _DashboardCard(
            icon: Icons.air, title: 'Respiración', value: ultimaRespiracion),
        _DashboardCard(
            icon: Icons.timer,
            title: 'Tiempo Resp.',
            value: duracionRespiracion),
        _DashboardCard(
            icon: Icons.psychology_alt,
            title: 'Mindfulness',
            value: progresoMindfulness),
        _DashboardCard(
            icon: Icons.spa, title: 'Meditación', value: progresoMeditacion),
        _DashboardCard(
            icon: Icons.music_note, title: 'Audio', value: ultimoAudio),
        _DashboardCard(
            icon: Icons.mood, title: 'Estrés', value: estresEstimado),
        _DashboardCard(
            icon: Icons.psychology,
            title: 'IA Recomienda',
            value: iaRecomienda),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                child: CalmScreen(),
                type: PageTransitionType.slideInUp,
                duration: Duration(milliseconds: 250),
              ),
            ).then((_) => _loadDashboardData());
          },
          child: _DashboardCard(
              icon: Icons.sentiment_satisfied_alt,
              title: 'Calma',
              value: calmaInterior),
        ),
        GestureDetector(
          onTap: () {
        

                   checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: GoodSleepScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });

          },
          child: _DashboardCard(
              icon: Icons.nightlight_round, title: 'Dormir', value: buenDormir),
        ),
        GestureDetector(
          onTap: () {
                checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: SerenityScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });

          },
          child: _DashboardCard(
              icon: Icons.water_drop, title: 'Serenidad', value: serenidad),
        ),
        GestureDetector(
          onTap: () {
                checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: StressScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });

        
          },
          child: _DashboardCard(
              icon: Icons.bolt, title: 'Estrés', value: gestionEstres),
        ),
        GestureDetector(
          onTap: () {

                    checkSubscriptionAndRedirect((){
                             Navigator.pop(context);
                              Navigator.push(
                                      context,
                                      PageTransition(
                                          child: GymScreen(),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)))
                                  .then((_) => _loadDashboardData());
                          });

         
          },
          child: _DashboardCard(
            icon: Icons.fitness_center,
            title: 'Entrenamiento',
            value: progresoGym,
          ),
        ),
      ]),
    );
  }

  Future<void> showAnswerQuestionDialog({
    required BuildContext context,
    required QuestionModel question,
    required Function(String answer, dynamic image) onSubmit,
    bool useBtnCancel = true,
    String image = "",
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AnswerQuestionDialog(
          question,
          (String answer, dynamic imageSelected) {
            onSubmit(answer, imageSelected);
          },
          useBtnCancel: useBtnCancel,
          image: image,
        );
      },
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Showcase(
            key: _saludBottomBar,
            title: "Salud",
            description:
                "Inicia sesión y gestiona tus recetas médicas, pide medicamentos a domicilio y disfruta de más funciones para mantener tu salud.",
            child: _bottomBarItem(Icons.home, 'Salud', () async {
              UserModel user = await AppPreferences().getUser();
              if (user.id == null) {
                _mostrarTipoUsuarioPopup();
              } else {
                if (scaffoldKeyMainLayout != null &&
                    scaffoldKeyMainLayout is GlobalKey) {
                  scaffoldKeyMainLayout.currentState!.openDrawer();
                }
              }
            }, const Color(0xFF91C8E4)),
          ),
          Showcase(
              key: _temasBottomBar,
              title: "Temas",
              description:
                  "Con este botón podrás acceder fácilmente a todas las actividades disponibles.",
              child: _bottomBarItem(Icons.view_module, 'Temas',
                  _mostrarTemasBottomSheet, const Color(0xFFA8D5BA))),
          const SizedBox(width: 48),
          Showcase(
              key: _biometriaBottomBar,
              title: "Biometría",
              description:
                  "Registra tus signos vitales y datos de salud de forma rápida y sencilla, para llevar un mejor control de tu bienestar diario.",
              child: _bottomBarItem(Icons.monitor_heart, 'Biometría', () {
                Navigator.push(
                        context,
                        PageTransition(
                            child: BiometriaPage(),
                            type: PageTransitionType.slideInUp,
                            duration: Duration(milliseconds: 250)))
                    .then((_) => _loadDashboardData());
              }, const Color(0xFFF7C59F))),
          Showcase(
              key: _perfilBottomBar,
              title: "Perfil",
              description:
                  "Gestiona tu información personal, preferencias y configuración de la app para una experiencia personalizada.",
              child: _bottomBarItem(Icons.person, 'Perfil', () async {
                UserModel user = await AppPreferences().getUser();
                if (user.id == null) {
                  _mostrarTipoUsuarioPopup();
                } else {
                  List<RoleModel> roles = user.roles ?? [];

                  if (checkHasRole(roles, "admin")) {
                    Navigator.push(
                            context,
                            PageTransition(
                                child: AdminEditProfile(),
                                type: PageTransitionType.slideInUp,
                                duration: Duration(milliseconds: 250)))
                        .then((_) => _loadDashboardData());
                  } else if (checkHasRole(roles, "super_admin")) {
                    Navigator.push(
                            context,
                            PageTransition(
                                child: AdminEditProfile(),
                                type: PageTransitionType.slideInUp,
                                duration: Duration(milliseconds: 250)))
                        .then((_) => _loadDashboardData());
                  } else if (checkHasRole(roles, "pharmacy_admin")) {
                    Navigator.push(
                            context,
                            PageTransition(
                                child: PharmacyAdminProfile(),
                                type: PageTransitionType.slideInUp,
                                duration: Duration(milliseconds: 250)))
                        .then((_) => _loadDashboardData());
                  } else if (checkHasRole(roles, "laboratory_admin")) {
                    Navigator.push(
                            context,
                            PageTransition(
                                child: LaboratoryAdminProfile(),
                                type: PageTransitionType.slideInUp,
                                duration: Duration(milliseconds: 250)))
                        .then((_) => _loadDashboardData());
                  } else if (checkHasRole(roles, "client")) {
                    Navigator.push(
                            context,
                            PageTransition(
                                child: ClientEditProfile(),
                                type: PageTransitionType.slideInUp,
                                duration: Duration(milliseconds: 250)))
                        .then((_) => _loadDashboardData());
                  } else if (checkHasRole(roles, "delivery")) {
                    Navigator.push(
                            context,
                            PageTransition(
                                child: DeliveryEditProfile(),
                                type: PageTransitionType.slideInUp,
                                duration: Duration(milliseconds: 250)))
                        .then((_) => _loadDashboardData());
                  } else if (checkHasRole(roles, "doctor")) {
                    Navigator.push(
                            context,
                            PageTransition(
                                child: DoctorEditProfile(),
                                type: PageTransitionType.slideInUp,
                                duration: Duration(milliseconds: 250)))
                        .then((_) => _loadDashboardData());
                  } else if (checkHasRole(roles, "hospital_admin")) {
                    Navigator.push(
                            context,
                            PageTransition(
                                child: HospitalAdminEditProfile(),
                                type: PageTransitionType.slideInUp,
                                duration: Duration(milliseconds: 250)))
                        .then((_) => _loadDashboardData());
                  }
                }
              }, const Color(0xFFF48498))),
        ]),
      ),
    );
  }

  Widget _bottomBarItem(
          IconData icon, String label, VoidCallback onTap, Color color) =>
      GestureDetector(
          onTap: onTap,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ]));

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      autoPlay: false,
      builder: Builder(
        builder: (contextSC) {
          contextShowCase = contextSC;
          return Scaffold(
            backgroundColor: const Color(0xFFFDFCF9),
            body: Stack(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: (widget.isLogged) ? 0 : 50,
                      left: 32,
                      right: 32,
                      bottom: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('¿Listo para comenzar?',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        SizedBox(height: 10),
                        Text(
                            'Elige tu práctica favorita y da el primer paso hacia tu bienestar.',
                            style:
                                TextStyle(fontSize: 17, color: Colors.black54)),
                        SizedBox(height: 15),
                        Text('Tu progreso',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ]),
                ),
                InkWell(
                  onTap: () async {
                    UserModel user = await AppPreferences().getUser();
                    if (user.id == null) {
                      _mostrarTipoUsuarioPopup();
                    } else {
                      if (scaffoldKeyMainLayout != null &&
                          scaffoldKeyMainLayout is GlobalKey) {
                        scaffoldKeyMainLayout.currentState!.openDrawer();
                      }
                    }
                  },
                  child: Showcase(
                      key: _salud2BottomBar,
                      title: "Salud y medicamentos",
                      description:
                          "Inicia sesión y gestiona tus recetas médicas, pide medicamentos a domicilio y disfruta de más funciones para mantener tu salud.",
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 16.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F2F7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(children: [
                            SizedBox(height: 8),
                            Text("Mi Salud Médica",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("Salud y medicamentos al instante",
                                style: TextStyle(fontSize: 14)),
                          ]),
                        ),
                      )),
                ),
                if (!isOpen)
                  Expanded(
                      child: SingleChildScrollView(
                          padding: const EdgeInsets.only(
                              left: 0, right: 0, bottom: 50),
                          child: Showcase(
                              key: _resumen,
                              title: "Resumen",
                              description:
                                  "Visualiza un panel con tus datos clave y un resumen de tus últimas actividades.",
                              child: _buildDashboard()))),
              ]),
              _buildRadialMenu(verticalOffset: 90),
            ]),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Showcase(
              key: _atajoBombilla,
              title: "Atajo",
              description:
                  "Accede rápido a Mindfulness, Meditación y Respiración, y descubre eBooks útiles para tu bienestar.",
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF91C8E4),
                onPressed: _toggleMenu,
                child: Icon(isOpen ? Icons.close : Icons.lightbulb,
                    color: Colors.white),
              ),
            ),
            bottomNavigationBar: _buildBottomAppBar(),
          );
        },
      ),
      onFinish: () {
        seeShowCase();
      },
    );
  }
}

class _RadialButtonData {
  final IconData icon;
  final String label;
  _RadialButtonData({required this.icon, required this.label});
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width - 48) / 2;
    return Container(
      constraints: BoxConstraints(minHeight: 130),
      width: cardWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F2F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: const Color(0xFF91C8E4)),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class LoginTypeDialog extends StatefulWidget {
  final void Function(String email, String pass) onLogin;
  final VoidCallback onForgotPassword;
  final void Function(String role) onSelectType;
  final VoidCallback onRefreshDashboard;

  const LoginTypeDialog({
    required this.onLogin,
    required this.onForgotPassword,
    required this.onSelectType,
    required this.onRefreshDashboard,
    super.key,
  });

  @override
  State<LoginTypeDialog> createState() => _LoginTypeDialogState();
}

class _LoginTypeDialogState extends State<LoginTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cEmail = TextEditingController();
  final _cPass = TextEditingController();
  bool _showLogin = true;
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 28),
                    if (_showLogin)
                      Column(
                        children: [
                          const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _cEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Correo electrónico',
                                    prefixIcon: Icon(Icons.email),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese su correo';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _cPass,
                                  obscureText: !_passwordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    prefixIcon: Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(_passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese su contraseña';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      widget.onLogin(
                                        _cEmail.text.trim(),
                                        _cPass.text.trim(),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: const Color(0xFF91C8E4),
                                  ),
                                  child: const Text('Ingresar'),
                                ),
                                TextButton(
                                  onPressed: widget.onForgotPassword,
                                  child:
                                      const Text('¿Olvidaste tu contraseña?'),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showLogin = false;
                                    });
                                  },
                                  child: const Text(
                                    '¿Eres nuevo?',
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          const Text(
                            'Selecciona tu tipo de cuenta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: [
                              _roleOption('Eres cliente', 'cliente'),
                              _roleOption('Eres médico', 'medico'),
                              _roleOption('Farmacia o laboratorio', 'farmacia'),
                              _roleOption('Hospital o clínica', 'hospital'),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.close, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleOption(String label, String role) {
    IconData icon;

    switch (role) {
      case 'cliente':
        icon = Icons.person_outline;
        break;
      case 'medico':
        icon = Icons.local_hospital;
        break;
      case 'farmacia':
        icon = Icons.medical_services_outlined;
        break;
      case 'hospital':
        icon = Icons.apartment;
        break;
      default:
        icon = Icons.account_circle_outlined;
    }

    return InkWell(
      onTap: () {
        switch (role) {
          case 'cliente':
            Navigator.push(
                    context,
                    PageTransition(
                        child: Register("client"),
                        type: PageTransitionType.slideInRight,
                        duration: Duration(milliseconds: 250)))
                .then((_) => widget.onRefreshDashboard());
            break;
          case 'medico':
            Navigator.push(
                    context,
                    PageTransition(
                        child: Register("doctor"),
                        type: PageTransitionType.slideInRight,
                        duration: Duration(milliseconds: 250)))
                .then((_) => widget.onRefreshDashboard());
            break;
          case 'farmacia':
            Navigator.push(
                    context,
                    PageTransition(
                        child: Register("pharmacy_admin"),
                        type: PageTransitionType.slideInRight,
                        duration: Duration(milliseconds: 250)))
                .then((_) => widget.onRefreshDashboard());
            break;
          case 'hospital':
            Navigator.push(
                    context,
                    PageTransition(
                        child: Register("hospital_admin"),
                        type: PageTransitionType.slideInRight,
                        duration: Duration(milliseconds: 250)))
                .then((_) => widget.onRefreshDashboard());
            break;
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF42A5F5)),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogin() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Ingresa a tu cuenta',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            controller: _cEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (v) =>
                v != null && v.contains('@') ? null : 'Email inválido',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cPass,
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              hintText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() {
                  _passwordVisible = !_passwordVisible;
                }),
              ),
            ),
            validator: (v) =>
                v != null && v.length >= 6 ? null : '6+ caracteres',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final form = _formKey.currentState;
              if (form!.validate()) {
                form.save();
                processSignInEmailPassword(
                    _cEmail.text.trim(), _cPass.text.trim());
              }
            },
            child: const Text('Ingresar'),
          ),
        ]),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: widget.onForgotPassword,
        child: const Text('¿Olvidaste tu contraseña?'),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () => setState(() => _showLogin = false),
        child: const Text('Registrarme'),
      ),
    ]);
  }

  processSignInEmailPassword(email, pass) async {
    simpleLoading(context, (BuildContext loadingContext) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      WebService(context).signIn(email, pass).then((user) async {
        await provider.setUser(user);
        initProcess(context, user.token ?? "", () {
          Navigator.pop(loadingContext);
          goHome(context, provider.user.roles);
        });
      }).catchError((e) {
        print(e);
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e);
      });
    });
  }

  Widget _buildTypeGrid() {
    final roles = [
      {'icon': Icons.person, 'label': 'Miembro', 'type': 'client'},
      {'icon': Icons.medical_services, 'label': 'Médico', 'type': 'doctor'},
      {
        'icon': Icons.local_pharmacy,
        'label': 'Farmacia/Lab.',
        'type': 'pharmacy_admin'
      },
      {
        'icon': Icons.local_hospital,
        'label': 'Hospital/Clínica',
        'type': 'hospital_admin'
      },
    ];

    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('¿Eres?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: roles.map((r) {
          return GestureDetector(
            onTap: () => widget.onSelectType(r['type'] as String),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(r['icon'] as IconData,
                      size: 30, color: const Color(0xFF91C8E4)),
                  const SizedBox(height: 8),
                  Text(r['label'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () => setState(() => _showLogin = true),
        child: const Text('Volver al inicio de sesión'),
      ),
    ]);
  }
}
