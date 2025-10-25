import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class MembresiaScreen extends StatefulWidget {
  const MembresiaScreen({super.key});

  @override
  State<MembresiaScreen> createState() => _MembresiaScreenState();
}

class _MembresiaScreenState extends State<MembresiaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  List<Map<String, dynamic>> _clientesSin = [];
  List<Map<String, dynamic>> _clientesCon = [];
  List<Map<String, dynamic>> _planes = [];
  List<Map<String, dynamic>> _clientesAll = [];
  List<Map<String, dynamic>> _pagos = [];

  // form state for crear membresia
  final _formKey = GlobalKey<FormState>();
  int? _selectedClienteId;
  int? _selectedPlanId;
  int _frecuencia = 3;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  TimeOfDay? _hora;
  bool _recuperacionSabado = true;

  // Pagos form
  final _pagoFormKey = GlobalKey<FormState>();
  int? _pagoClienteId;
  final TextEditingController _montoC = TextEditingController();
  int _mesesAdelantados = 1;
  final TextEditingController _metodoC = TextEditingController();
  final TextEditingController _referenciaC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final planes = await DatabaseHelper.instance.getPlanes();
    final sin = await DatabaseHelper.instance.getClientesSinMembresia();
    final con = await DatabaseHelper.instance.getClientesConMembresia();
    final clientes = await DatabaseHelper.instance.getClientes();
    final pagos = await DatabaseHelper.instance.getPagos();
    if (mounted) {
      setState(() {
        _planes = planes;
        _clientesSin = sin;
        _clientesCon = con;
        _clientesAll = clientes;
        _pagos = pagos;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _montoC.dispose();
    _metodoC.dispose();
    _referenciaC.dispose();
    super.dispose();
  }

  Future<void> _pickFechaInicio() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null && mounted) setState(() => _fechaInicio = picked);
  }

  Future<void> _pickFechaFin() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? now.add(const Duration(days: 30)),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) setState(() => _fechaFin = picked);
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null && mounted) setState(() => _hora = picked);
  }

  Future<void> _submitPago() async {
    if (!_pagoFormKey.currentState!.validate()) return;
    if (_pagoClienteId == null || _montoC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione cliente y monto')),
      );
      return;
    }

    final monto = double.tryParse(_montoC.text.replaceAll(',', '.')) ?? 0.0;
    final row = {
      'id_cliente': _pagoClienteId,
      'id_membresia': null,
      'monto': monto,
      'meses_adelantados': _mesesAdelantados,
      'metodo_pago': _metodoC.text.trim().isEmpty ? null : _metodoC.text.trim(),
      'referencia': _referenciaC.text.trim().isEmpty
          ? null
          : _referenciaC.text.trim(),
    };

    try {
      await DatabaseHelper.instance.insertPago(row);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pago registrado')));
      _pagoFormKey.currentState?.reset();
      _montoC.clear();
      _metodoC.clear();
      _referenciaC.clear();
      _pagoClienteId = null;
      _mesesAdelantados = 1;
      await _loadData();
      _tabController.animateTo(2);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error registrando pago: $e')));
      }
    }
  }

  void _openCrearFormForClient(Map<String, dynamic> cliente) {
    // populate client and open form in a modal
    _selectedClienteId = cliente['id'] as int?;
    _selectedPlanId = _planes.isNotEmpty ? _planes.first['id'] as int? : null;
    _frecuencia = 3;
    _fechaInicio = DateTime.now();
    _fechaFin = DateTime.now().add(const Duration(days: 30));
    _hora = const TimeOfDay(hour: 8, minute: 0);
    _recuperacionSabado = true;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildForm(cliente),
        ),
      ),
    );
  }

  Widget _buildForm(Map<String, dynamic> cliente) {
    final nombre = '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Crear membresía para',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _selectedPlanId,
                items: _planes
                    .map(
                      (p) => DropdownMenuItem<int>(
                        value: p['id'] as int,
                        child: Text(p['nombre'] ?? ''),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedPlanId = v),
                decoration: const InputDecoration(labelText: 'Plan'),
                validator: (v) => v == null ? 'Seleccione un plan' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _frecuencia,
                items: const [
                  DropdownMenuItem(value: 3, child: Text('3 veces por semana')),
                  DropdownMenuItem(value: 5, child: Text('5 veces por semana')),
                ],
                onChanged: (v) => setState(() => _frecuencia = v ?? 3),
                decoration: const InputDecoration(labelText: 'Frecuencia'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Inicio: ${_fechaInicio == null ? '-' : _fechaInicio!.toLocal().toIso8601String().split('T').first}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickFechaInicio,
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fin: ${_fechaFin == null ? '-' : _fechaFin!.toLocal().toIso8601String().split('T').first}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickFechaFin,
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hora: ${_hora == null ? '-' : _hora!.format(context)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickHora,
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
              CheckboxListTile(
                title: const Text('Recuperación sábado'),
                value: _recuperacionSabado,
                onChanged: (v) =>
                    setState(() => _recuperacionSabado = v ?? true),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submitMembresia,
                child: const Text('Crear membresía'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitMembresia() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClienteId == null ||
        _selectedPlanId == null ||
        _fechaInicio == null ||
        _fechaFin == null ||
        _hora == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos')),
      );
      return;
    }

    final horaStr =
        '${_hora!.hour.toString().padLeft(2, '0')}:${_hora!.minute.toString().padLeft(2, '0')}';
    final row = {
      'id_cliente': _selectedClienteId,
      'id_plan': _selectedPlanId,
      'frecuencia': _frecuencia,
      'fecha_inicio': _fechaInicio!.toIso8601String().split('T').first,
      'fecha_fin': _fechaFin!.toIso8601String().split('T').first,
      'hora': horaStr,
      'recuperacion_sabado': _recuperacionSabado ? 1 : 0,
      'activa': 1,
    };

    try {
      await DatabaseHelper.instance.insertMembresia(row);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Membresía creada')));
      Navigator.of(context).pop(); // close bottom sheet
      await _loadData();
      // switch to members tab to show created record
      _tabController.animateTo(1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creando membresía: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membresías'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Clientes sin membresía'),
            Tab(text: 'Clientes con membresía'),
            Tab(text: 'Pagos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Clientes sin membresía
          RefreshIndicator(
            onRefresh: _loadData,
            child: _clientesSin.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Center(child: Text('No hay clientes sin membresía.')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _clientesSin.length,
                    itemBuilder: (context, i) {
                      final c = _clientesSin[i];
                      final id = c['id'] as int?;
                      return Card(
                        child: ListTile(
                          title: Text(
                            '${c['nombres'] ?? ''} ${c['apellidos'] ?? ''}',
                          ),
                          subtitle: Text('DNI: ${c['dni'] ?? ''}'),
                          trailing: id == null
                              ? null
                              : ElevatedButton(
                                  onPressed: () => _openCrearFormForClient(c),
                                  child: const Text('Crear membresía'),
                                ),
                        ),
                      );
                    },
                  ),
          ),

          // Clientes con membresía
          RefreshIndicator(
            onRefresh: _loadData,
            child: _clientesCon.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Center(child: Text('No hay membresías registradas.')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _clientesCon.length,
                    itemBuilder: (context, i) {
                      final m = _clientesCon[i];
                      final nombre =
                          '${m['cliente_nombres'] ?? ''} ${m['cliente_apellidos'] ?? ''}';
                      return Card(
                        child: ListTile(
                          title: Text(nombre),
                          subtitle: Text(
                            'Plan: ${m['plan_nombre'] ?? ''}\nInicio: ${m['fecha_inicio'] ?? ''} - Fin: ${m['fecha_fin'] ?? ''}\nHora: ${m['hora'] ?? ''} - Frec: ${m['frecuencia'] ?? ''}',
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
          // Pagos
          RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Form(
                    key: _pagoFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: _pagoClienteId,
                          items: _clientesAll
                              .map(
                                (c) => DropdownMenuItem<int>(
                                  value: c['id'] as int,
                                  child: Text(
                                    '${c['nombres'] ?? ''} ${c['apellidos'] ?? ''}',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _pagoClienteId = v),
                          decoration: const InputDecoration(
                            labelText: 'Cliente',
                          ),
                          validator: (v) =>
                              v == null ? 'Seleccione un cliente' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _montoC,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Monto'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingrese un monto'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _mesesAdelantados,
                          items: List.generate(12, (i) => i + 1)
                              .map(
                                (m) => DropdownMenuItem<int>(
                                  value: m,
                                  child: Text('$m meses'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _mesesAdelantados = v ?? 1),
                          decoration: const InputDecoration(
                            labelText: 'Meses adelantados',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _metodoC,
                          decoration: const InputDecoration(
                            labelText: 'Método de pago (opcional)',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _referenciaC,
                          decoration: const InputDecoration(
                            labelText: 'Referencia (opcional)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _submitPago,
                          child: const Text('Registrar Pago'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Pagos recientes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _pagos.isEmpty
                      ? const Text('No hay pagos registrados.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _pagos.length,
                          itemBuilder: (context, i) {
                            final p = _pagos[i];
                            final clienteName =
                                '${p['cliente_nombres'] ?? ''} ${p['cliente_apellidos'] ?? ''}';
                            return Card(
                              child: ListTile(
                                title: Text(clienteName),
                                subtitle: Text(
                                  'Monto: ${p['monto'] ?? 0} - Fecha: ${p['fecha_pago'] ?? ''}\nMétodo: ${p['metodo_pago'] ?? '-'} Ref: ${p['referencia'] ?? '-'}',
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
        ],
      ),
    );
  }
}
