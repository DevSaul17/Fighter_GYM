class Cliente {
  final int? id;
  final String dni;
  final String nombres;
  final String apellidos;
  final String celular;
  final String? correo;
  final int? edad;
  final double? peso;
  final double? talla;
  final String genero;
  final String? descripcion;
  final String? condicionMedica;
  final String? fechaNacimiento;
  final String contrasenaHash;
  final String? fechaRegistro;

  Cliente({
    this.id,
    required this.dni,
    required this.nombres,
    required this.apellidos,
    required this.celular,
    this.correo,
    this.edad,
    this.peso,
    this.talla,
    required this.genero,
    this.descripcion,
    this.condicionMedica,
    this.fechaNacimiento,
    required this.contrasenaHash,
    this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dni': dni,
      'nombres': nombres,
      'apellidos': apellidos,
      'celular': celular,
      'correo': correo,
      'edad': edad,
      'peso': peso,
      'talla': talla,
      'genero': genero,
      'descripcion': descripcion,
      'condicion_medica': condicionMedica,
      'fecha_nacimiento': fechaNacimiento,
      'contrasena_hash': contrasenaHash,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      dni: map['dni'],
      nombres: map['nombres'],
      apellidos: map['apellidos'],
      celular: map['celular'],
      correo: map['correo'],
      edad: map['edad'],
      peso: map['peso'],
      talla: map['talla'],
      genero: map['genero'],
      descripcion: map['descripcion'],
      condicionMedica: map['condicion_medica'],
      fechaNacimiento: map['fecha_nacimiento'],
      contrasenaHash: map['contrasena_hash'],
      fechaRegistro: map['fecha_registro'],
    );
  }
}
