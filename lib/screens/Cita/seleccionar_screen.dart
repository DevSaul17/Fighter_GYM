import 'package:flutter/material.dart';

class SeleccionarScreen extends StatelessWidget {
  const SeleccionarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horarios = [
      {'texto': 'LUNES 11:00 a 12:00 AM   ＋', 'color': Colors.black, 'align': Alignment.centerLeft},
      {'texto': 'MARTES 16:00 a 17:00 PM   ＋', 'color': Colors.red, 'align': Alignment.centerRight},
      {'texto': 'MIÉRCOLES 10:00 a 11:00 AM   ＋', 'color': Colors.black, 'align': Alignment.centerLeft},
      {'texto': 'JUEVES 14:00 a 15:00 PM   ＋', 'color': Colors.red, 'align': Alignment.centerRight},
      {'texto': 'VIERNES 9:00 a 10:00 AM   ＋', 'color': Colors.black, 'align': Alignment.centerLeft},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        toolbarHeight: 80,
        centerTitle: true,
        title: const Text('SELECCIONAR HORARIOS',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
        ),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '<',
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
  

            // Lista en zigzag
            Expanded(
              child: ListView.builder(
                itemCount: horarios.length,
                itemBuilder: (context, index) {
                  final horario = horarios[index];
                  return Align(
                    alignment: horario['align'] as Alignment,
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: index == horarios.length - 1 ? 70 : 14, // más espacio al final
                      ),
                      width: 280,
                      height: 77,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: horario['color'] as Color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          horario['texto'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/confirmacion');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'REGISTRAR CITA',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
