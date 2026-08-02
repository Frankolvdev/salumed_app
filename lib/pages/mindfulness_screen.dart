import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

class MindfulnessScreen extends StatefulWidget {
  @override
  _MindfulnessScreenState createState() => _MindfulnessScreenState();
}

class BreathingPhase {
  final String label;
  final int seconds;
  BreathingPhase(this.label, this.seconds);
}

class _MindfulnessScreenState extends State<MindfulnessScreen> with TickerProviderStateMixin {
  int _currentWeek = 1;
  int _currentDayCount = 0;
  DateTime? _lastSessionDate;
  bool _sessionStarted = false;
  bool _sessionCompletedToday = false;
  bool _isMuted = false;
  bool _isIntroPlaying = false;
  bool _showVideo = true;
  bool _isButtonDisabled = false; // ✅ NUEVO

  AudioPlayer _voicePlayer = AudioPlayer();
  VideoPlayerController? _videoController;
  AnimationController? _waveController;

  Timer? _breathingTimer;
  Timer? _sessionTimer;
  Timer? _elapsedTimer;

  int _currentPhaseIndex = 0;
  Duration _elapsed = Duration.zero;
  Duration _sessionDuration = Duration(minutes: 1);
  List<BreathingPhase> _phases = [];

  final Map<int, Duration> weekDurations = {
    1: Duration(minutes: 1),
    2: Duration(minutes: 3),
    3: Duration(minutes: 5),
    4: Duration(minutes: 10),
    5: Duration(minutes: 15),
    6: Duration(minutes: 20),
    7: Duration(minutes: 40),
    8: Duration(minutes: 60),
  };

  final Map<int, List<BreathingPhase>> breathingPatterns = {
    1: [BreathingPhase('inhala', 4), BreathingPhase('mantén', 2), BreathingPhase('exhala', 5)],
    2: [BreathingPhase('inhala', 4), BreathingPhase('mantén', 2), BreathingPhase('exhala', 5)],
    3: [BreathingPhase('inhala', 4), BreathingPhase('mantén', 2), BreathingPhase('exhala', 5)],
    4: [BreathingPhase('inhala', 4), BreathingPhase('mantén', 7), BreathingPhase('exhala', 8)],
    5: [BreathingPhase('inhala', 4), BreathingPhase('mantén', 7), BreathingPhase('exhala', 8)],
    6: [BreathingPhase('inhala', 4), BreathingPhase('mantén', 7), BreathingPhase('exhala', 8)],
    7: [BreathingPhase('inhala', 4), BreathingPhase('mantén', 7), BreathingPhase('exhala', 8)],
    8: [BreathingPhase('inhala', 4), BreathingPhase('mantén', 7), BreathingPhase('exhala', 8)],
  };


  @override
  void initState() {
    super.initState();
    _loadProgress();
    _waveController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
    _videoController = VideoPlayerController.asset('assets/video/mindfulness_bg.mp4')
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        _videoController!.play();
        setState(() {});
      });

      _showVolumeReminder(context); 
  }

  void _showVolumeReminder(BuildContext context) {
  Future.delayed(Duration(milliseconds: 400), () {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('🔊 Sube el volumen para escuchar los audios de respiración. Para una mejor experiencia, coloca tus audífonos y cierra los ojos. Esto te permitirá sumergirte completamente en la práctica de mindfulness.'),
      duration: Duration(seconds: 7),
    ));
  });
}





  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentWeek = prefs.getInt('mindfulness_week') ?? 1;
      _currentDayCount = prefs.getInt('mindfulness_daycount') ?? 0;
      String? dateStr = prefs.getString('mindfulness_lastdate');
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
    await prefs.setInt('mindfulness_week', _currentWeek);
    await prefs.setInt('mindfulness_daycount', _currentDayCount);
    await prefs.setString('mindfulness_lastdate', DateTime.now().toIso8601String());
  }

  void _playIntroAndStartSession() async {
    if (_isButtonDisabled) return; // ✅ NUEVO: evita múltiples clics

    setState(() {
      _isButtonDisabled = true; // ✅ Bloquea el botón
      _isIntroPlaying = true;
    });

    if (!_isMuted) await _voicePlayer.play(AssetSource('sound/intro.mp3'));
    await Future.delayed(Duration(seconds: 7));
    
    setState(() {
      _isIntroPlaying = false;
    });

    _startSession();
  }

  void _startSession() {
    setState(() {
      _sessionStarted = true;
      _elapsed = Duration.zero;
      _currentPhaseIndex = 0;
      _showVideo = false;
    });

    _elapsedTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (!_sessionStarted) return;
      setState(() {
        _elapsed += Duration(seconds: 1);
      });
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
        _isButtonDisabled = false; // ✅ Desbloquea el botón al terminar sesión
      });
    });

    _runBreathingCycle();
  }

  void _runBreathingCycle() {
    final phase = _phases[_currentPhaseIndex];
    if (!_isMuted) {
      _voicePlayer.play(AssetSource('sound/${_sanitizeLabel(phase.label)}.mp3'));
    }

    _breathingTimer = Timer(Duration(seconds: phase.seconds), () {
      if (!_sessionStarted) return;
      setState(() {
        _currentPhaseIndex = (_currentPhaseIndex + 1) % _phases.length;
      });
      _runBreathingCycle();
    });
  }

  String _sanitizeLabel(String label) {
    return label
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _voicePlayer.dispose();
    _videoController?.dispose();
    _waveController?.dispose();
    _breathingTimer?.cancel();
    _sessionTimer?.cancel();
    _elapsedTimer?.cancel();
    super.dispose();
  }

  Widget _buildBreathingCircle() {
 return Container(
    width: 180,
    height: 180,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.blueAccent.withOpacity(0.2),
    ),
    alignment: Alignment.center,
    child: Text(
      _phases[_currentPhaseIndex].label.toUpperCase(),
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
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
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                        onPressed: () => setState(() => _isMuted = !_isMuted),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 8),
                            color: Colors.black.withOpacity(0.6),
                            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                            child: Column(
                              children: [
                                Text(
                                  "Semana $_currentWeek",
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Día ${_sessionCompletedToday ? _currentDayCount : _currentDayCount + 1} de 7",
                                  style: TextStyle(fontSize: 16, color: Colors.white70),
                                ),
                                SizedBox(height: 24),

                                if (!_sessionCompletedToday)
                                  ElevatedButton(
                                    onPressed: _isButtonDisabled ? null : _playIntroAndStartSession, // ✅
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: Text("Comenzar práctica", style: TextStyle(fontSize: 18)),
                                  ),

                                if (_sessionCompletedToday && !_sessionStarted)
                                  TextButton(
                                    onPressed: _isButtonDisabled ? null : _playIntroAndStartSession, // ✅
                                    child: Text("Repetir sesión de hoy", style: TextStyle(color: Colors.white)),
                                  ),
                              ],
                            ),
                          ),
                          if (_sessionStarted)
                            Padding(
                              padding: const EdgeInsets.only(top: 60.0, bottom: 40.0),
                              child: Column(
                                children: [
                                  _buildBreathingCircle(),
                                  SizedBox(height: 40),
                                  Text(
                                    _formatDuration(_elapsed),
                                    style: TextStyle(color: Colors.white, fontSize: 26),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }
}
