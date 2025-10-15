import 'package:flutter/material.dart';

class ConfirmacionScreen extends StatelessWidget {
  const ConfirmacionScreen({super.key});

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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Tu cita gratuita ha sido confirmada correctamente para el MARTES 23 en el horario de 16:00 a 17:00.\n\n¡Felicitaciones por dar el primer paso hacia tu bienestar!\n\n💪 Nos vemos pronto — prepárate para una experiencia que te hará sentir más fuerte, más enfocado y más motivado que nunca.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18, // texto más grande
                  height: 1.6, // más espacio entre líneas
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),
            Image.asset(
              'assets/ic_heartgym.jpg',
              width: 300,
              height: 200,
              fit: BoxFit.contain,
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
