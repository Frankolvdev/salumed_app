// lib/screens/gym_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({Key? key}) : super(key: key);
  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> with TickerProviderStateMixin {
  late SharedPreferences _prefs;
  // ahora cargamos internamente desde assets/json/routines.json
  Map<String, dynamic>? _allRoutines;
  String? _selectedType; // 'gym' | 'home' | 'calisthenics'
  String? _selectedLevel; // 'beginner' | 'intermediate' | 'advanced'
  bool _showMenus = false;
  bool _initialized = false;
  Map<String, dynamic>? _currentRoutine;
  List<String> _dayKeys = [];
  int _currentDayIndex = 0;
  int _currentWeek = 1;
  // Estado de ejercicios guardado: 'd{dayIndex}_e{exerciseIndex}' -> { 'weight': '2.5' | null, 'done': true|false }
  Map<String, dynamic> _dayState = {};
  // Controllers por ejercicio
  final Map<String, TextEditingController> _controllers = {};
  final Set<String> _listenerAttached = {};
  final Set<String> _controllerUpdating = {};
  late AnimationController _levelAnimController;
  // Regex que valida números enteros o decimales con punto (ej. 2, 2.5, 12.0)
  final RegExp _weightReg = RegExp(r'^\d+(\.\d+)?$');

  @override
  void initState() {
    super.initState();
    _levelAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _init();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _levelAnimController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    // Cargar rutinas desde assets
    await _loadRoutinesFromAssets();
    _prefs = await SharedPreferences.getInstance();
    String? prefType = _prefs.getString('training_type');
    if (prefType == null) {
      _selectedType = 'gym';
      await _prefs.setString('training_type', _selectedType!);
    } else {
      _selectedType = prefType;
    }
    _selectedLevel = _prefs.getString('training_level');
    // Configurar menús
    if (_allRoutines != null) {
      if (_selectedType != null && _selectedLevel != null) {
        await _loadRoutine(_selectedType!, _selectedLevel!,
            autoShowModal: true);
        _showMenus = false;
      } else {
        _showMenus = true;
      }
    } else {
      _showMenus = true;
    }
    _initialized = true;
    setState(() {});
    if (_showMenus && _selectedType != null) {
      _levelAnimController.forward(from: 0);
    }
  }

  Future<void> _loadRoutinesFromAssets() async {
    try {
      final raw = await rootBundle.loadString('assets/json/routines.json');
      final parsed = jsonDecode(raw);
      if (parsed is Map<String, dynamic>) {
        _allRoutines = parsed;
      } else {
        _allRoutines = null;
      }
    } catch (e) {
      _allRoutines = null;
      // opcional: print('Error cargando routines.json: $e');
    }
  }

  void _resetSelectionMenus() {
    setState(() {
      _showMenus = true;
    });
    if (_selectedType != null) {
      _levelAnimController.forward(from: 0);
    }
  }

  Future<void> _loadRoutine(String type, String level,
      {bool autoShowModal = false}) async {
    // usar _allRoutines en lugar de widget.routines
    if (_allRoutines == null) return;
    final dataForType = _allRoutines![type];
    if (dataForType == null) return;
    final lvl = dataForType[level];
    if (lvl == null) return;
    _selectedType = type;
    _selectedLevel = level;
    _currentRoutine = Map<String, dynamic>.from(lvl);
    // obtener y ordenar keys day1, day2...
    _dayKeys = _currentRoutine!.keys
        .where((k) => k.toLowerCase().startsWith('day'))
        .toList();
    _dayKeys.sort((a, b) {
      final ai = int.tryParse(a.replaceAll(RegExp('[^0-9]'), '')) ?? 0;
      final bi = int.tryParse(b.replaceAll(RegExp('[^0-9]'), '')) ?? 0;
      return ai.compareTo(bi);
    });
    // cargar progreso guardado
    final dayIndex =
        _prefs.getInt('${_selectedType}_${_selectedLevel}_current_day') ?? 0;
    final week =
        _prefs.getInt('${_selectedType}_${_selectedLevel}_current_week') ?? 1;
    _currentDayIndex = (dayIndex < _dayKeys.length) ? dayIndex : 0;
    _currentWeek = week;
    final progressStr =
        _prefs.getString('progress_${_selectedType}_${_selectedLevel}');
    if (progressStr != null) {
      try {
        _dayState = Map<String, dynamic>.from(jsonDecode(progressStr));
      } catch (_) {
        _dayState = {};
      }
    } else {
      _dayState = {};
    }
    // inicializar controllers para el día actual
    _initControllersForCurrentDay();
    setState(() {});
    // mostrar modal la primera vez para esta combinación
    final shownKey = 'details_shown_${_selectedType}_${_selectedLevel}';
    final alreadyShown = _prefs.getBool(shownKey) ?? false;
    if (autoShowModal && !alreadyShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRoutineDetailsModal();
        _prefs.setBool(shownKey, true);
      });
    }
  }

  void _initControllersForCurrentDay() {
    final current = _getCurrentDayExercises();
    final list = current['list'] as List<dynamic>;
    final keepKeys = <String>{};
    for (var i = 0; i < list.length; i++) {
      final key = 'd${_currentDayIndex}_e${i}';
      keepKeys.add(key);
      final existingState = _dayState[key];
      final initial = existingState == null
          ? ''
          : (existingState['weight']?.toString() ?? '');
      if (_controllers.containsKey(key)) {
        final ctrl = _controllers[key]!;
        if (ctrl.text != initial) ctrl.text = initial;
      } else {
        final ctrl = TextEditingController(text: initial);
        // añadir listener ahora (cuando se crea el controller)
        ctrl.addListener(() {
          if (_controllerUpdating.contains(key)) return;
          final raw = ctrl.text;
          final sanitized = _sanitizeWeightInput(raw);
          if (raw != sanitized) {
            _controllerUpdating.add(key);
            final sel = TextSelection.collapsed(offset: sanitized.length);
            ctrl.value = TextEditingValue(text: sanitized, selection: sel);
            _controllerUpdating.remove(key);
          }
          if (sanitized.isEmpty) {
            _dayState[key] = {'weight': ''};
          } else if (_weightReg.hasMatch(sanitized)) {
            _dayState[key] = {'weight': sanitized};
          }
          // guardado parcial
          _prefs.setString('progress_${_selectedType}_${_selectedLevel}',
              jsonEncode(_dayState));
          // actualizar UI
          if (mounted) setState(() {});
        });
        _controllers[key] = ctrl;
        _listenerAttached.add(key);
      }
    }
    // eliminar controllers que ya no pertenecen al día actual
    final toRemove = <String>[];
    for (final k in _controllers.keys) {
      if (!keepKeys.contains(k)) toRemove.add(k);
    }
    for (final k in toRemove) {
      _controllers[k]?.dispose();
      _controllers.remove(k);
      _listenerAttached.remove(k);
    }
  }

  // selecciona tipo y guarda
  Future<void> _selectType(String type) async {
    final oldType = _selectedType;
    _selectedType = type;
    await _prefs.setString('training_type', type);
    if (oldType != type) {
      _selectedLevel = null;
      await _prefs.remove('training_level');
    }
    setState(() {});
    _levelAnimController.forward(from: 0);
  }

  Future<void> _selectLevel(String level) async {
    if (_selectedType == null) return;
    _selectedLevel = level;
    await _prefs.setString('training_level', level);
    await _loadRoutine(_selectedType!, _selectedLevel!, autoShowModal: true);
    setState(() {
      _showMenus = false;
    });
  }

  Map<String, dynamic> _getCurrentDayExercises() {
    if (_currentRoutine == null || _dayKeys.isEmpty) return {};
    final key = _dayKeys[_currentDayIndex];
    final list = _currentRoutine![key] as List<dynamic>?;
    return {'key': key, 'list': list ?? []};
  }

  String _titleForCurrent() {
    final dayNumber = (_currentDayIndex + 1).toString().padLeft(2, '0');
    return 'Semana ${_currentWeek.toString().padLeft(2, '0')} Día $dayNumber';
  }

  // InputFormatter que evita múltiples puntos y caracteres inválidos
  static TextInputFormatter weightInputFormatter() =>
      SingleDotDecimalFormatter();

  String _sanitizeWeightInput(String raw) {
    final filtered = raw.replaceAll(RegExp('[^0-9\\.]'), '');
    if (filtered.split('.').length > 2) {
      final parts = filtered.split('.');
      final first = parts.first;
      final rest = parts.sublist(1).join('');
      return '$first.$rest';
    }
    if (filtered.startsWith('.')) return '0$filtered';
    return filtered;
  }

  bool _isDayComplete() {
    final current = _getCurrentDayExercises();
    final list = current['list'] as List<dynamic>;
    for (var i = 0; i < list.length; i++) {
      final ex = list[i] as Map<String, dynamic>;
      final key = 'd${_currentDayIndex}_e${i}';
      final type = (ex['type'] ?? 'input').toString().toLowerCase();
      final state = _dayState[key];
      if (type == 'check') {
        if (state == null || state['done'] != true) return false;
      } else {
        final val = _controllers[key]?.text ??
            (state == null ? null : state['weight']?.toString());
        if (val == null || val.isEmpty || !_weightReg.hasMatch(val))
          return false;
      }
    }
    return true;
  }

  Future<void> _saveDayProgressAndAdvance() async {
    if (!_isDayComplete()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Completa todos los ejercicios antes de avanzar.'),
        ));
      }
      return;
    }
    // guardar estado actual
    final progressKey = 'progress_${_selectedType}_${_selectedLevel}';
    await _prefs.setString(progressKey, jsonEncode(_dayState));
    // avanzar día/semana
    int nextDayIndex = _currentDayIndex + 1;
    int nextWeek = _currentWeek;
    if (nextDayIndex >= _dayKeys.length) {
      nextWeek += 1;
      nextDayIndex = 0;
    }
    _currentDayIndex = nextDayIndex;
    _currentWeek = nextWeek;
    await _prefs.setInt(
        '${_selectedType}_${_selectedLevel}_current_day', _currentDayIndex);
    await _prefs.setInt(
        '${_selectedType}_${_selectedLevel}_current_week', _currentWeek);
    // re-inicializar controllers para nuevo día
    _initControllersForCurrentDay();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Progreso guardado. Avanzando al siguiente día.'),
      ));
    }
  }

  // actualizar peso o check
  Future<void> _updateExerciseState(int exIndex, String? weight, bool? done) async {
    final key = 'd${_currentDayIndex}_e${exIndex}';
    if (!_dayState.containsKey(key)) _dayState[key] = {};
    if (weight != null) _dayState[key]['weight'] = weight;
    if (done != null) _dayState[key]['done'] = done;
    // sincronizar controller si corresponde
    if (weight != null && _controllers.containsKey(key)) {
      final ctrl = _controllers[key]!;
      if (ctrl.text != weight) {
        _controllerUpdating.add(key);
        ctrl.text = weight;
        _controllerUpdating.remove(key);
      }
    }
    await _prefs.setString(
        'progress_${_selectedType}_${_selectedLevel}', jsonEncode(_dayState));
    if (mounted) setState(() {});
  }

  void _showRoutineDetailsModal() {
    if (_currentRoutine == null) return;
    final details =
        Map<String, dynamic>.from(_currentRoutine!['details'] ?? {});
    // proveer defaults si faltan (según tipo)
    final defaults = _defaultsForType(_selectedType ?? 'gym');
    for (final k in defaults.keys) {
      if (!details.containsKey(k) ||
          details[k] == null ||
          details[k].toString().isEmpty) {
        details[k] = defaults[k];
      }
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Detalles de la rutina - ${_niceTypeName(_selectedType)}',
            style: const TextStyle( fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in details.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${_niceKeyName(entry.key)}:',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 5,
                          child: Text(
                            '${entry.value}',
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cerrar', style: TextStyle(fontSize: 16)),
            )
          ],
        );
      },
    );
  }

  Map<String, String> _defaultsForType(String type) {
    switch (type) {
      case 'calisthenics':
        return {
          'duration': '45–60 min',
          'rest': '45–90 s entre ejercicios',
          'frequency': '5 días/semana',
          'material':
              'barra baja, escalón o banco, barra fija o TRX y banda elástica ligera.',
          'tempo': '2-1-2',
          'objective': 'progresar en carga y volumen de forma controlada.'
        };
      case 'home':
        return {
          'duration': '60–75 min',
          'frequency': '5 días/semana',
          'rest': '45–90 s entre ejercicios',
          'objective':
              'mejorar fuerza total, resistencia muscular y definición',
          'material':
              '2 botellas de agua (1–1.5 L), 1 kilo de arroz o azúcar, Mochila ligera con libros, Silla firme, Tapete o alfombra'
        };
      case 'gym':
      default:
        return {
          'structure': 'Push / Pull / Legs / Hombro-Core / Full Body',
          'rest': '60–90 s entre series',
          'tempo': '2-1-2',
          'duration': '50-60 min por sesión'
        };
    }
  }

  String _niceTypeName(String? t) {
    switch (t) {
      case 'calisthenics':
        return 'Calistenia';
      case 'home':
        return 'Entrenamiento en casa';
      case 'gym':
      default:
        return 'Gym';
    }
  }

  String _niceLevelName(String? l) {
    switch (l) {
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      default:
        return '';
    }
  }

  String _niceKeyName(String k) {
    switch (k) {
      case 'duration':
        return 'Duración';
      case 'rest':
        return 'Descanso';
      case 'frequency':
        return 'Frecuencia';
      case 'material':
        return 'Material';
      case 'tempo':
        return 'Tempo';
      case 'objective':
        return 'Objetivo';
      case 'structure':
        return 'Estructura';
      default:
        return _capitalize(k);
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {

        SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    if (!_initialized) return const Center(child: CircularProgressIndicator());
    // si no se pudo cargar el JSON, mostrar mensaje con opción de reintentar
    if (_allRoutines == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/gym_background2.png'), // Ruta de la imagen en assets
              fit:
                  BoxFit.cover, // Ajusta la imagen para cubrir toda la pantalla
            ),
          ),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Error cargando assets/json/routines.json'),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: () async {
                    await _loadRoutinesFromAssets();
                    if (_allRoutines != null) {
                      // reiniciar flujo
                      _init();
                    } else {
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Sigue sin cargarse el JSON. Revisa assets y pubspec.yaml.')));
                    }
                  },
                  child: const Text('Reintentar'))
            ]),
          ),
        ),
      );
    }
    return Scaffold(
   
      body: Container(
        decoration:  BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              _showMenus? 'assets/images/gym_background.png' : 'assets/images/gym_background2.png'), // Ruta de la imagen en assets
            fit: BoxFit.cover, // Ajusta la imagen para cubrir toda la pantalla
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _showMenus
              ? Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTypeMenu(),
                          const SizedBox(height: 24),
                          SizeTransition(
                            sizeFactor: CurvedAnimation(
                                parent: _levelAnimController,
                                curve: Curves.easeInOut),
                            axisAlignment: -1.0,
                            child: _selectedType != null
                                ? _buildLevelMenu()
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Expanded(child: _buildRoutineView()),
        ),
      ),
    );
  }

  Widget _buildTypeMenu() {
    return Hero(
      tag: 'ponteenforma_hero',
      child: Material(
        color: Colors.transparent,
        child: Column(
          key: const ValueKey('type_menu'),
          children: [
 
            const SizedBox(height: 24),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              alignment: WrapAlignment.center,
              children: [
                _typeButton('gym', 'Entrena en Gym', Icons.fitness_center),
                _typeButton('home', 'Entrena en Casa', Icons.home_work),
                _typeButton(
                    'calisthenics', 'Con Calistenia', Icons.self_improvement),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _typeButton(String type, String label, IconData icon) {
    final active = _selectedType == type;
    return ElevatedButton.icon(
      onPressed: () => _selectType(type),
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? Color.fromARGB(255, 210, 87, 16): Color.fromARGB(179, 0, 0, 0),
        foregroundColor: active ? Colors.white : Color.fromARGB(255, 210, 87, 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: active ? 4 : 2,
        minimumSize: Size(MediaQuery.of(context).size.width * .70, 60),
      ),
    );
  }

  Widget _buildLevelMenu() {
    return Center(
      child: Container(
        key: const ValueKey('level_menu'),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color.fromARGB(96, 0, 0, 0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Selecciona tu nivel',
              style: TextStyle(fontSize: 20, color:Color.fromARGB(255, 210, 87, 16), fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.center,
              children: [
                _levelButton('beginner', 'Principiante'),
                _levelButton('intermediate', 'Intermedio'),
                _levelButton('advanced', 'Avanzado'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _levelButton(String levelKey, String label){
    final active = _selectedLevel == levelKey;
    return ElevatedButton(
      onPressed: () => _selectLevel(levelKey),
      child: Text(label, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? Color.fromARGB(255, 210, 87, 16): Colors.white,
        foregroundColor: active ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: active ? 4 : 1,
      ),
    );
  }

  Widget _buildRoutineView() {
    final current = _getCurrentDayExercises();
    final list = current['list'] as List<dynamic>;
    return Column(

      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
      SizedBox(height: 85,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
         Text(
   _titleForCurrent(),
   style:
       const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
 )
        
          ],
        ),

          //   IconButton(
          //   icon: const Icon(Icons.settings_backup_restore, color: Colors.orange,),
          //   tooltip: 'Cambiar rutina',
          //   onPressed: _resetSelectionMenus,
          // ),
          SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '${_niceTypeName(_selectedType)} • ${_niceLevelName(_selectedLevel)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _showRoutineDetailsModal,
                  icon: const Icon(Icons.info_outline, size: 28, color: Colors.white,),
                  tooltip: 'Detalles de la rutina',
                ),
                 IconButton(
            icon: const Icon(Icons.settings_backup_restore, color: Colors.orange,),
            tooltip: 'Cambiar rutina',
             onPressed: _resetSelectionMenus,
           )
              ],
            ),
     
        Expanded(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final ex = Map<String, dynamic>.from(list[index]);
              return _buildExerciseRow(ex, index);
            },
          ),
        ),
        const SizedBox(height: 16),
      
  SizedBox(
  width: 200,
  child: ElevatedButton(
    onPressed: _isDayComplete() ? _saveDayProgressAndAdvance : (){
          showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text("Completa los ejercicios"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
    },
    child: const Text(
      'Guardar y avanzar',
      style: TextStyle(
        fontSize: 17,
        color: Colors.white, // Color del texto blanco
      ),
      textAlign: TextAlign.center, // Centra el texto
    ),
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Color.fromARGB(255, 210, 87, 16), // Color de fondo habilitado (#AD4F11)
      disabledBackgroundColor: Color.fromARGB(255, 210, 87, 16), // Color de fondo deshabilitado (#AD4F11)
      foregroundColor: Colors.white, // Color del texto y otros elementos interactivos
    ),
  ),
)
      ],
    );
  }

  Widget _buildExerciseRow(Map<String, dynamic> ex, int index) {
    final name = ex['exercise'] ?? '';
    final observations = ex['observations'] ?? '';
    final series = ex['series'] ?? '';
    final reps = ex['reps'] ?? '';
    final type = (ex['type'] ?? 'input').toString().toLowerCase();
    final key = 'd${_currentDayIndex}_e${index}';
    final state = _dayState.containsKey(key) ? _dayState[key] : null;
    final curWeight = state == null ? '' : (state['weight']?.toString() ?? '');
    final curDone = state == null ? false : (state['done'] == true);
    // obtener controller o crear temporal (no attach listener aquí)
    final controller = _controllers.containsKey(key)
        ? _controllers[key]!
        : TextEditingController(text: curWeight);
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: "${index + 1}. ",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30, // Tamaño más grande para el número
        ),
      ),
      TextSpan(
        text: name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18, // Tamaño original para el nombre
        ),
      ),
    ],
  ),
),
                  const SizedBox(height: 8),
                  Text(
                    observations,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white, height: 1.4),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$series series • $reps',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  if (type == 'check')
                    Checkbox(
                      value: curDone,
                      onChanged: (v) => _updateExerciseState(index, null, v),
                   
                    )
                  else
                    SizedBox(
                      width: 140,
                      child: TextFormField(
                        
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [weightInputFormatter()],
                        style: const TextStyle(
                         
                          color: Colors
                              .black, // Color del texto ingresado por el usuario
                          fontSize:
                              16, // Opcional: ajusta el tamaño si es necesario
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: const TextStyle(color: Color.fromARGB(255, 205, 205, 205)),
                          hintText: 'kg',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                          enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color.fromARGB(255, 255, 255, 255)), // Color del borde cuando no está enfocado
    ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 255, 255, 255),
                                width: 2),
                          ),
                        ),
                        onChanged: (raw) {
                          final sanitized = _sanitizeWeightInput(raw);
                          if (sanitized.isEmpty ||
                              _weightReg.hasMatch(sanitized)) {
                            _updateExerciseState(index,
                                sanitized.isEmpty ? null : sanitized, null);
                          }
                        },
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// Formatter que permite sólo dígitos y un punto (máximo uno).
class SingleDotDecimalFormatter extends TextInputFormatter {
  final RegExp _allowed = RegExp(r'[0-9\.]');
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String filtered =
        newValue.text.split('').where((c) => _allowed.hasMatch(c)).join();
    if (filtered.split('.').length > 2) {
      final parts = filtered.split('.');
      filtered = parts[0] + '.' + parts.sublist(1).join('');
    }
    if (filtered.startsWith('.')) filtered = '0$filtered';
    int offset = filtered.length;
    try {
      offset = newValue.selection.baseOffset.clamp(0, filtered.length);
    } catch (_) {}
    return TextEditingValue(
        text: filtered, selection: TextSelection.collapsed(offset: offset));
  }
}
