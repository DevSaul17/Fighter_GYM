import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class NegocioScreen extends StatefulWidget {
  const NegocioScreen({super.key});

  @override
  State<NegocioScreen> createState() => _NegocioScreenState();
}

class _NegocioScreenState extends State<NegocioScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Plan controllers
  final _planFormKey = GlobalKey<FormState>();
  final TextEditingController _planNombreC = TextEditingController();
  final TextEditingController _planDescC = TextEditingController();

  // Entrenador controllers
  final _entFormKey = GlobalKey<FormState>();
  final TextEditingController _entNombresC = TextEditingController();
  final TextEditingController _entApellidosC = TextEditingController();
  final TextEditingController _entCelularC = TextEditingController();
  final TextEditingController _entCorreoC = TextEditingController();

  // Horario controllers (UI only: inserting horarios requires a membresia id)
  final _horFormKey = GlobalKey<FormState>();
  DateTime? _horFecha;
  TimeOfDay? _horHora;
  int? _horEntrenadorId;
  List<Map<String, dynamic>> _entrenadores = [];
  List<Map<String, dynamic>> _horarios = [];

  // Entrenadores state for list/edit
  int? _editingEntrenadorId;
  List<Map<String, dynamic>> _entrenadoresList = [];

  // Planes
  List<Map<String, dynamic>> _planes = [];
  int? _editingPlanId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEntrenadores();
    _loadPlanes();
    _loadHorarios();
  }

  Future<void> _loadHorarios() async {
    final data = await DatabaseHelper.instance.getHorarios();
    if (mounted) setState(() => _horarios = data);
  }

  Future<void> _loadPlanes() async {
    final data = await DatabaseHelper.instance.getPlanes();
    if (mounted) setState(() => _planes = data);
  }

  Future<void> _loadEntrenadores() async {
    final data = await DatabaseHelper.instance.getEntrenadores();
    if (mounted) {
      setState(() {
        _entrenadores = data;
        _entrenadoresList = data;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _planNombreC.dispose();
    _planDescC.dispose();
    _entNombresC.dispose();
    _entApellidosC.dispose();
    _entCelularC.dispose();
    _entCorreoC.dispose();
    super.dispose();
  }

  Future<void> _savePlan() async {
    if (!_planFormKey.currentState!.validate()) return;
    final row = {
      'nombre': _planNombreC.text.trim(),
      'descripcion': _planDescC.text.trim().isEmpty
          ? null
          : _planDescC.text.trim(),
    };
    try {
      if (_editingPlanId != null) {
        await DatabaseHelper.instance.updatePlan(_editingPlanId!, row);
      } else {
        await DatabaseHelper.instance.insertPlan(row);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingPlanId != null ? 'Plan actualizado' : 'Plan guardado',
          ),
        ),
      );
      _planFormKey.currentState?.reset();
      _planNombreC.clear();
      _planDescC.clear();
      await _loadPlanes();
      // exit editing mode
      if (_editingPlanId != null) setState(() => _editingPlanId = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando plan: ${e.toString()}')),
        );
      }
    }
  }

  void _startEditPlan(Map<String, dynamic> plan) {
    final id = plan['id'] as int?;
    if (id == null) return;
    setState(() {
      _editingPlanId = id;
      _planNombreC.text = plan['nombre'] ?? '';
      _planDescC.text = plan['descripcion'] ?? '';
    });
    // Ensure Plans tab is active
    _tabController.animateTo(0);
  }

  void _cancelEdit() {
    setState(() => _editingPlanId = null);
    _planFormKey.currentState?.reset();
    _planNombreC.clear();
    _planDescC.clear();
  }

  Future<void> _deletePlan(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Eliminar plan'),
        content: const Text('¿Desea eliminar este plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deletePlan(id);
      await _loadPlanes();
    }
  }

  Future<void> _saveEntrenador() async {
    if (!_entFormKey.currentState!.validate()) return;
    final row = {
      'nombres': _entNombresC.text.trim(),
      'apellidos': _entApellidosC.text.trim(),
      'celular': _entCelularC.text.trim().isEmpty
          ? null
          : _entCelularC.text.trim(),
      'correo': _entCorreoC.text.trim().isEmpty
          ? null
          : _entCorreoC.text.trim(),
    };
    try {
      if (_editingEntrenadorId != null) {
        await DatabaseHelper.instance.updateEntrenador(
          _editingEntrenadorId!,
          row,
        );
      } else {
        await DatabaseHelper.instance.insertEntrenador(row);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingEntrenadorId != null
                ? 'Entrenador actualizado'
                : 'Entrenador guardado',
          ),
        ),
      );
      _entFormKey.currentState?.reset();
      _entNombresC.clear();
      _entApellidosC.clear();
      _entCelularC.clear();
      _entCorreoC.clear();
      await _loadEntrenadores();
      // exit editing mode
      if (_editingEntrenadorId != null) {
        setState(() => _editingEntrenadorId = null);
      }
      _tabController.animateTo(2);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error guardando entrenador: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _startEditEntrenador(Map<String, dynamic> ent) {
    final id = ent['id'] as int?;
    if (id == null) return;
    setState(() {
      _editingEntrenadorId = id;
      _entNombresC.text = ent['nombres'] ?? '';
      _entApellidosC.text = ent['apellidos'] ?? '';
      _entCelularC.text = ent['celular'] ?? '';
      _entCorreoC.text = ent['correo'] ?? '';
    });
    _tabController.animateTo(2);
  }

  void _cancelEditEntrenador() {
    setState(() => _editingEntrenadorId = null);
    _entFormKey.currentState?.reset();
    _entNombresC.clear();
    _entApellidosC.clear();
    _entCelularC.clear();
    _entCorreoC.clear();
  }

  Future<void> _deleteEntrenador(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Eliminar entrenador'),
        content: const Text('¿Desea eliminar este entrenador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteEntrenador(id);
      await _loadEntrenadores();
      if (_editingEntrenadorId == id) _cancelEditEntrenador();
    }
  }

  Future<void> _pickFechaHorario() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _horFecha ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null && mounted) setState(() => _horFecha = picked);
  }

  Future<void> _pickHoraHorario() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) setState(() => _horHora = picked);
  }

  Future<void> _saveHorario() async {
    if (!_horFormKey.currentState!.validate()) return;
    // Validate presence
    if (_horFecha == null || _horHora == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione fecha y hora')));
      return;
    }

    // Validate against availability rules
    final available = DatabaseHelper.instance.horarioDisponibleFromParts(
      _horFecha!,
      _horHora!.hour,
      _horHora!.minute,
    );

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Horario no disponible. Sábados/Domingos: 05:00-15:00. Lunes-Viernes: 05:00-22:00.',
          ),
        ),
      );
      return;
    }

    // NOTE: In DB, horarios requires id_membresia NOT NULL. We don't create membresias here,
    // so we only provide a UI placeholder for now. If you want to insert horarios, pass a valid
    // id_membresia in the row and call DatabaseHelper.instance.insertHorario(row).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Horario dentro de la disponibilidad (vista) — implementar inserción real si aplica',
        ),
      ),
    );

    // Clear
    if (mounted) {
      setState(() {
        _horFecha = null;
        _horHora = null;
        _horEntrenadorId = null;
      });
    }
    // refresh list in case there are stored horarios
    await _loadHorarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Negocio'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Planes'),
            Tab(text: 'Horarios'),
            Tab(text: 'Entrenadores'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Planes Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _planFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _planNombreC,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del plan',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingrese nombre'
                        : null,
                  ),
                  TextFormField(
                    controller: _planDescC,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _savePlan,
                    child: Text(
                      _editingPlanId != null
                          ? 'Actualizar Plan'
                          : 'Guardar Plan',
                    ),
                  ),
                  if (_editingPlanId != null)
                    TextButton(
                      onPressed: _cancelEdit,
                      child: const Text('Cancelar'),
                    ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Planes registrados',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_planes.isEmpty)
                    const Text('No hay planes registrados.')
                  else
                    Column(
                      children: _planes.map((p) {
                        final id = p['id'] as int?;
                        return Card(
                          child: ListTile(
                            onTap: () => _startEditPlan(p),
                            title: Text(p['nombre'] ?? ''),
                            subtitle: p['descripcion'] == null
                                ? null
                                : Text(p['descripcion']),
                            trailing: id == null
                                ? null
                                : IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await _deletePlan(id);
                                      if (_editingPlanId == id) _cancelEdit();
                                    },
                                  ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),

          // Horarios Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _horFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _horFecha == null
                              ? 'Fecha: -'
                              : 'Fecha: ${_horFecha!.toLocal().toIso8601String().split('T').first}',
                        ),
                      ),
                      TextButton(
                        onPressed: _pickFechaHorario,
                        child: const Text('Seleccionar'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _horHora == null
                              ? 'Hora: -'
                              : 'Hora: ${_horHora!.format(context)}',
                        ),
                      ),
                      TextButton(
                        onPressed: _pickHoraHorario,
                        child: const Text('Seleccionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _horEntrenadorId,
                    decoration: const InputDecoration(
                      labelText: 'Entrenador (opcional)',
                    ),
                    items: _entrenadores.map((e) {
                      return DropdownMenuItem<int>(
                        value: e['id'] as int?,
                        child: Text(
                          '${e['nombres'] ?? ''} ${e['apellidos'] ?? ''}',
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _horEntrenadorId = v),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _saveHorario,
                    child: const Text('Registrar Horario (vista)'),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Horarios registrados',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _horarios.isEmpty
                      ? const Text('No hay horarios registrados.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _horarios.length,
                          itemBuilder: (context, i) {
                            final h = _horarios[i];
                            final fecha = h['fecha'] ?? '';
                            final hora = h['hora'] ?? '';
                            final cliente =
                                '${h['cliente_nombres'] ?? ''} ${h['cliente_apellidos'] ?? ''}'
                                    .trim();
                            final entrenador =
                                '${h['entrenador_nombres'] ?? ''} ${h['entrenador_apellidos'] ?? ''}'
                                    .trim();
                            final estado = h['estado'] ?? '';
                            return Card(
                              child: ListTile(
                                title: Text('$fecha $hora'),
                                subtitle: Text(
                                  'Cliente: ${cliente.isEmpty ? '-' : cliente}\nEntrenador: ${entrenador.isEmpty ? '-' : entrenador}\nEstado: $estado',
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),

          // Entrenadores Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _entFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _entNombresC,
                    decoration: const InputDecoration(labelText: 'Nombres'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingrese nombres'
                        : null,
                  ),
                  TextFormField(
                    controller: _entApellidosC,
                    decoration: const InputDecoration(labelText: 'Apellidos'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingrese apellidos'
                        : null,
                  ),
                  TextFormField(
                    controller: _entCelularC,
                    decoration: const InputDecoration(
                      labelText: 'Celular (opcional)',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: _entCorreoC,
                    decoration: const InputDecoration(
                      labelText: 'Correo (opcional)',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _saveEntrenador,
                    child: Text(
                      _editingEntrenadorId != null
                          ? 'Actualizar Entrenador'
                          : 'Guardar Entrenador',
                    ),
                  ),
                  if (_editingEntrenadorId != null)
                    TextButton(
                      onPressed: _cancelEditEntrenador,
                      child: const Text('Cancelar'),
                    ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Entrenadores registrados',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_entrenadoresList.isEmpty)
                    const Text('No hay entrenadores registrados.')
                  else
                    Column(
                      children: _entrenadoresList.map((ent) {
                        final id = ent['id'] as int?;
                        return Card(
                          child: ListTile(
                            onTap: () => _startEditEntrenador(ent),
                            title: Text(
                              '${ent['nombres'] ?? ''} ${ent['apellidos'] ?? ''}',
                            ),
                            subtitle: Text(
                              'Celular: ${ent['celular'] ?? ''}\nCorreo: ${ent['correo'] ?? ''}',
                            ),
                            isThreeLine: true,
                            trailing: id == null
                                ? null
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _startEditEntrenador(ent),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteEntrenador(id),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
