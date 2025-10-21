import 'package:flutter/material.dart'; // Flutter UI toolkit
import '../../routes.dart'; // Archivo con rutas nombradas (Routes.seleccionar, Routes.solicitar, etc.)

class SeleccionarScreen extends StatefulWidget {
  const SeleccionarScreen({super.key});

  @override
  State<SeleccionarScreen> createState() => _SeleccionarScreenState();
}

class _SeleccionarScreenState extends State<SeleccionarScreen> {
  int? _selectedIndex; // Índice del horario seleccionado (null = ninguno)

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
                itemCount: horarios.length,
                itemBuilder: (context, index) {
                  final horario = horarios[index];
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
                                  horario['dia'] as String,
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
                                  horario['hora'] as String,
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
                          // Navega a la pantalla de solicitud con la selección
                          Navigator.pushNamed(context, Routes.solicitar);
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
