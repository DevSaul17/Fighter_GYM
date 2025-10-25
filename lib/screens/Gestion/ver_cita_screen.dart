import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../routes.dart';
import '../../widgets/gym_button.dart';

class VerCitaScreen extends StatelessWidget {
  const VerCitaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppText.gestionar), centerTitle: true),
      // Dos botones: 'Citas' y 'Horarios de citas'
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FractionallySizedBox(
              widthFactor: 0.9,
              child: GymButton(
                label: AppText.citas,
                onPressed: () => Navigator.pushNamed(context, Routes.citas),
              ),
            ),
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.9,
              child: GymButton(
                label: AppText.horariosCitas,
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.horariosCitas),
              ),
            ),
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.9,
              child: GymButton(
                label: AppText.cliente,
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.gestionarCliente),
              ),
            ),
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.9,
              child: GymButton(
                label: 'Negocio',
                onPressed: () => Navigator.pushNamed(context, Routes.negocio),
              ),
            ),
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.9,
              child: GymButton(
                label: 'Membresía',
                onPressed: () => Navigator.pushNamed(context, Routes.membresia),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
