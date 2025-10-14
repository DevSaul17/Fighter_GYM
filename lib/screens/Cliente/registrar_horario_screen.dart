import 'package:flutter/material.dart';

class RegistrarHorarioScreen extends StatefulWidget {
  const RegistrarHorarioScreen({super.key});

  @override
  State<RegistrarHorarioScreen> createState() => _RegistrarHorarioScreenState();
}

class _RegistrarHorarioScreenState extends State<RegistrarHorarioScreen> {
  final Map<String, List<String>> groups = {
    'LUNES - MIERCOLES - VIERNES': [
      '10:00 am - 11:00 am',
      '11:00 am - 12:00 am',
      '13:00 pm - 14:00 pm',
      '14:00 pm - 15:00 pm',
    ],
    'MARTES - JUEVES - SABADO': [
      '10:00 am - 11:00 am',
      '11:00 am - 12:00 am',
      '13:00 pm - 14:00 pm',
      '14:00 pm - 15:00 pm',
    ],
  };

  String? _selectedGroup;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedGroup = groups.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SELECCIONAR HORARIO'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          children: [
            // Collapsible lists: one ExpansionTile per group containing its times
            Expanded(
              child: ListView.builder(
                itemCount: groups.keys.length,
                itemBuilder: (context, index) {
                  final g = groups.keys.elementAt(index);
                  final times = groups[g]!;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      title: Text(
                        g,
                        style: TextStyle(
                          color: g == _selectedGroup
                              ? Colors.black
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: g == _selectedGroup
                          ? Colors.white
                          : Colors.white,
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: times.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final t = times[i];
                            final selected =
                                _selectedTime == t && _selectedGroup == g;
                            return ListTile(
                              title: Text(t),
                              trailing: selected
                                  ? const Icon(Icons.check, color: Colors.red)
                                  : null,
                              onTap: () {
                                // Save selection and keep user on this screen
                                setState(() {
                                  _selectedGroup = g;
                                  _selectedTime = t;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _selectedTime == null
                  ? null
                  : () async {
                      final t = _selectedTime!;
                      await showDialog(
                        context: context,
                        builder: (dctx) => AlertDialog(
                          title: const Text('Horario registrado correctamente'),
                          content: Text('Has registrado: $t'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dctx).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'REGISTRAR HORARIO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
