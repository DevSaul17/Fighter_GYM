import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../routes.dart';
import '../../database/database_helper.dart';
import 'solicitar_validations.dart';

class SolicitarScreen extends StatefulWidget {
  const SolicitarScreen({super.key});

  @override
  State<SolicitarScreen> createState() => _SolicitarScreenState();
}

class _SolicitarScreenState extends State<SolicitarScreen> {
  String? _selectedGender;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _tallaController = TextEditingController();

  String? _selectedObjetivo;
  double? _bmi;
  Map<String, dynamic>? _selectedCita;
  List<String> _objetivos = [];

  @override
  void initState() {
    super.initState();
    _loadObjetivos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && _selectedCita == null) {
      try {
        _selectedCita = Map<String, dynamic>.from(args as Map);
      } catch (_) {
        // ignore
      }
    }
  }

  Future<void> _loadObjetivos() async {
    final rows = await DatabaseHelper.instance.getProspectos();
    final set = <String>{};
    for (final r in rows) {
      final obj = (r['objetivo'] as String?) ?? '';
      if (obj.trim().isNotEmpty) set.add(obj);
    }
    setState(() {
      _objetivos = set.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Valores por defecto que están permitidos en la tabla `prospectos` (CHECK)
    final List<String> defaultObjetivos = [
      'Movilidad, Coordinacion y Fuerza',
      'Desarrollo Muscular',
      'Pérdida de Grasa Corporal',
      'Recuperación de Habilidades Funcionales',
    ];

    // Merge: empezar por los por defecto (en ese orden), y añadir cualquier objetivo
    // adicional que venga de la BD sin duplicados.
    final merged = <String>[];
    merged.addAll(defaultObjetivos);
    for (final o in _objetivos) {
      if (o.trim().isEmpty) continue;
      if (!merged.contains(o)) merged.add(o);
    }

    // Lista final con la opción placeholder al inicio
    final objetivos = ['----Seleccionar----', ...merged];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        toolbarHeight: 80,
        centerTitle: true,
        title: const Text(
          'SOLICITAR PRIMERA CITA',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 0),
                _nameField(label: 'NOMBRE', controller: _nombreController),
                _nameField(
                  label: 'APELLIDOS',
                  controller: _apellidosController,
                ),
                _celularField(),
                _edadField(),
                _pesoField(),
                _tallaField(),
                const SizedBox(height: 22),
                const Text(
                  'GÉNERO',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Builder(
                  builder: (context) {
                    final double screenWidth = MediaQuery.of(
                      context,
                    ).size.width;
                    final double usableWidth = screenWidth - 48;
                    const double between = 12;
                    final double optionWidth = (usableWidth - between) / 2;

                    return Row(
                      children: [
                        SizedBox(
                          width: optionWidth * 0.95,
                          height: 60,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                  initialValue: _selectedObjetivo,
                  onChanged: (v) => setState(() => _selectedObjetivo = v),
                  hint: const Text('----Seleccionar----'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (v == '----Seleccionar----') {
                      return 'Selecciona un objetivo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                if (_selectedCita != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CITA SELECCIONADA',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_selectedCita?['dia'] ?? ''} ${_selectedCita?['fecha'] ?? ''} ${_selectedCita?['hora'] ?? ''}',
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                if (_bmi != null)
                  Text(
                    'IMC: ${_bmi!.toStringAsFixed(1)}${_bmi! < 18.5 ? ' — Bajo peso' : (_bmi! > 29.9 ? ' — Sobrepeso/obesidad' : '')}',
                    style: TextStyle(
                      color: (_bmi! < 18.5 || _bmi! > 29.9)
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 100), // espacio final antes del botón
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: () async {
            final valid = _formKey.currentState?.validate() ?? false;
            if (!valid) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor revisa los campos')),
              );
              return;
            }
            if (_selectedGender == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selecciona un género')),
              );
              return;
            }
            _nombreController.text = _normalizeName(_nombreController.text);
            _apellidosController.text = _normalizeName(
              _apellidosController.text,
            );
            _updateBmi();

            final row = <String, dynamic>{
              'nombres': _nombreController.text.trim(),
              'apellidos': _apellidosController.text.trim(),
              'celular': _celularController.text.replaceAll(RegExp(r'\D'), ''),
              'edad': int.tryParse(_edadController.text) ?? 0,
              'peso':
                  double.tryParse(_pesoController.text.replaceAll(',', '.')) ??
                  0.0,
              'talla':
                  double.tryParse(_tallaController.text.replaceAll(',', '.')) ??
                  0.0,
              'genero': _selectedGender,
              'objetivo': _selectedObjetivo,
              'cita_id': _selectedCita != null ? _selectedCita!['id'] : null,
            };

            try {
              await DatabaseHelper.instance.insertProspecto(row);
              // ignore: use_build_context_synchronously
              Navigator.pushNamed(context, Routes.confirmacion);
            } catch (e) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al registrar: ${e.toString()}')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size.fromHeight(65),
          ),
          child: const Text(
            'Solicitar',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _celularController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    super.dispose();
  }

  // Normaliza nombres: trim, colapsa espacios múltiples y capitaliza cada palabra
  String _normalizeName(String input) => normalizeName(input);

  // Actualiza BMI si peso y talla son válidos
  void _updateBmi() {
    final bmi = calculateBmi(_pesoController.text, _tallaController.text);
    setState(() => _bmi = bmi);
  }

  Widget _nameField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿñÑ\s-]")),
        ],
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
        validator: (v) {
          final err = validateName(v);
          if (err == null) {
            final newVal = normalizeName(v ?? '');
            if (newVal != controller.text) controller.text = newVal;
          }
          return err;
        },
      ),
    );
  }

  Widget _celularField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _celularController,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\s-]')),
          PeruPhoneFormatter(),
        ],
        decoration: InputDecoration(
          hintText: 'CELULAR',
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
        validator: (v) => validatePeruPhone(v),
      ),
    );
  }

  Widget _edadField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _edadController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: 'EDAD',
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
        validator: (v) => validateEdad(v),
      ),
    );
  }

  Widget _pesoField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _pesoController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
        ],
        decoration: InputDecoration(
          hintText: 'PESO / KG',
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
        onChanged: (_) => _updateBmi(),
        validator: (v) => validatePeso(v),
      ),
    );
  }

  Widget _tallaField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _tallaController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
        ],
        decoration: InputDecoration(
          hintText: 'TALLA (m o cm)',
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
        onChanged: (_) => _updateBmi(),
        validator: (v) => validateTalla(v),
      ),
    );
  }
}

// El formateador ahora se importa desde solicitar_validations.dart (PeruPhoneFormatter)
