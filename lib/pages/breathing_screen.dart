import 'dart:convert';
import 'package:app/pages/breathing_practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class BreathingType {
  final String name;
  final String pattern;
  final int inhale;
  final int hold;
  final int exhale;

  BreathingType(this.name, this.pattern, this.inhale, this.hold, this.exhale);
}

class BreathingScreen extends StatefulWidget {
  @override
  _BreathingScreenState createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _history = [];
  late VideoPlayerController _videoController;

  final List<BreathingType> _types = [
    BreathingType("Tranquilidad", "4-7-8", 4, 7, 8),
    BreathingType("Alivio del Estrés", "5-5-5", 5, 5, 5),
    BreathingType("Energética", "6-2-6", 6, 2, 6),
    BreathingType("Relajación Profunda", "4-8-8", 4, 8, 8),
    BreathingType("Concentración", "5-3-7", 5, 3, 7),
    BreathingType("Sueño", "4-4-8", 4, 4, 8),
    BreathingType("Alerta", "3-3-3", 3, 3, 3),
    BreathingType("Equilibrio", "6-4-6", 6, 4, 6),
    BreathingType("Creatividad", "5-4-7", 5, 4, 7),
    BreathingType("Calma interior", "4-5-6", 4, 5, 6),
    BreathingType("Anti ansiedad", "4-6-6", 4, 6, 6),
    BreathingType("Motivación", "6-3-6", 6, 3, 6),
    BreathingType("Positividad", "5-6-5", 5, 6, 5),
    BreathingType("Desbloqueo", "7-3-7", 7, 3, 7),
    BreathingType("Recuperación", "4-4-4", 4, 4, 4),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();

    _videoController = VideoPlayerController.asset("assets/video/diagram_4_7_8.mp4")
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0.0);
        _videoController.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('breathing_history');
    if (data != null) {
      setState(() {
      _history = List<Map<String, dynamic>>.from(jsonDecode(data)).reversed.toList(); // ← invierte orden
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('breathing_history', jsonEncode(_history));
  }

  void _startBreathing(BreathingType type) async {
    final startTime = DateTime.now();



    final duration = await Navigator.push(
      context,
      MaterialPageRoute(
       builder: (_) => BreathingPracticeScreen(
  data: {
    'name': type.name,
    'pattern': type.pattern,
    'inhale': type.inhale,
    'hold': type.hold,
    'exhale': type.exhale,
  },
  onCompleted: (seconds) async{
    _history.add({
      'type': type.name,
      'pattern': type.pattern,
      'duration': "$seconds segundos",
      'timestamp': startTime.toIso8601String(),
    });

    _saveHistory(); 

  
  },
),
      ),
    );

    await _loadHistory();

  }


  Widget _buildExploreTab() {
    return ListView.builder(
      itemCount: _types.length,
      itemBuilder: (_, index) {
        final type = _types[index];
        return Card(
          color: Colors.black.withOpacity(0.6),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(type.name, style: TextStyle(color: Colors.white, fontSize: 18)),
            subtitle: Text("Patrón: ${type.pattern}", style: TextStyle(color: Colors.white70)),
            trailing: Icon(Icons.play_arrow, color: Colors.white),
            onTap: () => _startBreathing(type),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return Center(
        child: Text("Sin historial aún.", style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (_, index) {
        final item = _history[index];
        return ListTile(
          title: Text(item['type'], style: TextStyle(color: Colors.white)),
          subtitle: Text("${item['pattern']} - ${item['duration']}", style: TextStyle(color: Colors.white70)),
          trailing: Text(
            DateTime.parse(item['timestamp']).toLocal().toString().split('.')[0],
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_videoController.value.isInitialized)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            ),
          ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.7),
            title: Text("Respiración", style: TextStyle(color: Colors.white)),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: "Explorar"),
                Tab(text: "Historial"),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildExploreTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }
}
