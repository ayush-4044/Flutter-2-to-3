import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // To-Do Table
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isDone INTEGER NOT NULL
      )
    ''');
    // Notes Table
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL
      )
    ''');
  }

  // --- To-Do Methods ---
  Future<int> insertTodo(Map<String, dynamic> row) async => await (await database).insert('todos', row);
  Future<List<Map<String, dynamic>>> getTodos() async => await (await database).query('todos');
  Future<int> updateTodo(Map<String, dynamic> row) async => await (await database).update('todos', row, where: 'id = ?', whereArgs: [row['id']]);
  Future<int> deleteTodo(int id) async => await (await database).delete('todos', where: 'id = ?', whereArgs: [id]);

  // --- Notes Methods ---
  Future<int> insertNote(Map<String, dynamic> row) async => await (await database).insert('notes', row);
  Future<List<Map<String, dynamic>>> getNotes() async => await (await database).query('notes');
  Future<int> updateNote(Map<String, dynamic> row) async => await (await database).update('notes', row, where: 'id = ?', whereArgs: [row['id']]);
  Future<int> deleteNote(int id) async => await (await database).delete('notes', where: 'id = ?', whereArgs: [id]);
}