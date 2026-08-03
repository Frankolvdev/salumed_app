import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SerenityScreen extends StatefulWidget {
  const SerenityScreen({Key? key}) : super(key: key);

  @override
  State<SerenityScreen> createState() => _SerenityScreenState();
}

class _SerenityScreenState extends State<SerenityScreen> {
  late VideoPlayerController _videoController;
  late AudioPlayer _beachAudioPlayer;
  late AudioPlayer _ttsAudioPlayer;

  // Variables estáticas internas
  static const double _beachSoundVolumeInitial = 1;
  static const double _ttsVolumeInitial = 0.8;

  static const String _videoAsset = 'assets/video/serenity.mp4';
  static const String _beachSoundAsset = 'sound/serenity_ambient.mp3';
  static const String _ttsSoundAsset = 'sound/serenity.mp3';

  bool _ttsFinished = false;

  // Controlador para el campo de texto
  final TextEditingController _thoughtsController = TextEditingController();

  // Variables para rastrear tiempo
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [], // Oculta barras status y navegación
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
    await prefs.setString('serenity_last_used', _startTime!.toIso8601String());
  }

  // Guardar duración de la sesión
  Future<void> _saveDuration() async {
    if (_startTime != null) {
      final duration = DateTime.now().difference(_startTime!).inSeconds;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('serenity_duration', duration);
    }
  }

  // Guardar el último pensamiento
  Future<void> _saveThought() async {
    final thought = _thoughtsController.text.trim();
    if (thought.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('serenity_last_thought', thought);
    }
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

  void _showVolumeReminder(BuildContext context) {
    Future.delayed(Duration(milliseconds: 400), () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🔊 Sube el volumen para escuchar los audios. Para una mejor experiencia, coloca tus audífonos.'),
        duration: Duration(seconds: 5),
      ));
    });
  }

  @override
  void dispose() {
    // Guardar duración y pensamiento antes de liberar recursos
    _saveDuration();
    _saveThought();

    _videoController.dispose();
    _beachAudioPlayer.dispose();
    _ttsAudioPlayer.dispose();
    _thoughtsController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge, // Restaura barras
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

                // Campo de texto semi-transparente centrado
                SafeArea(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 400,
                          maxHeight: 300,
                        ),
                        child: Scrollbar(
                          radius: const Radius.circular(10),
                          thickness: 6,
                          thumbVisibility: true,
                          child: TextField(
                            controller: _thoughtsController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Escribe tus pensamientos aquí...',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}