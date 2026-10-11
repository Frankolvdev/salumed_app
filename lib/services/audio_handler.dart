import 'package:just_audio/just_audio.dart';

/// Reproductor auxiliar conservado por compatibilidad.
/// La pantalla de Audios relajantes usa su propio AudioPlayer.
/// No requiere audio_service ni inicializa un servicio Android.
class RelaxAudioHandler {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playAudioUrl(String url) async {
    await _player.setUrl(url);
    await _player.setLoopMode(LoopMode.one);
    await _player.play();
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}
