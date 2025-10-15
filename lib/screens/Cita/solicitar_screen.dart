import 'package:flutter/material.dart';

class SolicitarScreen extends StatelessWidget {
  const SolicitarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> objetivos = [
      '----Seleccionar----',
      'Movilidad, coordinación y fuerza',
      'Fortalecimiento muscular',
      'Quemar de grasa',
      'Entrenamiento funcional',
    ];

    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.black,
      centerTitle: true,
      title: const Text('Solicitar primera cita'),
      leading: TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
      '<',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        ),
      ),
    ),
    ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SOLICITAR PRIMERA CITA',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _inputField('NOMBRE'),
              _inputField('APELLIDOS'),
              _inputField('CELULAR'),
              _inputField('EDAD'),
              _inputField('PESO / KG'),
              _inputField('TALLA'),
              const SizedBox(height: 12),
              const Text('GÉNERO',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Masculino'),
                      value: 'Masculino',
                      groupValue: null,
                      onChanged: (_) {},
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Femenino'),
                      value: 'Femenino',
                      groupValue: null,
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'OBJETIVOS / NECESIDAD',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF2F2F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                items: objetivos
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (_) {},
                hint: const Text('----Seleccionar----'),
              ),
              const SizedBox(height: 100), // espacio final antes del botón
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/seleccionar');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text(
            'Solicitar',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}
