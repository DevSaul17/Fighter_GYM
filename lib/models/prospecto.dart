class Prospecto {
  final int? id;
  final String nombres;
  final String apellidos;
  final String celular;
  final int edad;
  final double peso;
  final double talla;
  final String genero;
  final String objetivo;
  final int? citaId;

  Prospecto({
    this.id,
    required this.nombres,
    required this.apellidos,
    required this.celular,
    required this.edad,
    required this.peso,
    required this.talla,
    required this.genero,
    required this.objetivo,
    this.citaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'celular': celular,
      'edad': edad,
      'peso': peso,
      'talla': talla,
      'genero': genero,
      'objetivo': objetivo,
      'cita_id': citaId,
    };
  }

  factory Prospecto.fromMap(Map<String, dynamic> map) {
    return Prospecto(
      id: map['id'],
      nombres: map['nombres'],
      apellidos: map['apellidos'],
      celular: map['celular'],
      edad: map['edad'],
      peso: map['peso'],
      talla: map['talla'],
      genero: map['genero'],
      objetivo: map['objetivo'],
      citaId: map['cita_id'],
    );
  }
}
