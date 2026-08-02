import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BiometriaPage extends StatefulWidget {
  const BiometriaPage({Key? key}) : super(key: key);

  @override
  _BiometriaPageState createState() => _BiometriaPageState();
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;
  DecimalTextInputFormatter({this.decimalRange = 2});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) return oldValue;
    if (text.indexOf('.') != text.lastIndexOf('.')) return oldValue;
    if (text.startsWith('.')) return oldValue;

    if (text.contains('.') && decimalRange >= 0) {
      final index = text.indexOf('.');
      final decimals = text.length - index - 1;
      if (decimals > decimalRange) return oldValue;
    }
    return newValue;
  }
}

class _BiometriaPageState extends State<BiometriaPage> {
  List<Map<String, dynamic>> registros = [];

  @override
  void initState() {
    super.initState();
    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('registros') ?? '[]';
    try {
      registros = List<Map<String, dynamic>>.from(json.decode(data));
    } catch (_) {
      registros = [];
    }
    setState(() {});
  }

  Future<void> _guardarRegistro(Map<String, dynamic> registro) async {
    registros.add(registro);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registros', json.encode(registros));
    setState(() {});
  }

  Future<void> _borrarRegistros() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('registros');
    setState(() => registros.clear());
  }

  Future<void> _eliminarRegistro(int index) async {
    registros.removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registros', json.encode(registros));
    setState(() {});
  }

  void _abrirModalRegistro() {
    final _pesoController = TextEditingController();
    final _alturaController = TextEditingController();
    final _presionSisController = TextEditingController();
    final _presionDiaController = TextEditingController();
    final _frecuenciaController = TextEditingController();

    // Autocompletar con el último registro
    if (registros.isNotEmpty) {
      final ultimo = registros.last;
      _pesoController.text = ultimo['peso'].toString();
      _alturaController.text = ultimo['altura'].toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nuevo registro biométrico", style: Theme.of(context).textTheme.headline6),
              const SizedBox(height: 12),
              _buildInput(_pesoController, "Peso (kg)", TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)], hint: 'ej. 72.5'),
              _buildInput(_alturaController, "Altura (cm)", TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], hint: 'ej. 175'),
              Row(
                children: [
                  Expanded(
                    child: _buildInput(_presionSisController, "Presión Sistólica", TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly], hint: 'ej. 120'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInput(_presionDiaController, "Presión Diastólica", TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly], hint: 'ej. 80'),
                  ),
                ],
              ),
              _buildInput(_frecuenciaController, "Frecuencia cardíaca (30–220)", TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], hint: 'ej. 72'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                  ElevatedButton(
                    onPressed: () {
                      final peso = double.tryParse(_pesoController.text);
                      final altura = double.tryParse(_alturaController.text);
                      final presSis = int.tryParse(_presionSisController.text);
                      final presDia = int.tryParse(_presionDiaController.text);
                      final frecuencia = int.tryParse(_frecuenciaController.text);

                      if (peso == null || peso <= 0 || peso > 300) {
                        _showErrorDialog("Peso inválido (1–300 kg)");
                        return;
                      }
                      if (altura == null || altura < 50 || altura > 250) {
                        _showErrorDialog("Altura inválida (50–250 cm)");
                        return;
                      }
                      if (presSis == null || presSis < 50 || presSis > 250) {
                        _showErrorDialog("Presión sistólica inválida (50–250)");
                        return;
                      }
                      if (presDia == null || presDia < 30 || presDia > 150) {
                        _showErrorDialog("Presión diastólica inválida (30–150)");
                        return;
                      }
                      if (frecuencia == null || frecuencia < 30 || frecuencia > 220) {
                        _showErrorDialog("Frecuencia inválida (30–220)");
                        return;
                      }

                      final alturaM = altura / 100;
                      final imc = double.parse((peso / (alturaM * alturaM)).toStringAsFixed(2));

                      _guardarRegistro({
                        'fecha': DateTime.now().toIso8601String(),
                        'peso': peso,
                        'altura': altura,
                        'imc': imc,
                        'sistolica': presSis,
                        'diastolica': presDia,
                        'presion': '$presSis/$presDia',
                        'frecuencia': frecuencia,
                      });

                      Navigator.pop(context);
                    },
                    child: const Text("Guardar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, TextInputType type,
      {List<TextInputFormatter>? inputFormatters, String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  List<ChartData> _toChartData(String key) {
    if (registros.isEmpty) return [];
    return registros.map((r) {
      final fecha = DateTime.tryParse(r['fecha'] ?? '') ?? DateTime.now();
      final label = "${fecha.day}/${fecha.month} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";
      return ChartData(label, (r[key] as num).toDouble());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final reversed = registros.reversed.toList();
    final ultimo = registros.isNotEmpty ? registros.last : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Biométrico"),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _abrirModalRegistro,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Badges último registro
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Último registro",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIndicador("Peso", ultimo?['peso']?.toString() ?? "0", Colors.teal),
                      _buildIndicador("IMC", ultimo?['imc']?.toStringAsFixed(2) ?? "0.00", Colors.orange),
                      _buildIndicador("Frecuencia", ultimo?['frecuencia']?.toString() ?? "0", Colors.redAccent),
                      _buildIndicador("Presión", ultimo?['presion'] ?? "0/0", Colors.blueAccent),
                    ],
                  ),
                ],
              ),
            ),
            // Gráficas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildGrafica("Peso", "kg", Colors.teal, 'peso'),
                  _buildGrafica("IMC", "", Colors.orange, 'imc'),
                  _buildGrafica("Frecuencia cardíaca", "bpm", Colors.redAccent, 'frecuencia'),
                ],
              ),
            ),
            // Historial
            if (registros.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: reversed.asMap().entries.map((entry) {
                    final index = entry.key;
                    final reg = entry.value;
                    final fecha = DateTime.parse(reg['fecha']);
                    Color color = Colors.teal;
                    if (reg['frecuencia'] > 100) color = Colors.redAccent;
                    else if (reg['frecuencia'] < 60) color = Colors.orange;
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          child: Text(reg['frecuencia'].toString(),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text("Peso: ${reg['peso']} kg | IMC: ${reg['imc']?.toStringAsFixed(2) ?? 'N/A'}"),
                        subtitle: Text(
                          "Altura: ${reg['altura']} cm | Presión: ${reg['presion']} | Frecuencia: ${reg['frecuencia']}\n${fecha.toLocal()}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Eliminar registro"),
                                content: const Text("¿Seguro que deseas eliminar este registro?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
                                  ElevatedButton(
                                    onPressed: () {
                                      _eliminarRegistro(registros.length - 1 - index);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text("Eliminar"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),
            // Botón borrar todo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text("Borrar todos los registros"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Confirmar"),
                      content: const Text("¿Seguro que deseas borrar todos los registros?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
                        ElevatedButton(
                          onPressed: () {
                            _borrarRegistros();
                            Navigator.pop(ctx);
                          },
                          child: const Text("Borrar"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicador(String titulo, String valor, Color color) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Text(valor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }

  Widget _buildGrafica(String titulo, String unidad, Color color, String key) {
    final series = _toChartData(key);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 220,
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          tooltipBehavior: TooltipBehavior(enable: true),
          title: ChartTitle(text: "$titulo ($unidad)"),
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          series: <CartesianSeries<ChartData, String>>[
            ColumnSeries<ChartData, String>(
              dataSource: series,
              xValueMapper: (d, _) => d.x,
              yValueMapper: (d, _) => d.y,
              color: color,
              name: titulo,
              borderRadius: BorderRadius.circular(6),
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;
  ChartData(this.x, this.y);
}
