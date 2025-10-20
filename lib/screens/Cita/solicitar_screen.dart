import 'package:flutter/material.dart';

class SolicitarScreen extends StatefulWidget {
  const SolicitarScreen({super.key});

  @override
  State<SolicitarScreen> createState() => _SolicitarScreenState();
}

class _SolicitarScreenState extends State<SolicitarScreen> {
  String? _selectedGender;

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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        toolbarHeight: 80,
        centerTitle: true,
        title: const Text('SOLICITAR PRIMERA CITA',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '<',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
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
              const SizedBox(height: 34),
              _inputField('NOMBRE'),
              _inputField('APELLIDOS'),
              _inputField('CELULAR'),
              _inputField('EDAD'),
              _inputField('PESO / KG'),
              _inputField('TALLA'),
              const SizedBox(height: 22),
              const Text(
                'GÉNERO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Builder(
                builder: (context) {
                  final double screenWidth = MediaQuery.of(context).size.width;
                  // outer padding is 24 left + 24 right = 48
                  final double usableWidth = screenWidth - 48;
                  // spacing between the two options
                  const double between = 12;
                  final double optionWidth = (usableWidth - between) / 2;

                  return Row(
                    children: [
                      SizedBox(
                        width: optionWidth * 0.95, // slightly narrower
                        height: 60, // increased height
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedGender = 'Masculino'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedGender == 'Masculino'
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _selectedGender == 'Masculino'
                                    ? Colors.blue
                                    : const Color(0xFFCCCCCC),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Masculino',
                                  style: TextStyle(
                                    color: _selectedGender == 'Masculino'
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _selectedGender == 'Masculino'
                                        ? Colors.white
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: _selectedGender == 'Masculino'
                                          ? Colors.white
                                          : const Color(0xFF9E9E9E),
                                    ),
                                  ),
                                  child: _selectedGender == 'Masculino'
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.blue,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: between),
                      SizedBox(
                        width: optionWidth * 0.95,
                        height: 60,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedGender = 'Femenino'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedGender == 'Femenino'
                                  ? Colors.pink
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _selectedGender == 'Femenino'
                                    ? Colors.pink
                                    : const Color(0xFFCCCCCC),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Femenino',
                                  style: TextStyle(
                                    color: _selectedGender == 'Femenino'
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _selectedGender == 'Femenino'
                                        ? Colors.white
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: _selectedGender == 'Femenino'
                                          ? Colors.white
                                          : const Color(0xFF9E9E9E),
                                    ),
                                  ),
                                  child: _selectedGender == 'Femenino'
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.pink,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
            minimumSize: const Size.fromHeight(65), // altura del botón
            
          ),
          child: const Text(
            'Solicitar',
            style: TextStyle(color: Colors.white, fontSize: 20),
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
