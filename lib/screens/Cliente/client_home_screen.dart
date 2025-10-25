import 'package:flutter/material.dart';
import 'dart:async';
import '../../constants.dart';
import '../../routes.dart';

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

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _timer?.cancel();
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
      _timerRemaining = _timerDuration;
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
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Bienvenido devuelta,\n${widget.clienteNombre != null && widget.clienteNombre!.isNotEmpty ? widget.clienteNombre!.toUpperCase() : ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.registrarHorario),
                  child: Container(
                    height: 110,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'REGISTRAR\nHORARIO 📅',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 110,
                  margin: const EdgeInsets.only(left: 0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Peso: ${_formatDouble(widget.clientePeso)} kg\nTalla: ${_formatDouble(widget.clienteTalla, decimals: 2)} mts',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDuration(_stopwatchElapsed),
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _stopwatchRunning ? _stopStopwatch : _startStopwatch,
                child: Text(_stopwatchRunning ? 'Detener' : 'Iniciar'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _resetStopwatch,
                child: const Text('Reiniciar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDuration(_timerRemaining),
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _timerRunning ? _stopTimer : _startTimer,
                child: Text(_timerRunning ? 'Detener' : 'Iniciar'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _resetTimer,
                child: const Text('Reiniciar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
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
    );
  }

  Widget _buildUndefined() => const Center(child: Text('por definir'));

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
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: null,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Cronómetro'),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_bottom),
            label: 'Temporizador',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Por definir',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
