import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: library_prefixes
import 'package:pdf/pdf.dart' as pdfLib;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  // (removed _clientesAll - not used anymore)
  List<Map<String, dynamic>> _pagos = [];
  List<Map<String, dynamic>> _facturas = [];

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

  // Facturas form
  final _facturaFormKey = GlobalKey<FormState>();
  int? _selectedPagoForFactura;
  final TextEditingController _numeroFacturaC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _generateAndSharePdf(
    Map<String, dynamic> memb,
    Map<String, dynamic> pago,
    String numero,
    String diasText,
  ) async {
    try {
      final pdf = pw.Document();

      Uint8List? logoBytes;
      try {
        final data = await rootBundle.load('assets/logo.jpeg');
        logoBytes = data.buffer.asUint8List();
      } catch (_) {
        logoBytes = null;
      }

      pdf.addPage(
        pw.Page(
          pageFormat: pdfLib.PdfPageFormat.a4,
          build: (context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (logoBytes != null)
                    pw.Center(
                      child: pw.Image(pw.MemoryImage(logoBytes), width: 90),
                    ),
                  pw.SizedBox(height: logoBytes != null ? 8 : 12),
                  pw.Center(
                    child: pw.Text(
                      'GIMNASIO - FACTURA',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Factura #:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(numero),
                    ],
                  ),
                  pw.Divider(),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Cliente',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    '${memb['cliente_nombres'] ?? ''} ${memb['cliente_apellidos'] ?? ''}',
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Membresía / Plan',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(memb['plan_nombre'] ?? '-'),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Periodo',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('${memb['fecha_inicio']} - ${memb['fecha_fin']}'),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Hora',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(memb['hora'] ?? '-'),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '${pago['monto'] ?? memb['monto'] ?? '-'}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Pago asociado',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Monto: ${pago['monto'] ?? '-'}  •  Fecha: ${pago['fecha_pago'] ?? '-'}',
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Días de entrenamiento',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(diasText.isEmpty ? '-' : diasText),
                  pw.Spacer(),
                  pw.Divider(),
                  pw.SizedBox(height: 8),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'Gracias por su preferencia',
                      style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final bytes = await pdf.save();
      await Printing.sharePdf(bytes: bytes, filename: '$numero.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generando PDF: $e')));
      }
    }
  }

  Future<void> _loadData() async {
    final planes = await DatabaseHelper.instance.getPlanes();
    final sin = await DatabaseHelper.instance.getClientesSinMembresia();
    final con = await DatabaseHelper.instance.getClientesConMembresia();
    final pagos = await DatabaseHelper.instance.getPagos();
    final facturas = await DatabaseHelper.instance.getFacturas();
    // For each membership entry in `con`, fetch associated dias count so we can
    // filter clients in the Pagos dropdown (clients with frequency==3 must have dias selected)
    final List<Map<String, dynamic>> conWithDias = [];
    for (final m in con) {
      try {
        final idM = m['id'] as int?;
        if (idM != null) {
          final dias = await DatabaseHelper.instance.getDiasMembresia(idM);
          final copy = Map<String, dynamic>.from(m);
          copy['dias_count'] = dias.length;
          copy['dias_list'] = dias;
          conWithDias.add(copy);
          continue;
        }
      } catch (_) {}
      // fallback: keep original
      conWithDias.add(Map<String, dynamic>.from(m));
    }

    if (mounted) {
      setState(() {
        _planes = planes;
        _clientesSin = sin;
        _clientesCon = conWithDias;
        _pagos = pagos;
        _facturas = facturas;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _montoC.dispose();
    _metodoC.dispose();
    _referenciaC.dispose();
    _numeroFacturaC.dispose();
    super.dispose();
  }

  Future<void> _submitFactura() async {
    if (!_facturaFormKey.currentState!.validate()) return;
    if (_selectedPagoForFactura == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un pago para facturar')),
      );
      return;
    }

    try {
      final pago = _pagos.firstWhere(
        (p) => (p['id'] as int) == _selectedPagoForFactura,
      );
      final clienteId = (pago['id_cliente'] as int?);
      if (clienteId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago inválido, falta cliente')),
        );
        return;
      }

      final memb = await DatabaseHelper.instance.getMembresiaByCliente(
        clienteId,
      );
      if (memb == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El cliente no tiene una membresía activa'),
          ),
        );
        return;
      }

      String numero;
      if (_numeroFacturaC.text.trim().isEmpty) {
        numero = await DatabaseHelper.instance.getNextNumeroFactura();
      } else {
        numero = _numeroFacturaC.text.trim();
      }

      final row = {
        'id_pago': pago['id'],
        'numero_factura': numero,
        'membresia_inicio': memb['fecha_inicio'],
        'membresia_fin': memb['fecha_fin'],
        'total': (pago['monto'] as num?)?.toDouble() ?? 0.0,
      };

      await DatabaseHelper.instance.insertFactura(row);

      // fetch dias
      final dias = await DatabaseHelper.instance.getDiasMembresia(
        memb['id'] as int,
      );
      const diasNombres = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo',
      ];
      final diasText = dias
          .map((d) => diasNombres[(d - 1).clamp(0, 6)])
          .join(', ');

      final clienteNombre =
          '${memb['cliente_nombres'] ?? ''} ${memb['cliente_apellidos'] ?? ''}';
      final planNombre = memb['plan_nombre'] ?? '-';

      // Show formatted invoice
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          title: const Text(
            'Factura registrada',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'GIMNASIO - Factura',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Factura #:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(numero),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                Text('Cliente', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(clienteNombre),
                const SizedBox(height: 8),
                Text(
                  'Membresía / Plan',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(planNombre),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Periodo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('${memb["fecha_inicio"]} - ${memb["fecha_fin"]}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hora', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('${memb["hora"] ?? '-'}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${row["total"]}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Pago asociado',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Monto: ${pago["monto"] ?? '-'}  •  Fecha: ${pago["fecha_pago"] ?? '-'}',
                ),
                const SizedBox(height: 12),
                Text(
                  'Días de entrenamiento',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(diasText.isEmpty ? '-' : diasText),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Gracias por su preferencia',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 12),
                // Botón visible para descargar PDF dentro del contenido (evita que quede fuera si actions se recortan)
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Descargar PDF'),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await _generateAndSharePdf(memb, pago, numero, diasText);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // generate and share PDF
                Navigator.of(ctx).pop();
                await _generateAndSharePdf(memb, pago, numero, diasText);
              },
              child: const Text('Descargar PDF'),
            ),
          ],
        ),
      );

      // reset form
      _facturaFormKey.currentState?.reset();
      _selectedPagoForFactura = null;
      _numeroFacturaC.clear();
      await _loadData();
      _tabController.animateTo(3);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registrando factura: $e')),
        );
      }
    }
  }

  /// Muestra el detalle de una factura (usada al tocar una factura reciente)
  Future<void> _showFacturaDetails(Map<String, dynamic> f) async {
    try {
      // intentar encontrar el pago en la caché _pagos
      Map<String, dynamic>? pago;
      try {
        pago = _pagos.firstWhere(
          (p) => (p['id'] as int) == (f['id_pago'] as int),
        );
      } catch (_) {
        // fallback a los campos retornados por la consulta de facturas
        pago = {
          'id': f['id_pago'],
          'monto': f['pago_monto'] ?? f['total'],
          'fecha_pago': f['fecha_pago'] ?? f['fecha_factura'],
        };
      }

      // obtener la membresía asociada al cliente si es posible
      Map<String, dynamic>? memb;
      final clienteId = pago['id_cliente'] as int?;
      if (clienteId != null) {
        memb = await DatabaseHelper.instance.getMembresiaByCliente(clienteId);
      }

      // si no se encontró la membresía activa, construir una representación mínima
      memb ??= {
          'cliente_nombres': f['cliente_nombres'],
          'cliente_apellidos': f['cliente_apellidos'],
          'plan_nombre': f['plan_nombre'] ?? '-',
          'fecha_inicio': f['membresia_inicio'],
          'fecha_fin': f['membresia_fin'],
          'hora': f['hora'] ?? '-',
          'id': f['id_membresia'] ?? f['id_membresia'],
        };

      // obtener días si existe id de membresía
      List<int> dias = [];
      try {
        if (memb['id'] != null) {
          dias = await DatabaseHelper.instance.getDiasMembresia(
            memb['id'] as int,
          );
        }
      } catch (_) {
        dias = [];
      }

      const diasNombres = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo',
      ];
      final diasText = dias
          .map((d) => diasNombres[(d - 1).clamp(0, 6)])
          .join(', ');

      final numero = f['numero_factura'] ?? '';

      // ensure local references
      final membMap = memb;
      final pagoMap = pago;

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          title: const Text(
            'Detalle de factura',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'GIMNASIO - Factura',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Factura #:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(numero),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                Text('Cliente', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '${membMap['cliente_nombres'] ?? ''} ${membMap['cliente_apellidos'] ?? ''}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Membresía / Plan',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(membMap['plan_nombre'] ?? '-'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Periodo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${membMap['fecha_inicio']} - ${membMap['fecha_fin']}',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hora', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('${membMap['hora'] ?? '-'}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${f['total'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Pago asociado',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Monto: ${pagoMap['monto'] ?? '-'}  •  Fecha: ${pagoMap['fecha_pago'] ?? '-'}',
                ),
                const SizedBox(height: 12),
                Text(
                  'Días de entrenamiento',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(diasText.isEmpty ? '-' : diasText),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Gracias por su preferencia',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Descargar PDF'),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await _generateAndSharePdf(
                        membMap,
                        pagoMap,
                        numero,
                        diasText,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _generateAndSharePdf(membMap, pagoMap, numero, diasText);
              },
              child: const Text('Descargar PDF'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error abriendo factura: $e')));
      }
    }
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
      final paidClientId = _pagoClienteId;
      _pagoFormKey.currentState?.reset();
      _montoC.clear();
      _metodoC.clear();
      _referenciaC.clear();
      _pagoClienteId = null;
      _mesesAdelantados = 1;
      await _loadData();
      if (paidClientId != null) {
        await _openSeleccionDiasIfNeeded(paidClientId);
      }
      _tabController.animateTo(2);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error registrando pago: $e')));
      }
    }
  }

  /// Abre la pantalla para seleccionar días/hora según la membresía
  Future<void> _openSeleccionDiasIfNeeded(int clienteId) async {
    final memb = await DatabaseHelper.instance.getMembresiaByCliente(clienteId);
    if (memb == null) return;
    final freq = (memb['frecuencia'] as num?)?.toInt() ?? 0;
    if (freq == 3) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _SeleccionDiasScreen(membresia: memb),
        ),
      );
      await _loadData();
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
            Tab(text: 'Facturas'),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  // Open the day selection screen for this membership
                                  if (!mounted) return;
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          _SeleccionDiasScreen(membresia: m),
                                    ),
                                  );
                                  await _loadData();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text('Días'),
                              ),
                            ],
                          ),
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
                        // Mostrar solo clientes que tienen membresía activa y, si su
                        // frecuencia es 3, que ya tengan días seleccionados.
                        DropdownButtonFormField<int>(
                          initialValue: _pagoClienteId,
                          items: _clientesCon
                              .where((m) {
                                final freq =
                                    (m['frecuencia'] as num?)?.toInt() ?? 0;
                                final diasCount =
                                    (m['dias_count'] as int?) ?? 0;
                                if (freq == 3) {
                                  // requerir que hayan seleccionado exactamente la cantidad de días esperada
                                  return diasCount == freq;
                                }
                                // para otras frecuencias, permitir
                                return true;
                              })
                              .map(
                                (m) => DropdownMenuItem<int>(
                                  value: m['id_cliente'] as int,
                                  child: Text(
                                    '${m['cliente_nombres'] ?? ''} ${m['cliente_apellidos'] ?? ''}',
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

          // Facturas
          RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Form(
                    key: _facturaFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: _selectedPagoForFactura,
                          items: _pagos
                              .map(
                                (p) => DropdownMenuItem<int>(
                                  value: p['id'] as int,
                                  child: Text(
                                    '${p['cliente_nombres'] ?? ''} ${p['cliente_apellidos'] ?? ''} - ${p['monto'] ?? '-'} - ${p['fecha_pago'] ?? ''}',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedPagoForFactura = v),
                          decoration: const InputDecoration(
                            labelText: 'Pago a facturar',
                          ),
                          validator: (v) =>
                              v == null ? 'Seleccione un pago' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _numeroFacturaC,
                          decoration: const InputDecoration(
                            labelText: 'Número de factura (opcional)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _submitFactura,
                          child: const Text('Registrar Factura'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Facturas recientes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _facturas.isEmpty
                      ? const Text('No hay facturas registradas.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _facturas.length,
                          itemBuilder: (context, i) {
                            final f = _facturas[i];
                            final clienteName =
                                '${f['cliente_nombres'] ?? ''} ${f['cliente_apellidos'] ?? ''}';
                            return Card(
                              child: ListTile(
                                title: Text(
                                  '${f['numero_factura'] ?? '-'} - ${f['total'] ?? '-'}',
                                ),
                                subtitle: Text(
                                  'Cliente: $clienteName\nPeriodo: ${f['membresia_inicio'] ?? '-'} - ${f['membresia_fin'] ?? '-'}\nFecha: ${f['fecha_factura'] ?? f['fecha_pago'] ?? '-'}',
                                ),
                                isThreeLine: true,
                                onTap: () async {
                                  await _showFacturaDetails(f);
                                },
                                trailing: IconButton(
                                  icon: const Icon(Icons.download),
                                  tooltip: 'Ver / Descargar',
                                  onPressed: () async {
                                    await _showFacturaDetails(f);
                                  },
                                ),
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

class _SeleccionDiasScreen extends StatefulWidget {
  final Map<String, dynamic> membresia;
  const _SeleccionDiasScreen({required this.membresia});

  @override
  State<_SeleccionDiasScreen> createState() => _SeleccionDiasScreenState();
}

class _SeleccionDiasScreenState extends State<_SeleccionDiasScreen> {
  final List<String> _diasNombres = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  final Set<int> _selected = {};
  late int _frecuencia;
  TimeOfDay? _horaSeleccionada;

  @override
  void initState() {
    super.initState();
    _frecuencia = (widget.membresia['frecuencia'] as num?)?.toInt() ?? 3;
    final horaStr = widget.membresia['hora'] as String?;
    if (horaStr != null && horaStr.contains(':')) {
      final parts = horaStr.split(':');
      final h = int.tryParse(parts[0]) ?? 8;
      final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      _horaSeleccionada = TimeOfDay(hour: h, minute: m);
    } else {
      _horaSeleccionada = const TimeOfDay(hour: 8, minute: 0);
    }
    _loadDias();
  }

  Future<void> _loadDias() async {
    final dias = await DatabaseHelper.instance.getDiasMembresia(
      widget.membresia['id'] as int,
    );
    if (mounted) setState(() => _selected.addAll(dias));
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null && mounted) setState(() => _horaSeleccionada = picked);
  }

  Future<void> _save() async {
    if (_selected.length != _frecuencia) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccione exactamente $_frecuencia días')),
      );
      return;
    }
    final idM = widget.membresia['id'] as int;
    try {
      await DatabaseHelper.instance.setDiasMembresia(idM, _selected.toList());
      // update hora if changed
      final horaStr = widget.membresia['hora'] as String?;
      final nuevaHora = _horaSeleccionada != null
          ? '${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}'
          : null;
      if (nuevaHora != null && nuevaHora != horaStr) {
        await DatabaseHelper.instance.updateMembresiaHora(idM, nuevaHora);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Días y hora guardados')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error guardando: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar días y hora')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Frecuencia: $_frecuencia veces por semana',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: 7,
                itemBuilder: (context, i) {
                  final diaIndex = i + 1; // 1 = Lunes
                  final nombre = _diasNombres[i];
                  final selected = _selected.contains(diaIndex);
                  return CheckboxListTile(
                    title: Text(nombre),
                    value: selected,
                    onChanged: (v) {
                      if (v == true) {
                        if (_selected.length >= _frecuencia) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Solo puede seleccionar $_frecuencia días',
                              ),
                            ),
                          );
                          return;
                        }
                        setState(() => _selected.add(diaIndex));
                      } else {
                        setState(() => _selected.remove(diaIndex));
                      }
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hora: ${_horaSeleccionada?.format(context) ?? '-'}',
                  ),
                ),
                TextButton(
                  onPressed: _pickHora,
                  child: const Text('Seleccionar hora'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _save, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
