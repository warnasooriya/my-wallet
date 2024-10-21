import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_finance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE income_types (
        id TEXT PRIMARY KEY ,
        name TEXT,
        description TEXT,
        userId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses_type (
        id TEXT PRIMARY KEY ,
        name TEXT,
        description TEXT,
        userId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY ,
        type TEXT,
        section TEXT,
        userId TEXT,
        date TEXT,
        amount REAL,
        description TEXT,
        image BLOB      
      )
    ''');

    await db.execute('''
      CREATE TABLE budget  (
        id TEXT PRIMARY KEY ,
        title TEXT,
        startDate TEXT,
        enddate TEXT,
        userId TEXT,
        imageUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE budget_item  (
        id TEXT PRIMARY KEY ,
        budgetId TEXT,
        type TEXT,
        section TEXT,
        description TEXT,
        date TEXT,
        amount REAL,
        userId TEXT
      )
    ''');
  }
}
