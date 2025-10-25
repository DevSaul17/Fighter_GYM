import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../database/database_helper.dart';
import 'client_home_screen.dart';

class IniciarSesionScreen extends StatefulWidget {
  const IniciarSesionScreen({super.key});

  @override
  State<IniciarSesionScreen> createState() => _IniciarSesionScreenState();
}

class _IniciarSesionScreenState extends State<IniciarSesionScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.of(context).size.width * 0.08;

    return Scaffold(
      appBar: AppBar(title: const Text('INICIO SESION'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  AppText.appTitle,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 36),

              const Text(
                'USUARIO',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'CONTRASEÑA',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () async {
                  final dni = _userController.text.trim();
                  final pass = _passController.text;
                  if (dni.isEmpty || pass.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ingrese DNI y contraseña')),
                    );
                    return;
                  }

                  try {
                    final cliente = await DatabaseHelper.instance
                        .getClienteByDni(dni);
                    if (cliente == null) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Usuario no encontrado')),
                      );
                      return;
                    }

                    final stored = (cliente['contrasena_hash'] ?? '')
                        .toString();
                    // Nota: actualmente la aplicación almacena la contraseña tal cual en contrasena_hash.
                    // En el futuro se debería usar hashing (bcrypt/argon2) y comparar el hash.
                    if (stored != pass) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contraseña incorrecta')),
                      );
                      return;
                    }

                    // Credenciales válidas -> navegar a pantalla principal del cliente
                    if (!mounted) return;
                    final nombreCompleto =
                        '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}'
                            .trim();
                    final double? peso = cliente['peso'] != null
                        ? (cliente['peso'] as num).toDouble()
                        : null;
                    final double? talla = cliente['talla'] != null
                        ? (cliente['talla'] as num).toDouble()
                        : null;
                    Navigator.pushReplacement(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientHomeScreen(
                          clienteNombre: nombreCompleto.isEmpty
                              ? null
                              : nombreCompleto,
                          clientePeso: peso,
                          clienteTalla: talla,
                        ),
                      ),
                    );
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al iniciar sesión: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  foregroundColor: AppColors.buttonText,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'INICIAR SESION',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
