import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class RelaxAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  RelaxAudioHandler() {
    _player.playerStateStream.listen((state) {
      playbackState.add(
        PlaybackState(
          controls: [
            MediaControl.play,
            MediaControl.pause,
            MediaControl.stop,
          ],
          playing: _player.playing,
          processingState: AudioProcessingState.ready,
        ),
      );
    });
  }

  // Método público que tu widget puede llamar
  Future<void> playAudioUrl(String url) async {
    await _player.setUrl(url);
    await _player.setLoopMode(LoopMode.one); // loop infinito
    await _player.play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();
}
