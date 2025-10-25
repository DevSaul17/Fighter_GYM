import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gym_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final String dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        // Ensure tables exist when opening an older DB (migration guard)
        await db.execute('''
    CREATE TABLE IF NOT EXISTS planes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL UNIQUE,
      descripcion TEXT
    );
  ''');

        await db.execute('''
    CREATE TABLE IF NOT EXISTS clientes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dni TEXT NOT NULL UNIQUE,
      nombres TEXT NOT NULL,
      apellidos TEXT NOT NULL,
      celular TEXT NOT NULL,
      correo TEXT UNIQUE,
      edad INTEGER,
      peso REAL,
      talla REAL,
      genero TEXT CHECK(genero IN ('Masculino','Femenino')),
      descripcion TEXT,
      condicion_medica TEXT,
      fecha_nacimiento DATE,
      contrasena_hash TEXT NOT NULL,
      fecha_registro DATETIME DEFAULT (datetime('now'))
    );
  ''');

        await db.execute('''
    CREATE TABLE IF NOT EXISTS entrenadores (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombres TEXT NOT NULL,
      apellidos TEXT NOT NULL,
      celular TEXT,
      correo TEXT UNIQUE
    );
  ''');

        await db.execute('''
    CREATE TABLE IF NOT EXISTS membresias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_cliente INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
      id_plan INTEGER NOT NULL REFERENCES planes(id),
      frecuencia INTEGER NOT NULL CHECK(frecuencia IN (3,5)),
      fecha_inicio DATE NOT NULL,
      fecha_fin DATE NOT NULL,
      hora TIME NOT NULL,
      recuperacion_sabado INTEGER DEFAULT 1,
      activa INTEGER DEFAULT 1,
      fecha_creacion DATETIME DEFAULT (datetime('now'))
    );
  ''');

        await db.execute('''
    CREATE TABLE IF NOT EXISTS dias_membresia (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_membresia INTEGER NOT NULL REFERENCES membresias(id) ON DELETE CASCADE,
      dia_semana INTEGER NOT NULL CHECK(dia_semana BETWEEN 1 AND 7)
    );
  ''');

        await db.execute('''
    CREATE TABLE IF NOT EXISTS horarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_membresia INTEGER NOT NULL REFERENCES membresias(id) ON DELETE CASCADE,
      fecha DATE NOT NULL,
      hora TIME NOT NULL,
      id_entrenador INTEGER REFERENCES entrenadores(id),
      estado TEXT CHECK(estado IN ('reservado','completado','cancelado')) DEFAULT 'reservado'
    );
  ''');

        await db.execute('''
    CREATE TABLE IF NOT EXISTS pagos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_cliente INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
      id_membresia INTEGER REFERENCES membresias(id),
      monto REAL NOT NULL,
      meses_adelantados INTEGER DEFAULT 1,
      fecha_pago DATETIME DEFAULT (datetime('now')),
      metodo_pago TEXT,
      referencia TEXT
    );
  ''');

        await db.execute('''
    CREATE TABLE IF NOT EXISTS facturas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_pago INTEGER NOT NULL REFERENCES pagos(id) ON DELETE CASCADE,
      numero_factura TEXT UNIQUE,
      fecha_factura DATETIME DEFAULT (datetime('now')),
      membresia_inicio DATE NOT NULL,
      membresia_fin DATE NOT NULL,
      total REAL NOT NULL
    );
  ''');

        await db.execute('''
    CREATE TABLE IF NOT EXISTS asistencias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_horario INTEGER REFERENCES horarios(id) ON DELETE SET NULL,
      id_membresia INTEGER NOT NULL REFERENCES membresias(id) ON DELETE CASCADE,
      id_cliente INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
      id_entrenador INTEGER REFERENCES entrenadores(id),
      fecha DATE NOT NULL,
      hora TIME,
      presente INTEGER CHECK(presente IN (0,1)),
      observacion TEXT,
      fecha_registro DATETIME DEFAULT (datetime('now'))
    );
  ''');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE citas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE prospectos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombres TEXT NOT NULL,
        apellidos TEXT NOT NULL,
        celular TEXT NOT NULL UNIQUE CHECK (LENGTH(celular) = 9),
        edad INTEGER CHECK (edad >= 0),
        peso REAL CHECK (peso > 0),
        talla REAL CHECK (talla > 0),
        genero TEXT NOT NULL CHECK (genero IN ('Masculino', 'Femenino')),
        objetivo TEXT NOT NULL CHECK (
          objetivo IN (
            'Movilidad, Coordinacion y Fuerza',
            'Desarrollo Muscular',
            'Pérdida de Grasa Corporal',
            'Recuperación de Habilidades Funcionales'
          )
        ),
        cita_id INTEGER,
        FOREIGN KEY (cita_id) REFERENCES citas (id)
      );
    ''');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS planes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL UNIQUE,
      descripcion TEXT
    );
  ''');

    // CLIENTES
    await db.execute('''
    CREATE TABLE IF NOT EXISTS clientes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dni TEXT NOT NULL UNIQUE,
      nombres TEXT NOT NULL,
      apellidos TEXT NOT NULL,
      celular TEXT NOT NULL,
      correo TEXT UNIQUE,
      edad INTEGER,
      peso REAL,
      talla REAL,
      genero TEXT CHECK(genero IN ('Masculino','Femenino')),
      descripcion TEXT,
      condicion_medica TEXT,
      fecha_nacimiento DATE,
      contrasena_hash TEXT NOT NULL,
      fecha_registro DATETIME DEFAULT (datetime('now'))
    );
  ''');

    // ENTRENADORES
    await db.execute('''
    CREATE TABLE IF NOT EXISTS entrenadores (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombres TEXT NOT NULL,
      apellidos TEXT NOT NULL,
      celular TEXT,
      correo TEXT UNIQUE
    );
  ''');

    // MEMBRESÍAS
    await db.execute('''
    CREATE TABLE IF NOT EXISTS membresias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_cliente INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
      id_plan INTEGER NOT NULL REFERENCES planes(id),
      frecuencia INTEGER NOT NULL CHECK(frecuencia IN (3,5)),
      fecha_inicio DATE NOT NULL,
      fecha_fin DATE NOT NULL,
      hora TIME NOT NULL,
      recuperacion_sabado INTEGER DEFAULT 1,
      activa INTEGER DEFAULT 1,
      fecha_creacion DATETIME DEFAULT (datetime('now'))
    );
  ''');

    // DÍAS DE MEMBRESÍA
    await db.execute('''
    CREATE TABLE IF NOT EXISTS dias_membresia (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_membresia INTEGER NOT NULL REFERENCES membresias(id) ON DELETE CASCADE,
      dia_semana INTEGER NOT NULL CHECK(dia_semana BETWEEN 1 AND 7)
    );
  ''');

    // HORARIOS
    await db.execute('''
    CREATE TABLE IF NOT EXISTS horarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_membresia INTEGER NOT NULL REFERENCES membresias(id) ON DELETE CASCADE,
      fecha DATE NOT NULL,
      hora TIME NOT NULL,
      id_entrenador INTEGER REFERENCES entrenadores(id),
      estado TEXT CHECK(estado IN ('reservado','completado','cancelado')) DEFAULT 'reservado'
    );
  ''');

    // PAGOS
    await db.execute('''
    CREATE TABLE IF NOT EXISTS pagos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_cliente INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
      id_membresia INTEGER REFERENCES membresias(id),
      monto REAL NOT NULL,
      meses_adelantados INTEGER DEFAULT 1,
      fecha_pago DATETIME DEFAULT (datetime('now')),
      metodo_pago TEXT,
      referencia TEXT
    );
  ''');

    // FACTURAS
    await db.execute('''
    CREATE TABLE IF NOT EXISTS facturas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_pago INTEGER NOT NULL REFERENCES pagos(id) ON DELETE CASCADE,
      numero_factura TEXT UNIQUE,
      fecha_factura DATETIME DEFAULT (datetime('now')),
      membresia_inicio DATE NOT NULL,
      membresia_fin DATE NOT NULL,
      total REAL NOT NULL
    );
  ''');

    // ASISTENCIAS
    await db.execute('''
    CREATE TABLE IF NOT EXISTS asistencias (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_horario INTEGER REFERENCES horarios(id) ON DELETE SET NULL,
      id_membresia INTEGER NOT NULL REFERENCES membresias(id) ON DELETE CASCADE,
      id_cliente INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
      id_entrenador INTEGER REFERENCES entrenadores(id),
      fecha DATE NOT NULL,
      hora TIME,
      presente INTEGER CHECK(presente IN (0,1)),
      observacion TEXT,
      fecha_registro DATETIME DEFAULT (datetime('now'))
    );
  ''');
  }

  Future<int> insertProspecto(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('prospectos', row);
  }

  // CLIENTES methods
  Future<int> insertCliente(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('clientes', row);
  }

  Future<List<Map<String, dynamic>>> getClientes() async {
    final db = await instance.database;
    return await db.query('clientes', orderBy: 'nombres, apellidos');
  }

  /// Obtiene un cliente por su DNI. Retorna null si no existe.
  Future<Map<String, dynamic>?> getClienteByDni(String dni) async {
    final db = await instance.database;
    final res = await db.query(
      'clientes',
      where: 'dni = ?',
      whereArgs: [dni],
      limit: 1,
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<int> deleteCliente(int id) async {
    final db = await instance.database;
    return await db.delete('clientes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getProspectos() async {
    final db = await instance.database;
    return await db.query('prospectos');
  }

  // Citas methods
  Future<int> insertCita(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('citas', row);
  }

  Future<List<Map<String, dynamic>>> getCitas() async {
    final db = await instance.database;
    return await db.query('citas', orderBy: 'fecha, hora');
  }

  Future<int> deleteCita(int id) async {
    final db = await instance.database;
    return await db.delete('citas', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCita(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update('citas', row, where: 'id = ?', whereArgs: [id]);
  }

  // PLANES
  Future<int> insertPlan(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('planes', row);
  }

  Future<List<Map<String, dynamic>>> getPlanes() async {
    final db = await instance.database;
    return await db.query('planes', orderBy: 'nombre');
  }

  Future<int> deletePlan(int id) async {
    final db = await instance.database;
    return await db.delete('planes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updatePlan(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update('planes', row, where: 'id = ?', whereArgs: [id]);
  }

  // ENTRENADORES
  Future<int> insertEntrenador(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('entrenadores', row);
  }

  Future<List<Map<String, dynamic>>> getEntrenadores() async {
    final db = await instance.database;
    return await db.query('entrenadores', orderBy: 'nombres, apellidos');
  }

  Future<int> deleteEntrenador(int id) async {
    final db = await instance.database;
    return await db.delete('entrenadores', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateEntrenador(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'entrenadores',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // HORARIOS (note: table expects id_membresia NOT NULL; inserting horarios without a membresia
  // may fail. For now, provide a helper that requires the caller to provide a valid id_membresia.)
  Future<int> insertHorario(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('horarios', row);
  }

  /// Obtiene los horarios, incluyendo información del cliente (vía membresia) y del entrenador.
  Future<List<Map<String, dynamic>>> getHorarios() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT h.*, m.id_cliente, c.nombres as cliente_nombres, c.apellidos as cliente_apellidos,
             e.nombres as entrenador_nombres, e.apellidos as entrenador_apellidos
      FROM horarios h
      LEFT JOIN membresias m ON h.id_membresia = m.id
      LEFT JOIN clientes c ON m.id_cliente = c.id
      LEFT JOIN entrenadores e ON h.id_entrenador = e.id
      ORDER BY h.fecha DESC, h.hora DESC
    ''');
    return result;
  }

  // MEMBRESIAS methods
  Future<int> insertMembresia(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('membresias', row);
  }

  Future<List<Map<String, dynamic>>> getMembresias() async {
    final db = await instance.database;
    // join membresias with clientes and planes for display
    final result = await db.rawQuery('''
      SELECT m.id as id_membresia, m.id_cliente, m.id_plan, m.frecuencia, m.fecha_inicio, m.fecha_fin, m.hora, m.recuperacion_sabado, m.activa,
             c.nombres as cliente_nombres, c.apellidos as cliente_apellidos, c.dni as cliente_dni,
             p.nombre as plan_nombre
      FROM membresias m
      JOIN clientes c ON m.id_cliente = c.id
      JOIN planes p ON m.id_plan = p.id
      ORDER BY m.fecha_inicio DESC
    ''');
    return result;
  }

  /// Obtiene la membresía activa más reciente de un cliente
  Future<Map<String, dynamic>?> getMembresiaByCliente(int clienteId) async {
    final db = await instance.database;
    final res = await db.rawQuery(
      '''
      SELECT m.*, p.nombre as plan_nombre
      FROM membresias m
      JOIN planes p ON m.id_plan = p.id
      WHERE m.id_cliente = ? AND m.activa = 1
      ORDER BY m.fecha_creacion DESC
      LIMIT 1
    ''',
      [clienteId],
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> getClientesSinMembresia() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT c.* FROM clientes c
      LEFT JOIN membresias m ON c.id = m.id_cliente
      WHERE m.id IS NULL
      ORDER BY c.nombres, c.apellidos
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getClientesConMembresia() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT m.*, c.nombres as cliente_nombres, c.apellidos as cliente_apellidos, p.nombre as plan_nombre
      FROM membresias m
      JOIN clientes c ON m.id_cliente = c.id
      JOIN planes p ON m.id_plan = p.id
      ORDER BY m.fecha_inicio DESC
    ''');
    return result;
  }

  /// Reemplaza los días de una membresía (borra los previos e inserta los nuevos)
  Future<void> setDiasMembresia(int idMembresia, List<int> dias) async {
    final db = await instance.database;
    final batch = db.batch();
    await db.delete(
      'dias_membresia',
      where: 'id_membresia = ?',
      whereArgs: [idMembresia],
    );
    for (final d in dias) {
      batch.insert('dias_membresia', {
        'id_membresia': idMembresia,
        'dia_semana': d,
      });
    }
    await batch.commit(noResult: true);
  }

  /// Obtiene los días (1-7) asociados a una membresía
  Future<List<int>> getDiasMembresia(int idMembresia) async {
    final db = await instance.database;
    final rows = await db.query(
      'dias_membresia',
      where: 'id_membresia = ?',
      whereArgs: [idMembresia],
    );
    return rows.map<int>((r) => (r['dia_semana'] as num).toInt()).toList();
  }

  /// Actualiza la hora de una membresía (formato HH:MM)
  Future<int> updateMembresiaHora(int id, String hora) async {
    final db = await instance.database;
    return await db.update(
      'membresias',
      {'hora': hora},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // PAGOS
  Future<int> insertPago(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('pagos', row);
  }

  Future<List<Map<String, dynamic>>> getPagos() async {
    final db = await instance.database;
    // join pagos with clientes to include client names for display
    final result = await db.rawQuery('''
      SELECT p.*, c.nombres as cliente_nombres, c.apellidos as cliente_apellidos
      FROM pagos p
      LEFT JOIN clientes c ON p.id_cliente = c.id
      ORDER BY p.fecha_pago DESC
    ''');
    return result;
  }

  // FACTURAS
  Future<int> insertFactura(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('facturas', row);
  }

  /// Obtiene facturas con información de pago y cliente para mostrar/listar.
  Future<List<Map<String, dynamic>>> getFacturas() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT f.*, p.monto as pago_monto, p.fecha_pago, c.nombres as cliente_nombres, c.apellidos as cliente_apellidos,
             m.id as id_membresia, p.id_membresia
      FROM facturas f
      JOIN pagos p ON f.id_pago = p.id
      LEFT JOIN clientes c ON p.id_cliente = c.id
      LEFT JOIN membresias m ON p.id_membresia = m.id OR m.id_cliente = p.id_cliente
      ORDER BY f.fecha_factura DESC
    ''');
    return result;
  }

  /// Genera el siguiente número de factura con prefijo 'G0000' evitando repeticiones.
  /// Busca el máximo sufijo numérico ya usado y retorna el siguiente entero como string.
  Future<String> getNextNumeroFactura() async {
    final db = await instance.database;
    // numero_factura tiene formato 'G0000<numero>' — extraemos la parte numérica y tomamos el MAX
    final res = await db.rawQuery('''
      SELECT MAX(CAST(substr(numero_factura, 6) AS INTEGER)) as maxn
      FROM facturas
      WHERE numero_factura LIKE 'G0000%'
    ''');
    int maxn = 0;
    if (res.isNotEmpty) {
      final v = res.first['maxn'];
      if (v is int) {
        maxn = v;
      } else if (v is String)
        // ignore: curly_braces_in_flow_control_structures
        maxn = int.tryParse(v) ?? 0;
    }
    final next = maxn + 1;
    return 'G0000$next';
  }

  /// Valida si una fecha y hora (por partes) está dentro de la disponibilidad del gimnasio.
  /// Reglas:
  /// - Sábado (6) y Domingo (7): disponible desde 05:00 hasta 15:00
  /// - Lunes-Viernes (1-5): disponible desde 05:00 hasta 22:00
  bool horarioDisponibleFromParts(DateTime fecha, int hour, int minute) {
    final weekday = fecha.weekday; // 1 = Monday ... 7 = Sunday
    final minutes = hour * 60 + minute;
    const startMinutes = 5 * 60; // 05:00
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      const endWeekend = 15 * 60; // 15:00
      return minutes >= startMinutes && minutes <= endWeekend;
    } else {
      const endWeekday = 22 * 60; // 22:00
      return minutes >= startMinutes && minutes <= endWeekday;
    }
  }
}
