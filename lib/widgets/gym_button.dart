import 'package:flutter/material.dart';
import '../constants.dart';

class GymButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const GymButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.buttonText,
        backgroundColor: AppColors.buttonBackground,
        minimumSize: const Size(double.infinity, 48),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }
}
