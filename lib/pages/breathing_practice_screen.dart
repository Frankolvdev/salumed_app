import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BreathingPracticeScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(int seconds) onCompleted;

  BreathingPracticeScreen({required this.data, required this.onCompleted});

  @override
  _BreathingPracticeScreenState createState() => _BreathingPracticeScreenState();
}

class BreathingPhase {
  final String label;
  final int duration;
  BreathingPhase(this.label, this.duration);
}

class _BreathingPracticeScreenState extends State<BreathingPracticeScreen>
    with TickerProviderStateMixin {
  List<BreathingPhase> phases = [];
  int currentPhase = 0;
  int elapsedSeconds = 0;
  Timer? _timer;
  Timer? _elapsedTimer;

  bool _isMuted = false;
  late AnimationController _circleController;
  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    phases = [
      BreathingPhase("Inhala", widget.data['inhale']),
      BreathingPhase("Mantén", widget.data['hold']),
      BreathingPhase("Exhala", widget.data['exhale']),
    ];

    _circleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _startBreathingCycle();
    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() => elapsedSeconds++);
    });
  }

  void _startBreathingCycle() {
    _playAudioForPhase(phases[currentPhase].label);
    _timer = Timer(Duration(seconds: phases[currentPhase].duration), () {
      setState(() {
        currentPhase = (currentPhase + 1) % phases.length;
      });
      _startBreathingCycle();
    });
  }

  void _playAudioForPhase(String phase) {
    if (_isMuted) return;

    final sanitized = phase.toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e');
    _audioPlayer.play(AssetSource('sound/${sanitized}.mp3'));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _elapsedTimer?.cancel();
    _circleController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final current = phases[currentPhase];
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () {
                        widget.onCompleted(elapsedSeconds);
                        Navigator.pop(context);
                      },
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                      onPressed: () {
                        setState(() => _isMuted = !_isMuted);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                widget.data['name'],
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              Center(child: _buildBreathingCircle(current.label)),
              SizedBox(height: 50),
              Text(
                _formatTime(elapsedSeconds),
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
              Spacer(),
              Text(
                "Presiona ↩ para terminar",
                style: TextStyle(color: Colors.white54),
              ),
              SizedBox(height: 20),
            ],
          )
        ]),
      ),
    );
  }

  Widget _buildBreathingCircle(String label) {
   /* return AnimatedBuilder(
      animation: _circleController,
      builder: (_, child) {
        double scale = 1 + (_circleController.value * 0.4);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white12,
            ),
            alignment: Alignment.center,
            child: Text(
              label.toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
      color: Colors.white12, // Puedes cambiar el color si lo deseas
    ),
    alignment: Alignment.center,
    child: Text(
      label.toUpperCase(),
      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
    ),
  );
  }
}
