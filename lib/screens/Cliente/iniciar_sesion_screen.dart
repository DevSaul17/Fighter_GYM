import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              const SizedBox(height: 16),

              // App logo below the title (responsive larger size)
              LayoutBuilder(
                builder: (context, constraints) {
                  final double logoHeight =
                      (MediaQuery.of(context).size.width * 0.33).clamp(
                        120.0,
                        300.0,
                      );
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/login1.jpg',
                          height: logoHeight,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'USUARIO',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _userController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 12,
                decoration: InputDecoration(
                  counterText: '',
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
                    // validate format before querying to avoid unexpected input
                    if (!DatabaseHelper.instance.isValidDni(dni)) {
                      if (!mounted) return;
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                            'DNI inválido. Ingrese solo números.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    final cliente = await DatabaseHelper.instance
                        .getClienteByDni(dni);
                    if (cliente == null) {
                      if (!mounted) return;
                      showDialog<void>(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                            'Error al ingresar las credenciales',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    final stored = (cliente['contrasena_hash'] ?? '')
                        .toString();
                    final verified = DatabaseHelper.instance.verifyPassword(
                      pass,
                      stored,
                    );
                    if (!verified) {
                      if (!mounted) return;
                      showDialog<void>(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                            'Error al ingresar las credenciales',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
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
