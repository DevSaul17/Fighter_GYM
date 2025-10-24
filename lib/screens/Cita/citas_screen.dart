import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../database/database_helper.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _prospectos = [];
  Map<int, Map<String, dynamic>> _citasById = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final prospectos = await DatabaseHelper.instance.getProspectos();
    final citas = await DatabaseHelper.instance.getCitas();
    final map = <int, Map<String, dynamic>>{};
    for (final c in citas) {
      final id = c['id'];
      if (id is int) map[id] = c;
    }
    setState(() {
      _prospectos = prospectos;
      _citasById = map;
      _loading = false;
    });
  }

  String _formatCita(int? citaId) {
    if (citaId == null) return 'Sin cita asociada';
    final c = _citasById[citaId];
    if (c == null) return 'Cita (id: $citaId)';
    final fecha = c['fecha'] as String? ?? '';
    final hora = c['hora'] as String? ?? '';
    return '$fecha  $hora';
  }

  void _showDetails(Map<String, dynamic> p) {
    final nombres = p['nombres'] ?? '';
    final apellidos = p['apellidos'] ?? '';
    final celular = p['celular'] ?? '';
    final edad = p['edad']?.toString() ?? '';
    final peso = p['peso']?.toString() ?? '';
    final talla = p['talla']?.toString() ?? '';
    final genero = p['genero'] ?? '';
    final objetivo = p['objetivo'] ?? '';
    final citaId = p['cita_id'] as int?;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$nombres $apellidos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Celular: $celular'),
            Text('Edad: $edad'),
            Text('Peso: $peso'),
            Text('Talla: $talla'),
            Text('Género: $genero'),
            Text('Objetivo: $objetivo'),
            const SizedBox(height: 8),
            Text('Cita: ${_formatCita(citaId)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppText.citas), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _prospectos.isEmpty
          ? const Center(child: Text('No hay prospectos registrados.'))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _prospectos.length,
                itemBuilder: (context, index) {
                  final p = _prospectos[index];
                  final nombres = p['nombres'] ?? '';
                  final apellidos = p['apellidos'] ?? '';
                  final celular = p['celular'] ?? '';
                  final objetivo = p['objetivo'] ?? '';
                  final citaId = p['cita_id'] as int?;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    child: ListTile(
                      title: Text('$nombres $apellidos'),
                      subtitle: Text(
                        '$objetivo\n$celular\n${_formatCita(citaId)}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => _showDetails(p),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
