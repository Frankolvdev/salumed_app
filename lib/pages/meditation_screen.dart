import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

class MeditationScreen extends StatefulWidget {
  @override
  _MeditationScreenState createState() => _MeditationScreenState();
}

class MeditationPhase {
  final String label;
  final int seconds;
  MeditationPhase(this.label, this.seconds);
}


class _MeditationScreenState extends State<MeditationScreen> with TickerProviderStateMixin {
  // — Progreso diario/semanal —
  int _currentWeek = 1;
  int _currentDayCount = 0;
  DateTime? _lastSessionDate;
  bool _sessionStarted = false;
  bool _sessionCompletedToday = false;
  bool _isMuted = false;
  bool _isIntroPlaying = false;
  bool _isButtonDisabled = false;
  bool _showVideo = true;

  // — Controladores y timers —
  AudioPlayer _voicePlayer = AudioPlayer();
  VideoPlayerController? _videoController;
  //AnimationController? _pulseController;
  Timer? _breathingTimer;
  Timer? _sessionTimer;
  Timer? _elapsedTimer;

  int _currentPhaseIndex = 0;
  Duration _elapsed = Duration.zero;
  Duration _sessionDuration = Duration(minutes: 1);
  List<MeditationPhase> _phases = [];

  // — Definiciones de duración y patrones —
  final Map<int, Duration> weekDurations = {
    1: Duration(minutes: 1),
    2: Duration(minutes: 5),
    3: Duration(minutes: 10),
    4: Duration(minutes: 20),
    5: Duration(minutes: 30),
    6: Duration(minutes: 40),
    7: Duration(minutes: 50),
    8: Duration(minutes: 60),
  };

  final Map<int, List<MeditationPhase>> breathingPatterns = {
    1: [MeditationPhase('inhala', 3), MeditationPhase('mantén', 3), MeditationPhase('exhala', 3)],
    2: [MeditationPhase('inhala', 5), MeditationPhase('mantén', 3), MeditationPhase('exhala', 5)],
    3: [MeditationPhase('inhala', 5), MeditationPhase('mantén', 3), MeditationPhase('exhala', 7)],
    4: [MeditationPhase('inhala', 5), MeditationPhase('mantén', 4), MeditationPhase('exhala', 7)],
    5: [MeditationPhase('inhala', 4), MeditationPhase('mantén', 3), MeditationPhase('exhala', 7)],
    6: [MeditationPhase('inhala', 4), MeditationPhase('mantén', 3), MeditationPhase('exhala', 7)],
    7: [MeditationPhase('inhala', 4), MeditationPhase('mantén', 3), MeditationPhase('exhala', 7)],
    8: [MeditationPhase('inhala', 4), MeditationPhase('mantén', 3), MeditationPhase('exhala', 7)],
  };

  @override
  void initState() {
    super.initState();
    _loadProgress();

    // Inicializa animación de pulso
   // _pulseController = AnimationController(vsync: this, duration: Duration(seconds: 2))
    //  ..repeat(reverse: true);

    // Video de fondo
    _videoController = VideoPlayerController.asset('assets/video/meditation_bg.mp4')
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        _videoController!.play();
        setState(() {});
      });

    // Alerta de volumen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🔊 Sube el volumen para escuchar los audios de respiración. Para una mejor experiencia, coloca tus audífonos y cierra los ojos. Esto te permitirá sumergirte completamente en la práctica de meditación.'),
        duration: Duration(seconds: 7),
      ));
    });
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentWeek = prefs.getInt('meditation_week') ?? 1;
      _currentDayCount = prefs.getInt('meditation_daycount') ?? 0;
      String? dateStr = prefs.getString('meditation_lastdate');
      if (dateStr != null) {
        _lastSessionDate = DateTime.tryParse(dateStr);
        final now = DateTime.now();
        _sessionCompletedToday = _lastSessionDate?.year == now.year &&
            _lastSessionDate?.month == now.month &&
            _lastSessionDate?.day == now.day;
      }
      _sessionDuration = weekDurations[_currentWeek]!;
      _phases = breathingPatterns[_currentWeek]!;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('meditation_week', _currentWeek);
    await prefs.setInt('meditation_daycount', _currentDayCount);
    await prefs.setString('meditation_lastdate', DateTime.now().toIso8601String());
  }

void _playIntroAndStartSession() async {
  if (_isButtonDisabled) return;

  setState(() {
    _isButtonDisabled = true;
    _isIntroPlaying = true;
  });

  if (!_isMuted) {
    await _voicePlayer.play(AssetSource('sound/intro_meditacion.mp3'));
  }

  await Future.delayed(Duration(seconds: 26)); // Ajusta según la duración real del intro

  setState(() {
    _isIntroPlaying = false;
    _showVideo = false; // ✅ Ahora sí ocultamos el video
  });

  _startSession();
}

  void _startSession() {
    setState(() {
      _sessionStarted = true;
      _elapsed = Duration.zero;
      _currentPhaseIndex = 0;
    });

    _elapsedTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (!_sessionStarted) return;
      setState(() => _elapsed += Duration(seconds: 1));
    });

    _sessionTimer = Timer(_sessionDuration, () async {
      _elapsedTimer?.cancel();
      if (!_sessionCompletedToday) {
        _currentDayCount++;
        if (_currentDayCount >= 7 && _currentWeek < 8) {
          _currentWeek++;
          _currentDayCount = 0;
        }
        await _saveProgress();
      }
      setState(() {
        _sessionStarted = false;
        _sessionCompletedToday = true;
        _isButtonDisabled = false;
      });
    });

    _runBreathingCycle();
  }

  void _runBreathingCycle() {
    final phase = _phases[_currentPhaseIndex];
    final file = _sanitizeLabel(phase.label);
    if (!_isMuted) {
      _voicePlayer.play(AssetSource('sound/$file.mp3'));
    }
    _breathingTimer = Timer(Duration(seconds: phase.seconds), () {
      if (!_sessionStarted) return;
      setState(() => _currentPhaseIndex = (_currentPhaseIndex + 1) % _phases.length);
      _runBreathingCycle();
    });
  }

  String _sanitizeLabel(String label) => label
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n');

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Círculo de respiración que pulsa
  Widget _buildBreathingCircle() {
   /* return AnimatedBuilder(
      animation: _pulseController!,
      builder: (_, __) {
        final scale = 1 + _pulseController!.value * 0.3;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            alignment: Alignment.center,
            child: Text(
              _phases[_currentPhaseIndex].label.toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );*/

     return Container(
    width: 160,
    height: 160,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white24,
    ),
    alignment: Alignment.center,
    child: Text(
      _phases[_currentPhaseIndex].label.toUpperCase(),
      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.black),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Video de fondo
              if (_showVideo && _videoController!.value.isInitialized)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                ),

              // Contenido principal
              Column(
                children: [
                  // Barra superior
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                          onPressed: () => setState(() => _isMuted = !_isMuted),
                        ),
                      ],
                    ),
                  ),

                  // Zona de sesión / botón
                  Expanded(
                    child: Center(
                      child: _sessionStarted
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildBreathingCircle(),
                                SizedBox(height: 24),
                                Text(_format(_elapsed), style: TextStyle(color: Colors.white70, fontSize: 32)),
                              ],
                            )
                          : SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Contenedor negro
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Semana $_currentWeek",
                                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Día ${_sessionCompletedToday ? _currentDayCount : _currentDayCount + 1} de 7",
                                          style: TextStyle(color: Colors.white70, fontSize: 16),
                                        ),
                                        SizedBox(height: 24),
                                        if (_isIntroPlaying)
                                          Text("Preparando meditación...", style: TextStyle(color: Colors.white70))
                                        else if (!_sessionCompletedToday)
                                          ElevatedButton(
                                            onPressed: _playIntroAndStartSession,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black,
                                              padding: EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                            ),
                                            child: Text("Iniciar meditación", style: TextStyle(fontSize: 18)),
                                          ),
                                        if (_sessionCompletedToday)
                                          TextButton(
                                            onPressed: _playIntroAndStartSession,
                                            child: Text("Repetir meditación", style: TextStyle(color: Colors.white70)),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Espacio extra
                                  SizedBox(height: 40),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _voicePlayer.dispose();
    _videoController?.dispose();
   // _pulseController?.dispose();
    _breathingTimer?.cancel();
    _sessionTimer?.cancel();
    _elapsedTimer?.cancel();
    super.dispose();
  }
}
