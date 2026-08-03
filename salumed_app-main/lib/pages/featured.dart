import 'dart:async';
import 'package:app/helpers/helpers.dart';
import 'package:app/helpers/mercadopago_helper.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/start.dart';
import 'package:app/providers/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_preferences.dart';
import 'package:app/pages/breathing_screen.dart';
import 'package:app/pages/relaxing_audios.dart';
import 'package:app/pages/meditation_screen.dart';
import 'package:app/pages/good_sleep_screen.dart';
import 'package:app/pages/mindfulness_screen.dart';


class FeaturedPage extends StatefulWidget {
  const FeaturedPage({super.key});

  @override
  State<FeaturedPage> createState() => _FeaturedPageState();
}

class _FeaturedPageState extends State<FeaturedPage> {
  final ScrollController _scrollController = ScrollController();
  late Timer _scrollTimer;
  Timer? _userInactivityTimer;

  final double _scrollSpeed = 0.5;
  bool _userScrolled = false;

  final List<Map<String, dynamic>> _items = [
    {
      'icon': Icons.air,
      'label': 'Respiración\nConsciente',
      'screen': BreathingScreen()
    },
    {
      'icon': Icons.music_note,
      'label': 'Sonidos para\nDormir',
      'screen': RelaxAudioView()
    },
    {
      'icon': Icons.self_improvement,
      'label': 'Meditación de\n5 Min',
      'screen': MeditationScreen()
    },
    {
      'icon': Icons.brightness_2,
      'label': 'Rutina para\nDormir',
      'screen': GoodSleepScreen()
    },
    {
      'icon': Icons.favorite,
      'label': 'Mindfulness\ndiario',
      'screen': MindfulnessScreen()
    },
  ];

  String _lastRoutine =
      'Meditación guiada de 5 min'; // Genérico si no hay datos
  int _filledCircles = 0; // Todos vacíos si no hay datos

  @override
  void initState() {
    super.initState();
    _loadLastRoutine();
    _startAutoScroll();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final middleOffset = _scrollController.position.maxScrollExtent / 2;
      _scrollController.jumpTo(middleOffset);
    });
  }

  Future<void> _loadLastRoutine() async {
    print('DEPURACIÓN: _loadLastRoutine ejecutado a las ${DateTime.now()}');
    final prefs = await SharedPreferences.getInstance();
    final meditationDayCount = prefs.getInt('meditation_daycount') ?? 0;
    print('DEPURACIÓN: meditation_daycount: $meditationDayCount');

    setState(() {
      if (meditationDayCount > 0) {
        _lastRoutine = 'Meditación guiada de $meditationDayCount min';
        _filledCircles = (meditationDayCount > 5
            ? 5
            : meditationDayCount); // Máximo 5 círculos
      } else {
        _lastRoutine = 'Meditación guiada de 5 min'; // Genérico
        _filledCircles = 0; // Todos vacíos si no hay datos
      }
      print(
          'DEPURACIÓN: _lastRoutine establecido a: $_lastRoutine, _filledCircles: $_filledCircles');
    });
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_userScrolled || !_scrollController.hasClients) return;

      _scrollController.jumpTo(_scrollController.offset + _scrollSpeed);

      if (_scrollController.offset >
          _scrollController.position.maxScrollExtent - 500) {
        final middleOffset = _scrollController.position.maxScrollExtent / 2;
        _scrollController.jumpTo(middleOffset);
      }
    });
  }

  void _onUserInteraction() {
    _userScrolled = true;
    _userInactivityTimer?.cancel();

    _userInactivityTimer = Timer(const Duration(seconds: 2), () {
      _userScrolled = false;
    });
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _userInactivityTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repeatedItems =
        List.generate(1000, (index) => _items[index % _items.length]);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30)),
                    child: Image.asset(
                    kIsWeb? 'assets/images/mindfunless4.png' :'assets/images/mindfunless3.png',
                      height:kIsWeb?MediaQuery.of(context).size.height * .65 :MediaQuery.of(context).size.height * .55,
                      width: kIsWeb?  MediaQuery.of(context).size.width*.80:double.infinity,
                      fit: kIsWeb?BoxFit.fitWidth :BoxFit.fitWidth,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 32,
                  right: 32,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido a tu\nespacio de bienestar',
                        style: TextStyle(
                          fontSize: kIsWeb? 30 :25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Conéctate con tu mente, tu\ncuerpo y tu respiración.',
                        style: TextStyle(
                          fontSize: kIsWeb?20: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Carrusel Destacados
            SizedBox(
              height: 180,
              child: Listener(
                onPointerDown: (_) => _onUserInteraction(),
                onPointerMove: (_) => _onUserInteraction(),
                onPointerUp: (_) => _onUserInteraction(),
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: repeatedItems.length,
                  itemBuilder: (context, index) {
                    final item = repeatedItems[index];
                    return GestureDetector(
                      onTap: () async{
                        final provider =
                          Provider.of<AppProvider>(context, listen: false);

                      UserModel user = await AppPreferences().getUser();

                      if (user.id == null) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            PageTransition(
                                child: StartPage(false),
                                type: PageTransitionType.slideInUp,
                                duration: Duration(milliseconds: 250)),
                            (Route<dynamic> route) => false);
                      } else {
                        initProcess(context, user.token ?? "", () {
                          goHome(context, provider.user.roles);
                        });
                      }
                      },
                      child: _buildCard(item['icon'], item['label']),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Atajos
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                children: [
                  // Última rutina usada
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        MercadoPagoHelper(context).checkSubscription(
                            callback: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: MeditationScreen(),
                              type: PageTransitionType.slideInUp,
                              duration: Duration(milliseconds: 250),
                            ),
                          ).then((_) => _loadLastRoutine());
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.self_improvement,
                                size: 36, color: Colors.black87),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Última rutina',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _lastRoutine,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < _filledCircles
                                            ? Icons.circle
                                            : Icons.circle_outlined,
                                        size: 10,
                                        color: Colors.black54,
                                      );
                                    }),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Botón Iniciar
                  ElevatedButton(
                    onPressed: () async {
                      final provider =
                          Provider.of<AppProvider>(context, listen: false);

                      UserModel user = await AppPreferences().getUser();

                      if (user.id == null) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            PageTransition(
                                child: StartPage(false),
                                type: PageTransitionType.slideInUp,
                                duration: Duration(milliseconds: 250)),
                            (Route<dynamic> route) => false);
                      } else {
                        initProcess(context, user.token ?? "", () {
                          goHome(context, provider.user.roles);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3D1F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('Iniciar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 15, left: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.black87),
            const SizedBox(height: 15),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
