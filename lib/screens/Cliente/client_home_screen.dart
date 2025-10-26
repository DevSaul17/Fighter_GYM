import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../constants.dart';
import '../../routes.dart';

// A simple circular progress painter. value is 0..1 where 1.0 = full circle.
class _CircleProgressPainter extends CustomPainter {
  final double value;
  final Color backgroundColor;
  final Color foregroundColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.value,
    required this.backgroundColor,
    required this.foregroundColor,
    this.strokeWidth = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // draw full faint circle (the mark that the circle was there)
    canvas.drawCircle(center, radius, bgPaint);

    // draw arc for current value (clockwise from top)
    final startAngle = -math.pi / 2; // 12 o'clock
    final sweepAngle = 2 * math.pi * value.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class CircleProgressIndicator extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;
  final double strokeWidth;

  const CircleProgressIndicator({
    super.key,
    required this.value,
    required this.size,
    required this.child,
    this.backgroundColor = const Color(0x22000000),
    this.foregroundColor = Colors.deepPurple,
    this.strokeWidth = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _CircleProgressPainter(
              value: value,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              strokeWidth: strokeWidth,
            ),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}

class ClientHomeScreen extends StatefulWidget {
  final String? clienteNombre;
  final double? clientePeso;
  final double? clienteTalla;
  const ClientHomeScreen({
    super.key,
    this.clienteNombre,
    this.clientePeso,
    this.clienteTalla,
  });

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

  // Stopwatch state
  Duration _stopwatchElapsed = Duration.zero;
  bool _stopwatchRunning = false;
  Timer? _stopwatchTimer;

  // Timer state
  Duration _timerDuration = const Duration(minutes: 1);
  Duration _timerRemaining = const Duration(minutes: 1);
  bool _timerRunning = false;
  Timer? _timer;

  // IMC calculator state (por definir)
  String _genero = 'M'; // 'M' masculino, 'F' femenino
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _tallaController = TextEditingController();
  double? _imcResult;
  String _imcCategoria = '';
  // UI theme helpers
  final Color _accentColor = Colors.deepPurple;

  ButtonStyle get _modernButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: _accentColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 6,
  );

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _timer?.cancel();
    _pesoController.dispose();
    _tallaController.dispose();
    super.dispose();
  }

  void _startStopwatch() {
    if (_stopwatchRunning) return;
    _stopwatchRunning = true;
    _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        _stopwatchElapsed += const Duration(milliseconds: 100);
      });
    });
  }

  void _stopStopwatch() {
    _stopwatchRunning = false;
    _stopwatchTimer?.cancel();
  }

  void _resetStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() {
      _stopwatchElapsed = Duration.zero;
      _stopwatchRunning = false;
    });
  }

  void _startTimer() {
    if (_timerRunning) return;
    setState(() {
      _timerRunning = true;
      // Do not reset _timerRemaining here so that 'Detener' -> 'Reanudar' resumes remaining time
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timerRemaining.inSeconds <= 1) {
        _timer?.cancel();
        setState(() {
          _timerRunning = false;
          _timerRemaining = Duration.zero;
        });
      } else {
        setState(() {
          _timerRemaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _timerRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timerRunning = false;
      _timerRemaining = _timerDuration;
    });
  }

  Widget _buildHomeContent() {
    final horizontalPadding = MediaQuery.of(context).size.width * 0.06;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 0),
          Center(
            child: Text(
              'Bienvenido devuelta,\n${widget.clienteNombre != null && widget.clienteNombre!.isNotEmpty ? widget.clienteNombre!.toUpperCase() : ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          // Moti image between welcome text and weight/talla box
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/moti.jpg',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                height: 140,
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Larger, more prominent weight/height card
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Builder(
                builder: (ctx) {
                  final double infoFontSize =
                      (MediaQuery.of(ctx).size.width * 0.055).clamp(18.0, 34.0);
                  return Text(
                    'Peso: ${_formatDouble(widget.clientePeso)} kg\nTalla: ${_formatDouble(widget.clienteTalla, decimals: 2)} mts',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: infoFontSize,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // motivational image between weight/talla box and calendar
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/moti2.jpg',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, Routes.calendario),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'CALENDARIO 📅',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDouble(double? v, {int decimals = 2}) {
    if (v == null) return '-';
    // If it's a whole number, show without decimals
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(decimals);
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final mins = two(d.inMinutes.remainder(60));
    final secs = two(d.inSeconds.remainder(60));
    final hours = two(d.inHours);
    return '$hours:$mins:$secs';
  }

  Widget _buildStopwatch() {
    final width = MediaQuery.of(context).size.width;
    final double fontSize = (width * 0.12).clamp(36.0, 72.0);
    final availHeight = math.max(
      300.0,
      MediaQuery.of(context).size.height * 0.6,
    );

    return SizedBox(
      height: availHeight,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'CronoGym',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            // Circular progress around stopwatch (shows seconds progress within minute)
            CircleProgressIndicator(
              size: (width * 0.68).clamp(160.0, 360.0),
              value: ((_stopwatchElapsed.inMilliseconds % 60000) / 60000.0),
              strokeWidth: 10,
              backgroundColor: Colors.black12,
              foregroundColor: _accentColor,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  _formatDuration(_stopwatchElapsed),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: _accentColor,
                    shadows: [
                      Shadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.15),
                        offset: const Offset(0, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: _modernButtonStyle,
                  onPressed: _stopwatchRunning
                      ? _stopStopwatch
                      : _startStopwatch,
                  child: Row(
                    children: [
                      Icon(_stopwatchRunning ? Icons.pause : Icons.play_arrow),
                      const SizedBox(width: 8),
                      Text(
                        _stopwatchRunning
                            ? 'Detener'
                            : (_stopwatchElapsed > Duration.zero
                                  ? 'Reanudar'
                                  : 'Iniciar'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                ElevatedButton(
                  style: _modernButtonStyle.copyWith(
                    backgroundColor: WidgetStatePropertyAll(
                      Colors.grey.shade700,
                    ),
                  ),
                  onPressed: _resetStopwatch,
                  child: Row(
                    children: const [
                      Icon(Icons.restart_alt),
                      SizedBox(width: 8),
                      Text('Reiniciar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final width = MediaQuery.of(context).size.width;
    final double fontSize = (width * 0.12).clamp(36.0, 72.0);
    final availHeight = math.max(
      300.0,
      MediaQuery.of(context).size.height * 0.6,
    );

    return SizedBox(
      height: availHeight,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'TempoGym',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            // Circular progress for timer (foreground arc shows remaining time)
            CircleProgressIndicator(
              size: (width * 0.68).clamp(160.0, 360.0),
              value: (_timerDuration.inSeconds > 0)
                  ? (_timerRemaining.inSeconds / _timerDuration.inSeconds)
                  : 0.0,
              strokeWidth: 10,
              backgroundColor: Colors.black12,
              foregroundColor: _accentColor,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  _formatDuration(_timerRemaining),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: _accentColor,
                    shadows: [
                      Shadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.15),
                        offset: const Offset(0, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: _modernButtonStyle,
                  onPressed: _timerRunning ? _stopTimer : _startTimer,
                  child: Row(
                    children: [
                      Icon(_timerRunning ? Icons.pause : Icons.play_arrow),
                      const SizedBox(width: 8),
                      Text(
                        _timerRunning
                            ? 'Detener'
                            : (_timerRemaining != _timerDuration &&
                                      _timerRemaining != Duration.zero
                                  ? 'Reanudar'
                                  : 'Iniciar'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                ElevatedButton(
                  style: _modernButtonStyle.copyWith(
                    backgroundColor: WidgetStatePropertyAll(
                      Colors.grey.shade700,
                    ),
                  ),
                  onPressed: _resetTimer,
                  child: Row(
                    children: const [
                      Icon(Icons.restart_alt),
                      SizedBox(width: 8),
                      Text('Reiniciar'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              style: _modernButtonStyle.copyWith(
                backgroundColor: WidgetStatePropertyAll(Colors.teal),
              ),
              onPressed: () async {
                // allow user to pick duration (simple presets)
                final choice = await showModalBottomSheet<int>(
                  context: context,
                  builder: (ctx) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('1 minuto'),
                        onTap: () => Navigator.pop(ctx, 1),
                      ),
                      ListTile(
                        title: const Text('5 minutos'),
                        onTap: () => Navigator.pop(ctx, 5),
                      ),
                      ListTile(
                        title: const Text('10 minutos'),
                        onTap: () => Navigator.pop(ctx, 10),
                      ),
                      ListTile(
                        title: const Text('30 minutos'),
                        onTap: () => Navigator.pop(ctx, 30),
                      ),
                    ],
                  ),
                );

                if (choice != null) {
                  setState(() {
                    _timerDuration = Duration(minutes: choice);
                    _timerRemaining = _timerDuration;
                  });
                }
              },
              child: const Text('Seleccionar duración'),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateImc() {
    final peso =
        double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0.0;
    final talla =
        double.tryParse(_tallaController.text.replaceAll(',', '.')) ?? 0.0;
    if (peso <= 0 || talla <= 0) {
      setState(() {
        _imcResult = null;
        _imcCategoria = 'Ingrese peso y talla válidos';
      });
      return;
    }

    // talla can be entered in meters (e.g., 1.75) or centimeters (>3 treated as cm)
    double tallaM = talla;
    if (talla > 3) {
      // assume cm
      tallaM = talla / 100.0;
    }

    final imc = peso / (tallaM * tallaM);
    String categoria;
    if (imc < 18.5) {
      categoria = 'Bajo peso';
    } else if (imc < 25) {
      categoria = 'Normal';
    } else if (imc < 30) {
      categoria = 'Sobrepeso';
    } else {
      categoria = 'Obesidad';
    }

    // You may adapt category interpretation by gender in the future
    setState(() {
      _imcResult = double.parse(imc.toStringAsFixed(2));
      _imcCategoria = categoria;
    });
  }

  Widget _buildUndefined() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Calculadora de IMC',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Género',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Masculino'),
                          value: 'M',
                          // ignore: deprecated_member_use
                          groupValue: _genero,
                          // ignore: deprecated_member_use
                          onChanged: (v) => setState(() => _genero = v ?? 'M'),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Femenino'),
                          value: 'F',
                          // ignore: deprecated_member_use
                          groupValue: _genero,
                          // ignore: deprecated_member_use
                          onChanged: (v) => setState(() => _genero = v ?? 'F'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pesoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      hintText: 'Ej. 70.5',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tallaController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Talla (m o cm)',
                      hintText: 'Ej. 1.75 o 175',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _calculateImc,
                    child: const Text('Calcular IMC'),
                  ),
                  const SizedBox(height: 12),
                  if (_imcResult != null) ...[
                    Text(
                      'IMC: ${_imcResult!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Categoría: $_imcCategoria',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Intensidad visual según IMC
                    _buildImcIntensityBar(),
                  ] else ...[
                    Text(
                      _imcCategoria,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImcIntensityBar() {
    if (_imcResult == null) return const SizedBox.shrink();
    const double maxImc = 40.0; // scale for bar
    final imc = _imcResult!.clamp(0.0, maxImc);

    // ranges
    const under = 18.5;
    const normalEnd = 24.9;
    const overEnd = 29.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Intensidad según IMC',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final uW = (under / maxImc) * w;
            final nW = ((normalEnd - under) / maxImc) * w;
            final oW = ((overEnd - normalEnd) / maxImc) * w;
            final obW = ((maxImc - overEnd) / maxImc) * w;
            final markerLeft = (imc / maxImc) * w - 8; // center marker

            return SizedBox(
              height: 36,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Row(
                    children: [
                      Container(
                        width: uW,
                        height: 12,
                        color: Colors.lightBlueAccent,
                      ),
                      Container(
                        width: nW,
                        height: 12,
                        color: Colors.lightGreen,
                      ),
                      Container(
                        width: oW,
                        height: 12,
                        color: Colors.orangeAccent,
                      ),
                      Container(
                        width: obW,
                        height: 12,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                  Positioned(
                    left: markerLeft.clamp(0.0, w - 16),
                    top: 0,
                    child: Column(
                      children: [
                        Icon(
                          Icons.monitor_weight,
                          size: 20,
                          color: Colors.black,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            imc.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Expanded(
              child: Text(
                'Bajo peso',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 12),
              ),
            ),
            Expanded(
              child: Text(
                'Normal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
            Expanded(
              child: Text(
                'Sobrepeso',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
            Expanded(
              child: Text(
                'Obesidad',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeContent(),
      _buildStopwatch(),
      _buildTimer(),
      _buildUndefined(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu, color: Colors.black),
        title: const Text(
          AppText.appTitle,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      // gradient background and centered responsive layout
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(child: pages[_currentIndex]),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    // Visual design per user: active color #0A84FF, inactive #9AA6B2
    const activeColor = Color(0xFF0A84FF);
    const inactiveColor = Color(0xFF9AA6B2);
    const barHeight = 90.0;

    final items = [
      {'icon': Icons.home, 'label': 'Inicio'},
      {'icon': Icons.timer, 'label': 'Cronómetro'},
      {'icon': Icons.hourglass_bottom, 'label': 'Temporizador'},
      {'icon': Icons.more_horiz, 'label': 'IMC'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        child: Container(
          height: barHeight,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final it = items[i];
              final isActive = i == _currentIndex;
              final icon = it['icon'] as IconData;
              final label = it['label'] as String;

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _currentIndex = i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: isActive ? 52 : 48,
                        height: isActive ? 52 : 48,
                        decoration: BoxDecoration(
                          color: isActive
                              // ignore: deprecated_member_use
                              ? activeColor.withOpacity(0.14)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            size: isActive ? 30 : 28,
                            color: isActive ? activeColor : inactiveColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive ? activeColor : inactiveColor,
                          fontFamily: 'Roboto',
                        ),
                        child: Text(label),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
