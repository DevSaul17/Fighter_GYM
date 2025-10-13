import 'package:flutter/material.dart';
import 'constants.dart';
import 'routes.dart';
import 'screens/home_screen.dart';
import 'screens/Cliente/iniciar_sesion_screen.dart';
import 'screens/Cita/solicitar_screen.dart';
import 'screens/Cliente/client_home_screen.dart';
import 'screens/Cliente/registrar_horario_screen.dart';
import 'screens/Cliente/calendario_screen.dart';

void main() => runApp(const FightsGymApp());

class FightsGymApp extends StatelessWidget {
  const FightsGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppText.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.primary as MaterialColor,
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      ),
      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) => const HomeScreen(),
        Routes.iniciarSesion: (_) => const IniciarSesionScreen(),
        Routes.solicitar: (_) => const SolicitarScreen(),
        Routes.clientHome: (_) => const ClientHomeScreen(),
        Routes.registrarHorario: (_) => const RegistrarHorarioScreen(),
        Routes.calendario: (_) => const CalendarioScreen(),
      },
    );
  }
}
