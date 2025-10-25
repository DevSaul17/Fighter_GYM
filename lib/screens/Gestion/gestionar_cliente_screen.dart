import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../database/database_helper.dart';

class GestionarClienteScreen extends StatefulWidget {
  const GestionarClienteScreen({super.key});

  @override
  State<GestionarClienteScreen> createState() => _GestionarClienteScreenState();
}

class _GestionarClienteScreenState extends State<GestionarClienteScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dniC = TextEditingController();
  final TextEditingController _nombresC = TextEditingController();
  final TextEditingController _apellidosC = TextEditingController();
  final TextEditingController _celularC = TextEditingController();
  final TextEditingController _correoC = TextEditingController();
  final TextEditingController _edadC = TextEditingController();
  final TextEditingController _pesoC = TextEditingController();
  final TextEditingController _tallaC = TextEditingController();
  final TextEditingController _descripcionC = TextEditingController();
  final TextEditingController _condicionC = TextEditingController();
  final TextEditingController _contrasenaC = TextEditingController();

  String _genero = 'Masculino';
  DateTime? _fechaNacimiento;
  bool _saving = false;
  bool _loadingClientes = false;
  List<Map<String, dynamic>> _clientes = [];
  late final TabController _tabController;

  @override
  void dispose() {
    _dniC.dispose();
    _nombresC.dispose();
    _apellidosC.dispose();
    _celularC.dispose();
    _correoC.dispose();
    _edadC.dispose();
    _pesoC.dispose();
    _tallaC.dispose();
    _descripcionC.dispose();
    _condicionC.dispose();
    _contrasenaC.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickFechaNacimiento() async {
    final DateTime now = DateTime.now();
    final DateTime initial = _fechaNacimiento ?? DateTime(now.year - 20);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _fechaNacimiento = picked);
  }

  Future<void> _saveCliente() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      // Capture objects that use BuildContext before async gaps
      final messenger = ScaffoldMessenger.of(context);

      final row = <String, dynamic>{
        'dni': _dniC.text.trim(),
        'nombres': _nombresC.text.trim(),
        'apellidos': _apellidosC.text.trim(),
        'celular': _celularC.text.trim(),
        'correo': _correoC.text.trim().isEmpty ? null : _correoC.text.trim(),
        'edad': _edadC.text.trim().isEmpty ? null : int.tryParse(_edadC.text),
        'peso': _pesoC.text.trim().isEmpty
            ? null
            : double.tryParse(_pesoC.text),
        'talla': _tallaC.text.trim().isEmpty
            ? null
            : double.tryParse(_tallaC.text),
        'genero': _genero,
        'descripcion': _descripcionC.text.trim().isEmpty
            ? null
            : _descripcionC.text.trim(),
        'condicion_medica': _condicionC.text.trim().isEmpty
            ? null
            : _condicionC.text.trim(),
        'fecha_nacimiento': _fechaNacimiento?.toIso8601String(),
        // For now we store the password as provided in contrasena_hash. Consider hashing.
        'contrasena_hash': _contrasenaC.text,
      };

      await DatabaseHelper.instance.insertCliente(row);

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Cliente registrado correctamente')),
      );
      // Clear form fields
      _formKey.currentState?.reset();
      _dniC.clear();
      _nombresC.clear();
      _apellidosC.clear();
      _celularC.clear();
      _correoC.clear();
      _edadC.clear();
      _pesoC.clear();
      _tallaC.clear();
      _descripcionC.clear();
      _condicionC.clear();
      _contrasenaC.clear();
      _fechaNacimiento = null;
      _genero = 'Masculino';
      await _loadClientes();
      // Switch to Clientes tab
      _tabController.animateTo(1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar cliente: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadClientes() async {
    setState(() => _loadingClientes = true);
    try {
      final data = await DatabaseHelper.instance.getClientes();
      if (mounted) setState(() => _clientes = data);
    } catch (_) {
      if (mounted) setState(() => _clientes = []);
    } finally {
      if (mounted) setState(() => _loadingClientes = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClientes();
  }

  Widget _buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _dniC,
              decoration: const InputDecoration(labelText: 'DNI'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingrese DNI' : null,
            ),
            TextFormField(
              controller: _nombresC,
              decoration: const InputDecoration(labelText: 'Nombres'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingrese nombres' : null,
            ),
            TextFormField(
              controller: _apellidosC,
              decoration: const InputDecoration(labelText: 'Apellidos'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingrese apellidos' : null,
            ),
            TextFormField(
              controller: _celularC,
              decoration: const InputDecoration(labelText: 'Celular'),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingrese celular' : null,
            ),
            TextFormField(
              controller: _correoC,
              decoration: const InputDecoration(labelText: 'Correo (opcional)'),
              keyboardType: TextInputType.emailAddress,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _edadC,
                    decoration: const InputDecoration(labelText: 'Edad'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _pesoC,
                    decoration: const InputDecoration(labelText: 'Peso (kg)'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _tallaC,
              decoration: const InputDecoration(labelText: 'Talla (m)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _genero,
              items: const [
                DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
              ],
              onChanged: (v) => setState(() => _genero = v ?? 'Masculino'),
              decoration: const InputDecoration(labelText: 'Género'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descripcionC,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
              ),
              maxLines: 2,
            ),
            TextFormField(
              controller: _condicionC,
              decoration: const InputDecoration(
                labelText: 'Condición médica (opcional)',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _fechaNacimiento == null
                        ? 'Fecha de nacimiento: -'
                        : 'Fecha: ${_fechaNacimiento!.toLocal().toIso8601String().split('T').first}',
                  ),
                ),
                TextButton(
                  onPressed: _pickFechaNacimiento,
                  child: const Text('Seleccionar'),
                ),
              ],
            ),
            TextFormField(
              controller: _contrasenaC,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Ingrese contraseña' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _saveCliente,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Registrar cliente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientesTab() {
    if (_loadingClientes) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_clientes.isEmpty) {
      return const Center(child: Text('No hay clientes registrados.'));
    }

    return RefreshIndicator(
      onRefresh: _loadClientes,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _clientes.length,
        itemBuilder: (context, index) {
          final c = _clientes[index];
          final nombres = c['nombres'] ?? '';
          final apellidos = c['apellidos'] ?? '';
          final dni = c['dni'] ?? '';
          final celular = c['celular'] ?? '';
          final id = c['id'] as int?;
          return Card(
            child: ListTile(
              title: Text('$nombres $apellidos'),
              subtitle: Text('DNI: $dni\nCelular: $celular'),
              isThreeLine: true,
              onTap: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('$nombres $apellidos'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DNI: $dni'),
                      Text('Celular: $celular'),
                      Text('Correo: ${c['correo'] ?? ''}'),
                      Text('Edad: ${c['edad'] ?? ''}'),
                      Text('Peso: ${c['peso'] ?? ''}'),
                      Text('Talla: ${c['talla'] ?? ''}'),
                      Text('Género: ${c['genero'] ?? ''}'),
                      Text('Condición médica: ${c['condicion_medica'] ?? ''}'),
                    ],
                  ),
                  actions: [
                    if (id != null)
                      TextButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Eliminar cliente'),
                              content: const Text('¿Eliminar este cliente?'),
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
                            // ignore: use_build_context_synchronously
                            final navigator = Navigator.of(context);
                            await DatabaseHelper.instance.deleteCliente(id);
                            await _loadClientes();
                            navigator.pop();
                          }
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ),
              trailing: id == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Eliminar cliente'),
                            content: const Text('¿Eliminar este cliente?'),
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
                          await DatabaseHelper.instance.deleteCliente(id);
                          await _loadClientes();
                        }
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppText.gestionarCliente),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Registrar'),
            Tab(text: 'Clientes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormTab(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildClientesTab(),
          ),
        ],
      ),
    );
  }
}
