import 'package:flutter/material.dart';
import '../constants.dart';
import '../routes.dart';
import '../widgets/gym_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.of(context).size.width * 0.1;
    final buttonWidthFactor = 0.55; // 40% del ancho disponible

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppText.appTitle,
          style: TextStyle(
            fontSize: 42, // Tamaño aumentado
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 110, // Más espacio para el texto adicional
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            SizedBox(height: 70), // Espacio para bajar el texto
            // Espacio entre appTitle y fuerzaMovilidad
            SizedBox(height: 12),
            Text(
              AppText.fuerzaMovilidad,
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: buttonWidthFactor,
                child: GymButton(
                  label: AppText.iniciarSesion,
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.iniciarSesion),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Imagen entre los botones
            Image.asset(
              'assets/main1.jpg', // Cambia la ruta por la de tu imagen
              height: 320, // Ajusta el tamaño si lo deseas
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: buttonWidthFactor,
                child: GymButton(
                  label: AppText.solicitarAqui,
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.solicitar),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
