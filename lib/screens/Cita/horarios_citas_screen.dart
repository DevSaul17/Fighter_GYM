import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../database/database_helper.dart';

class HorariosCitasScreen extends StatefulWidget {
  const HorariosCitasScreen({super.key});

  @override
  State<HorariosCitasScreen> createState() => _HorariosCitasScreenState();
}

class _HorariosCitasScreenState extends State<HorariosCitasScreen> {
  List<Map<String, dynamic>> _citas = [];

  @override
  void initState() {
    super.initState();
    _loadCitas();
  }

  Future<void> _loadCitas() async {
    final citas = await DatabaseHelper.instance.getCitas();
    setState(() {
      _citas = citas;
    });
  }

  Future<void> _addCita() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha == null) return;

    final TimeOfDay? hora = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora == null) return;

    final fechaStr =
        '${fecha.year.toString().padLeft(4, '0')}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
    final horaStr =
        '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}';

    final row = {'fecha': fechaStr, 'hora': horaStr};
    await DatabaseHelper.instance.insertCita(row);
    await _loadCitas();
  }

  Future<void> _deleteCita(int id) async {
    await DatabaseHelper.instance.deleteCita(id);
    await _loadCitas();
  }

  Future<void> _editCita(int id, String fecha, String hora) async {
    // Parse fecha (YYYY-MM-DD) to DateTime
    DateTime initialDate = DateTime.now();
    try {
      initialDate = DateTime.parse(fecha);
    } catch (_) {}

    final DateTime? newFecha = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (newFecha == null) return;

    // Parse hora (HH:mm) to TimeOfDay
    TimeOfDay initialTime = TimeOfDay.now();
    try {
      final parts = hora.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        initialTime = TimeOfDay(hour: h, minute: m);
      }
    } catch (_) {}

    final TimeOfDay? newHora = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: initialTime,
    );
    if (newHora == null) return;

    final fechaStr =
        '${newFecha.year.toString().padLeft(4, '0')}-'
        '${newFecha.month.toString().padLeft(2, '0')}-'
        '${newFecha.day.toString().padLeft(2, '0')}';
    final horaStr =
        '${newHora.hour.toString().padLeft(2, '0')}:'
        '${newHora.minute.toString().padLeft(2, '0')}';

    final row = {'fecha': fechaStr, 'hora': horaStr};
    await DatabaseHelper.instance.updateCita(id, row);
    await _loadCitas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppText.horariosCitas),
        centerTitle: true,
      ),
      body: _citas.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.event_note, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No hay citas registradas.'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _citas.length,
              itemBuilder: (context, index) {
                final cita = _citas[index];
                final id = cita['id'] as int?;
                final fecha = cita['fecha'] as String? ?? '';
                final hora = cita['hora'] as String? ?? '';
                return ListTile(
                  leading: const Icon(Icons.event),
                  title: Text('$fecha  $hora'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: id == null
                            ? null
                            : () async {
                                await _editCita(id, fecha, hora);
                              },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: id == null
                            ? null
                            : () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Eliminar cita'),
                                    content: const Text(
                                      '¿Deseas eliminar esta cita?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _deleteCita(id);
                                }
                              },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCita,
        child: const Icon(Icons.add),
      ),
    );
  }
}
