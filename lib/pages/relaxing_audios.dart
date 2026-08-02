import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../services/audio_handler.dart';

class RelaxAudioView extends StatefulWidget {
  const RelaxAudioView({Key? key}) : super(key: key);

  @override
  State<RelaxAudioView> createState() => _RelaxAudioViewState();
}

class _RelaxAudioViewState extends State<RelaxAudioView> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String? _currentAudio;

  final List<Map<String, String>> audios = [
    {
      'name': 'Just Relax',
      'url': 'https://cdn.pixabay.com/download/audio/2021/11/23/audio_64b2dd1bce.mp3?filename=just-relax-11157.mp3'
    },
    {
      'name': 'Please Calm My Mind',
      'url': 'https://cdn.pixabay.com/download/audio/2022/11/11/audio_84306ee149.mp3?filename=please-calm-my-mind-125566.mp3'
    },
    {
      'name': 'Epic Relaxing Flute Music',
      'url': 'https://cdn.pixabay.com/download/audio/2023/03/26/audio_1d5c4319b7.mp3?filename=epic-relaxing-flute-music-144009.mp3'
    },

      {
      'name': 'Zen Spiritual Yoga Massage',
      'url': 'https://cdn.pixabay.com/download/audio/2022/02/07/audio_f72e59e453.mp3?filename=zen-spiritual-yoga-massage-meditation-spa-relax-ambient-music-18403.mp3'
    },
       {
      'name': 'Muzyka Medytacyjna',
      'url': 'https://cdn.pixabay.com/download/audio/2022/02/28/audio_e07f655a62.mp3?filename=muzyka-medytacyjna-21784.mp3'
    },
       {
      'name': '528Hz Frequency Ambient',
      'url': 'https://cdn.pixabay.com/download/audio/2024/09/02/audio_7da247642d.mp3?filename=528hz-frequency-ambient-music-meditationcalmingzenspiritual-music-237575.mp3'
    },
       {
      'name': 'Relaxing Music With Flute',
      'url': 'https://cdn.pixabay.com/download/audio/2023/03/26/audio_cbfb63de8f.mp3?filename=relaxing-music-with-flute-144016.mp3'
    },
       {
      'name': 'Inspiring meditation',
      'url': 'https://cdn.pixabay.com/download/audio/2024/07/20/audio_522474e034.mp3?filename=inspiring-meditation-225815.mp3'
    },
       {
      'name': 'Calming Sounds',
      'url': 'https://cdn.pixabay.com/download/audio/2022/10/26/audio_b6c2c0b4c3.mp3?filename=calming-sounds-124055.mp3'
    },
       {
      'name': '741Hz Frequency Ambient',
      'url': 'https://cdn.pixabay.com/download/audio/2024/09/03/audio_c7390b6b79.mp3?filename=741hz-frequency-ambient-music-meditationcalmingzenspiritual-music-237772.mp3'
    }
  ];




late RelaxAudioHandler _audioHandler;
@override
void initState() {
  super.initState();
  _audioHandler = RelaxAudioHandler();
}
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url, String name) async {
    try {
      await _player.setUrl(url);
      await _player.setLoopMode(LoopMode.one); // loop infinito
      _player.play();
      setState(() {
        _isPlaying = true;
        _currentAudio = name;
      });
      _saveListeningData(name);
    } catch (e) {
      print('Error al reproducir audio: $e');
    }
  }

  Future<void> _pauseAudio() async {
    await _player.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _stopAudio() async {
    await _player.stop();
    setState(() {
      _isPlaying = false;
      _currentAudio = null;
    });
  }

  Future<void> _saveListeningData(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await prefs.setString('last_audio', name);
    await prefs.setString('last_audio_time', now);
    print('Guardado: $name a las $now');
  }

  Widget _buildAudioItem(Map<String, String> audio) {
    final isSelected = audio['name'] == _currentAudio;
    return GestureDetector(
      onTap: () => _playAudio(audio['url']!, audio['name']!),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [Colors.blue, Colors.teal])
              : LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade100]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(isSelected && _isPlaying ? Icons.pause_circle : Icons.play_circle, size: 40, color: isSelected ? Colors.white : Colors.black54),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                audio['name']!,
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isSelected && _isPlaying)
              IconButton(
                icon: Icon(Icons.stop, color: Colors.white),
                onPressed: _stopAudio,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audios de Relajación'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: audios.length,
              itemBuilder: (_, index) => _buildAudioItem(audios[index]),
            ),
          ),
          if (_currentAudio != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.teal.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Text('Reproduciendo: $_currentAudio', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: _isPlaying ? _pauseAudio : () => _playAudio(audios.firstWhere((a) => a['name'] == _currentAudio)['url']!, _currentAudio!),
                  ),
                  IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: _stopAudio,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
