import 'package:flutter/material.dart';
import '../../constants.dart';

class SolicitarScreen extends StatelessWidget {
  const SolicitarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          AppText.pantallaSolicitar,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
