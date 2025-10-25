import 'package:flutter/material.dart';

import '../../database/database_helper.dart';

class InformesScreen extends StatefulWidget {
  const InformesScreen({super.key});

  @override
  State<InformesScreen> createState() => _InformesScreenState();
}

class _InformesScreenState extends State<InformesScreen> {
  bool _loading = true;

  final Map<String, double> _earningsPerMonth = {};
  double _earningsCurrentMonth = 0.0;
  final Map<String, double> _earningsPerClient = {};
  final Map<String, double> _earningsPerPlan = {};
  final Map<String, double> _earningsPerFrequency = {};

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
      _earningsPerMonth.clear();
      _earningsPerClient.clear();
      _earningsPerPlan.clear();
      _earningsPerFrequency.clear();
      _earningsCurrentMonth = 0.0;
    });

    try {
      final pagos = await DatabaseHelper.instance.getPagos();

      final Map<int, Map<String, dynamic>?> membCache = {};
      final now = DateTime.now();

      for (final p in pagos) {
        final monto = (p['monto'] as num?)?.toDouble() ?? 0.0;

        DateTime fecha;
        final fechaStr = p['fecha_pago'] as String?;
        if (fechaStr != null) {
          try {
            fecha = DateTime.parse(fechaStr);
          } catch (_) {
            fecha = DateTime.now();
          }
        } else {
          fecha = DateTime.now();
        }

        final monthKey =
            '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';
        _earningsPerMonth.update(
          monthKey,
          (v) => v + monto,
          ifAbsent: () => monto,
        );

        if (fecha.year == now.year && fecha.month == now.month) {
          _earningsCurrentMonth += monto;
        }

        final clienteName =
            '${p['cliente_nombres'] ?? ''} ${p['cliente_apellidos'] ?? ''}'
                .trim();
        final clientKey = clienteName.isEmpty ? 'Sin cliente' : clienteName;
        _earningsPerClient.update(
          clientKey,
          (v) => v + monto,
          ifAbsent: () => monto,
        );

        final clienteId = (p['id_cliente'] as int?);
        Map<String, dynamic>? memb;
        if (clienteId != null) {
          if (membCache.containsKey(clienteId)) {
            memb = membCache[clienteId];
          } else {
            memb = await DatabaseHelper.instance.getMembresiaByCliente(
              clienteId,
            );
            membCache[clienteId] = memb;
          }
        }

        final planName = memb != null
            ? (memb['plan_nombre'] ?? 'Sin plan')
            : 'Sin plan';
        _earningsPerPlan.update(
          planName,
          (v) => v + monto,
          ifAbsent: () => monto,
        );

        final freq = memb != null
            ? (memb['frecuencia'] as num?)?.toInt()
            : null;
        final freqKey = freq == null ? 'Sin frecuencia' : 'Frecuencia: $freq';
        _earningsPerFrequency.update(
          freqKey,
          (v) => v + monto,
          ifAbsent: () => monto,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando informes: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _sumMapValues(Map<String, double> m) =>
      m.values.fold(0.0, (a, b) => a + b);

  // helper for formatting could be used later

  Widget _buildSection(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informes'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refrescar',
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSection(
                      'Ganancias totales por mes',
                      Column(
                        children: [
                          ..._earningsPerMonth.entries
                              .toList()
                              .reversed
                              .map(
                                (e) => ListTile(
                                  dense: true,
                                  title: Text(e.key),
                                  trailing: Text(e.value.toStringAsFixed(2)),
                                ),
                              )
                              ,
                          const Divider(),
                          ListTile(
                            dense: true,
                            title: const Text('Total'),
                            trailing: Text(
                              _sumMapValues(
                                _earningsPerMonth,
                              ).toStringAsFixed(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSection(
                      'Ganancias del mes actual',
                      Column(
                        children: [
                          ListTile(
                            title: Text(
                              '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
                            ),
                            trailing: Text(
                              _earningsCurrentMonth.toStringAsFixed(2),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            dense: true,
                            title: const Text('Total mes actual'),
                            trailing: Text(
                              _earningsCurrentMonth.toStringAsFixed(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSection(
                      'Por cliente',
                      Column(
                        children: [
                          ..._earningsPerClient.entries
                              .toList()
                              .map(
                                (e) => ListTile(
                                  dense: true,
                                  title: Text(e.key),
                                  trailing: Text(e.value.toStringAsFixed(2)),
                                ),
                              )
                              ,
                          const Divider(),
                          ListTile(
                            dense: true,
                            title: const Text('Total clientes'),
                            trailing: Text(
                              _sumMapValues(
                                _earningsPerClient,
                              ).toStringAsFixed(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSection(
                      'Por plan',
                      Column(
                        children: [
                          ..._earningsPerPlan.entries
                              .toList()
                              .map(
                                (e) => ListTile(
                                  dense: true,
                                  title: Text(e.key),
                                  trailing: Text(e.value.toStringAsFixed(2)),
                                ),
                              )
                              ,
                          const Divider(),
                          ListTile(
                            dense: true,
                            title: const Text('Total por plan'),
                            trailing: Text(
                              _sumMapValues(
                                _earningsPerPlan,
                              ).toStringAsFixed(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSection(
                      'Por frecuencia',
                      Column(
                        children: [
                          ..._earningsPerFrequency.entries
                              .toList()
                              .map(
                                (e) => ListTile(
                                  dense: true,
                                  title: Text(e.key),
                                  trailing: Text(e.value.toStringAsFixed(2)),
                                ),
                              )
                              ,
                          const Divider(),
                          ListTile(
                            dense: true,
                            title: const Text('Total por frecuencia'),
                            trailing: Text(
                              _sumMapValues(
                                _earningsPerFrequency,
                              ).toStringAsFixed(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
