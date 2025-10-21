import 'package:flutter/services.dart';

// Normaliza nombres: trim, colapsa espacios múltiples y capitaliza cada palabra
String normalizeName(String input) {
  final parts = input.trim().replaceAll(RegExp(r'\s+'), ' ').split(' ');
  return parts
      .map((w) {
        if (w.isEmpty) return '';
        return w[0].toUpperCase() +
            (w.length > 1 ? w.substring(1).toLowerCase() : '');
      })
      .join(' ');
}

// Parsea texto decimal aceptando coma o punto, devuelve null si inválido
double? parseDecimal(String? input) {
  if (input == null) return null;
  final text = input.replaceAll(',', '.').trim();
  return double.tryParse(text);
}

// Calcula BMI dado peso(kg) y talla(m). Si talla parece en cm (>3), lo convierte a m.
double? calculateBmi(String? pesoText, String? tallaText) {
  final peso = parseDecimal(pesoText);
  var talla = parseDecimal(tallaText);
  if (peso == null || talla == null) return null;
  if (talla > 3) talla = talla / 100.0;
  if (talla <= 0) return null;
  return peso / (talla * talla);
}

// Validadores simples que devuelven String? (mensaje de error) o null si válido
String? validateName(String? v) {
  if (v == null || v.trim().isEmpty) return 'Requerido';
  final normalized = v.trim();
  if (normalized.length < 2) return 'Mínimo 2 caracteres';
  if (normalized.length > 50) return 'Máximo 50 caracteres';
  final valid = RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿñÑ\s-]{2,50}").hasMatch(normalized);
  if (!valid) return 'Sólo letras, espacios y guion';
  return null;
}

String? validatePeruPhone(String? v) {
  if (v == null || v.trim().isEmpty) return 'Requerido';
  final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length != 9) return 'El celular en Perú debe tener 9 dígitos';
  if (!digits.startsWith('9')) return 'El celular debe iniciar con 9';
  return null;
}

String? validateEdad(String? v) {
  if (v == null || v.trim().isEmpty) return 'Requerido';
  final age = int.tryParse(v);
  if (age == null) return 'Edad inválida';
  if (age < 13 || age > 100) return 'Edad debe estar entre 13 y 100';
  return null;
}

String? validatePeso(String? v) {
  if (v == null || v.trim().isEmpty) return 'Requerido';
  final peso = parseDecimal(v);
  if (peso == null) return 'Peso inválido';
  if (peso < 30 || peso > 200) return 'Peso debe estar entre 30 y 200 kg';
  return null;
}

String? validateTalla(String? v) {
  if (v == null || v.trim().isEmpty) return 'Requerido';
  final tallaRaw = parseDecimal(v);
  if (tallaRaw == null) return 'Talla inválida';
  var talla = tallaRaw;
  if (talla > 3) talla = talla / 100.0;
  if (talla < 1.2 || talla > 2.5) return 'Talla debe estar entre 1.20 y 2.50 m';
  return null;
}

// Formateador simple para celular en Perú: agrupa en bloques de 3 (ej. 912 345 678)
class PeruPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 9; i++) {
      buffer.write(digits[i]);
      if ((i == 2 || i == 5) && i != digits.length - 1) buffer.write(' ');
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
