import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ideas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ideas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT,
            descripcion TEXT,
            created_at TEXT
          )
        ''');
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getIdeas() async {
    final dbClient = await db;
    return await dbClient.query('ideas', orderBy: 'id DESC');
  }

  static Future<void> insertIdea(String titulo, String descripcion, String fecha) async {
    final dbClient = await db;
    await dbClient.insert('ideas', {
      'titulo': titulo,
      'descripcion': descripcion,
      'created_at': fecha,
    });
  }

  static Future<void> deleteIdeaByID(int id) async {
    final dbClient = await db;
    await dbClient.delete('ideas', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearIdeas() async {
    final dbClient = await db;
    await dbClient.delete('ideas');
  }

}