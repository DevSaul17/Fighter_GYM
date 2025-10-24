import 'package:flutter/material.dart'; // Flutter UI toolkit
import '../../routes.dart'; // Archivo con rutas nombradas (Routes.seleccionar, Routes.solicitar, etc.)
import '../../database/database_helper.dart';

class SeleccionarScreen extends StatefulWidget {
  const SeleccionarScreen({super.key});

  @override
  State<SeleccionarScreen> createState() => _SeleccionarScreenState();
}

class _SeleccionarScreenState extends State<SeleccionarScreen> {
  int? _selectedIndex; // Índice del horario seleccionado (null = ninguno)
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

  @override
  Widget build(BuildContext context) {
    // Cada entrada es un mapa con: 'texto' (String), 'color' (Color) y 'align' (Alignment).
    // Para añadir/quitar horarios modifica este array.
    // Cada horario ahora tiene 'dia' y 'hora' separados para permitir formato en dos líneas
    final horarios = [
      {
        'dia': 'LUNES',
        'hora': '11:00 a 12:00 AM',
        'color': Colors.black,
        'align': Alignment.centerLeft,
      },
      {
        'dia': 'MARTES',
        'hora': '16:00 a 17:00 PM',
        'color': Colors.red,
        'align': Alignment.centerRight,
      },
      {
        'dia': 'MIÉRCOLES',
        'hora': '10:00 a 11:00 AM',
        'color': Colors.black,
        'align': Alignment.centerLeft,
      },
      {
        'dia': 'JUEVES',
        'hora': '14:00 a 15:00 PM',
        'color': Colors.red,
        'align': Alignment.centerRight,
      },
      {
        'dia': 'VIERNES',
        'hora': '9:00 a 10:00 AM',
        'color': Colors.black,
        'align': Alignment.centerLeft,
      },
    ];

    // Si hay citas en la BD, mapearlas a un formato similar a `horarios`.
    final displayed = <Map<String, dynamic>>[];
    if (_citas.isNotEmpty) {
      // Alternar alineación/colores para mantener estilo zigzag
      for (var i = 0; i < _citas.length; i++) {
        final c = _citas[i];
        // Esperamos fecha en formato 'YYYY-MM-DD' y hora 'HH:mm'
        String fechaStr = c['fecha'] as String? ?? '';
        String horaStr = c['hora'] as String? ?? '';
        String diaStr = '';
        try {
          final dt = DateTime.parse(fechaStr);
          const dias = [
            'LUNES',
            'MARTES',
            'MIÉRCOLES',
            'JUEVES',
            'VIERNES',
            'SÁBADO',
            'DOMINGO',
          ];
          // DateTime.weekday: 1 = Monday
          diaStr = dias[dt.weekday - 1];
          // Formato de fecha DD/MM/YYYY
          fechaStr =
              '${dt.day.toString().padLeft(2, '0')}/'
              '${dt.month.toString().padLeft(2, '0')}/'
              '${dt.year}';
        } catch (_) {
          // si no se puede parsear, dejar la cadena original
        }

        displayed.add({
          'id': c['id'],
          'dia': diaStr,
          'fecha': fechaStr,
          'hora': horaStr,
          'color': i % 2 == 0 ? Colors.black : Colors.red,
          'align': i % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
        });
      }
    }

    // Scaffold es la estructura principal de la pantalla: AppBar, body, bottom widgets.
    return Scaffold(
      backgroundColor:
          Colors.white, // Fondo de pantalla (ajústalo si quieres otro color)
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
          255,
          255,
          255,
          255,
        ), // Color del AppBar
        toolbarHeight: 80, // Altura del AppBar
        centerTitle: true, // Centrar el título
        title: const Text(
          'SELECCIONAR HORARIOS', // Título que aparece en el AppBar
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: TextButton(
          // Botón izquierdo del AppBar. Por defecto hace `Navigator.pop` para volver.
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '<', // Puedes cambiar por un Icon(Icons.arrow_back)
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Lista en zigzag (los elementos alternan posición por `alignment`)
            Expanded(
              child: ListView.builder(
                itemCount: (displayed.isNotEmpty ? displayed : horarios).length,
                itemBuilder: (context, index) {
                  final horario = (displayed.isNotEmpty
                      ? displayed
                      : horarios)[index];
                  // Si este índice está seleccionado
                  final bool isSelected = _selectedIndex == index;

                  // Cada fila usa Align para posicionarla a la izquierda o derecha
                  return Align(
                    alignment: horario['align'] as Alignment,
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: index == horarios.length - 1 ? 70 : 14,
                      ),
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 88,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Colors.white
                              : (horario['color'] as Color),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: isSelected
                                ? const BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  )
                                : BorderSide.none,
                          ),
                        ),
                        onPressed: () => setState(() => _selectedIndex = index),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Día arriba, hora abajo
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (horario['dia'] as String?) ?? '',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  // Mostrar fecha y hora en la segunda línea
                                  '${(horario['fecha'] as String?) ?? ''}  ${(horario['hora'] as String?) ?? ''}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            // Indicador a la derecha: '+' por defecto, '✓' si está seleccionado
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white24,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.black,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.black,
                                      )
                                    : const Text(
                                        '+',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botón de acción inferior: centrado y con ancho relativo.
            // Cambia `width` y `minimumSize` para modificar ancho/altura.
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75, // 75% ancho
                child: ElevatedButton(
                  onPressed: _selectedIndex != null
                      ? () {
                          // Construir el mapa de cita seleccionado (puede venir de displayed o de horarios)
                          final source = (displayed.isNotEmpty
                              ? displayed
                              : horarios);
                          final selected = source[_selectedIndex!];
                          // Normalizar claves: id (opcional), fecha, hora, dia
                          final Map<String, dynamic> selectedCita = {
                            'id': selected.containsKey('id')
                                ? selected['id']
                                : null,
                            'fecha':
                                selected['fecha'] ?? selected['hora'] ?? '',
                            'hora': selected['hora'] ?? '',
                            'dia': selected['dia'] ?? '',
                          };
                          Navigator.pushNamed(
                            context,
                            Routes.solicitar,
                            arguments: selectedCita,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedIndex != null
                        ? Colors.black
                        : Colors.grey,
                    minimumSize: const Size.fromHeight(60), // Altura del botón
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Radio más grande
                    ),
                  ),
                  child: const Text(
                    'REGISTRAR HORARIO', // Texto del botón
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
