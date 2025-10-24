import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ConfirmacionScreen extends StatefulWidget {
  const ConfirmacionScreen({super.key});

  @override
  State<ConfirmacionScreen> createState() => _ConfirmacionScreenState();
}

class _ConfirmacionScreenState extends State<ConfirmacionScreen> {
  bool _loading = true;
  String? _nombreCompleto;
  String? _fechaStr;
  String? _horaStr;

  @override
  void initState() {
    super.initState();
    _loadLastRecord();
  }

  Future<void> _loadLastRecord() async {
    try {
      final prospectos = await DatabaseHelper.instance.getProspectos();
      if (prospectos.isNotEmpty) {
        // Elegir el prospecto con mayor id (último insert)
        Map<String, dynamic> last = prospectos.first;
        for (final p in prospectos) {
          if ((p['id'] as int?) != null && (last['id'] as int?) != null) {
            if ((p['id'] as int) > (last['id'] as int)) last = p;
          }
        }

        final nombres = (last['nombres'] as String?) ?? '';
        final apellidos = (last['apellidos'] as String?) ?? '';
        String? fecha;
        String? hora;
        final citaId = last['cita_id'] as int?;
        if (citaId != null) {
          final citas = await DatabaseHelper.instance.getCitas();
          for (final c in citas) {
            if ((c['id'] as int?) == citaId) {
              fecha = c['fecha'] as String?;
              hora = c['hora'] as String?;
              break;
            }
          }
        }

        setState(() {
          _nombreCompleto = '$nombres $apellidos'.trim();
          _fechaStr = fecha;
          _horaStr = hora;
        });
      }
    } catch (_) {
      // ignore errors and show default message
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formattedWhen({bool short = false}) {
    String defaultFull = 'para el MARTES 23 en el horario de 16:00 a 17:00.';
    String defaultShort = 'MARTES 23 — 16:00-17:00';
    if (_fechaStr != null && _horaStr != null) {
      try {
        final dt = DateTime.parse(_fechaStr!);
        const dias = [
          'LUNES',
          'MARTES',
          'MIÉRCOLES',
          'JUEVES',
          'VIERNES',
          'SÁBADO',
          'DOMINGO',
        ];
        final dia = dias[dt.weekday - 1];
        final fechaForm =
            '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/'
            '${dt.year}';
        final full = 'para el $dia $fechaForm en el horario de $_horaStr.';
        final shortStr = '$dia $fechaForm — $_horaStr';
        return short ? shortStr : full;
      } catch (_) {
        final full = 'para la fecha $_fechaStr en el horario de $_horaStr.';
        final shortStr = '$_fechaStr — $_horaStr';
        return short ? shortStr : full;
      }
    }
    return short ? defaultShort : defaultFull;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              '🎉 ¡Cita registrada con éxito!',
              style: TextStyle(
                fontSize: 26, // más grande
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_nombreCompleto != null &&
                            _nombreCompleto!.isNotEmpty)
                          Text(
                            _nombreCompleto!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        if ((_fechaStr != null && _horaStr != null) ||
                            _nombreCompleto != null)
                          const SizedBox(height: 8),
                        if (_fechaStr != null && _horaStr != null)
                          Text(
                            _formattedWhen(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 12),
                        Text(
                          'Tu cita gratuita ha sido confirmada correctamente',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '¡Felicitaciones por dar el primer paso hacia tu bienestar!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '💪 Nos vemos pronto — prepárate para una experiencia que te hará sentir más fuerte, más enfocado y más motivado que nunca.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.22,
              child: Image.asset('assets/ic_heartgym.jpg', fit: BoxFit.contain),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text(
            'VOLVER AL INICIO',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
