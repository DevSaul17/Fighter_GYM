import 'package:flutter/material.dart';
import '../../constants.dart';

class CitasScreen extends StatelessWidget {
  const CitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppText.citas), centerTitle: true),
      // Pantalla vacía para 'Citas'
      body: const SizedBox.shrink(),
    );
  }
}
