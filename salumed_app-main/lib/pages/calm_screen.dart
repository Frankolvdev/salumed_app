import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalmScreen extends StatefulWidget {
  const CalmScreen({Key? key}) : super(key: key);

  @override
  State<CalmScreen> createState() => _CalmScreenState();
}

class _CalmScreenState extends State<CalmScreen> {
  late VideoPlayerController _videoController;
  late AudioPlayer _beachAudioPlayer;
  late AudioPlayer _ttsAudioPlayer;

  // Variables estáticas internas
  static const double _beachSoundVolumeInitial = 0.3;
  static const double _ttsVolumeInitial = 0.7;

  static const String _videoAsset = 'assets/video/playa.mp4';
  static const String _beachSoundAsset = 'sound/playa_ambient.mp3';
  static const String _ttsSoundAsset = 'sound/playa.mp3';

  bool _ttsFinished = false;

  // Variables para rastrear tiempo
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [], // Oculta todas las barras (status bar y navbar)
    );
    // Guardar timestamp de inicio
    _startTime = DateTime.now();
    _saveStartTime();

    _videoController = VideoPlayerController.asset(_videoAsset)
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0.0);
        _videoController.play();
        setState(() {});
      });

    _beachAudioPlayer = AudioPlayer();
    _ttsAudioPlayer = AudioPlayer();

    _playBeachSound();
    _playTTS();

    _ttsAudioPlayer.onPlayerComplete.listen((event) {
      if (!_ttsFinished) {
        _ttsFinished = true;
        double newVol = (_beachSoundVolumeInitial + 0.2).clamp(0.0, 1.0);
        _beachAudioPlayer.setVolume(newVol);
      }
    });

    _showVolumeReminder(context);
  }

  // Guardar timestamp de inicio
  Future<void> _saveStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calm_last_used', _startTime!.toIso8601String());
  }

  // Guardar duración de la sesión
  Future<void> _saveDuration() async {
    if (_startTime != null) {
      final duration = DateTime.now().difference(_startTime!).inSeconds;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('calm_duration', duration);
    }
  }

  void _showVolumeReminder(BuildContext context) {
    Future.delayed(Duration(milliseconds: 400), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🔊 Sube el volumen para escuchar los audios. Para una mejor experiencia, coloca tus audífonos.'),
        duration: Duration(seconds: 5),
      ));
    });
  }

  Future<void> _playBeachSound() async {
    await _beachAudioPlayer.setReleaseMode(ReleaseMode.loop);
    await _beachAudioPlayer.setVolume(_beachSoundVolumeInitial);
    await _beachAudioPlayer.play(AssetSource(_beachSoundAsset));
  }

  Future<void> _playTTS() async {
    await _ttsAudioPlayer.setVolume(_ttsVolumeInitial);
    await _ttsAudioPlayer.play(AssetSource(_ttsSoundAsset));
  }

  @override
  void dispose() {
    // Guardar duración antes de liberar recursos
    _saveDuration();

    _videoController.dispose();
    _beachAudioPlayer.dispose();
    _ttsAudioPlayer.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge, // Vuelve a mostrar barras
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _videoController.value.isInitialized
          ? Stack(
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}