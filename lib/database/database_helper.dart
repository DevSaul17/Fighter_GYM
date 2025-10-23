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
    return await openDatabase(path, version: 1, onCreate: _createDB);
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
  }

  Future<int> insertProspecto(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('prospectos', row);
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
}
