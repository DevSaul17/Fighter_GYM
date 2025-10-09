import 'package:flutter/material.dart';
import '../constants.dart';
import '../routes.dart';
import '../widgets/gym_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.of(context).size.width * 0.1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppText.appTitle),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GymButton(
              label: AppText.iniciarSesion,
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.iniciarSesion),
            ),
            const SizedBox(height: 20),
            GymButton(
              label: AppText.solicitarAqui,
              onPressed: () => Navigator.pushNamed(context, Routes.solicitar),
            ),
          ],
        ),
      ),
    );
  }
}
