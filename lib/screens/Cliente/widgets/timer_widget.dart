import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final String display;
  final bool running;
  final VoidCallback onStartStop;
  final VoidCallback onReset;
  final VoidCallback onPickDuration;

  const TimerWidget({
    super.key,
    required this.display,
    required this.running,
    required this.onStartStop,
    required this.onReset,
    required this.onPickDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            display,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: onStartStop,
                child: Text(running ? 'Detener' : 'Iniciar'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onReset,
                child: const Text('Reiniciar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onPickDuration,
            child: const Text('Seleccionar duración'),
          ),
        ],
      ),
    );
  }
}
