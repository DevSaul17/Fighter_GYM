import 'package:flutter/material.dart';
import '../../constants.dart';

class IniciarSesionScreen extends StatelessWidget {
  const IniciarSesionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          AppText.pantallaIniciar,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
