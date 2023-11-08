import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/todo_item.dart'; // Correct this import according to your project structure

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const boolType = 'INTEGER NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE todo_items (
  id $idType,
  title $textType,
  isDone $boolType
)
''');
  }

  Future<TodoItem> createTodoItem(TodoItem todoItem) async {
    final db = await database;

    final id = await db.insert('todo_items', todoItem.toMap());
    return todoItem.copyWith(id: id);
  }

  Future<TodoItem> readTodoItem(int id) async {
    final db = await database;

    final maps = await db.query(
      'todo_items',
      columns: ['id', 'title', 'isDone'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TodoItem.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<TodoItem>> readAllTodoItems() async {
    final db = await database;

    final orderBy = 'id ASC';
    final result = await db.query('todo_items', orderBy: orderBy);

    return result.map((json) => TodoItem.fromMap(json)).toList();
  }

  Future<int> updateTodoItem(TodoItem todoItem) async {
    final db = await database;

    return db.update(
      'todo_items',
      todoItem.toMap(),
      where: 'id = ?',
      whereArgs: [todoItem.id],
    );
  }

  Future<int> deleteTodoItem(int id) async {
    final db = await database;

    return db.delete(
      'todo_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
