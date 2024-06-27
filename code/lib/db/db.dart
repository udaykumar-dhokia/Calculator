import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UiTheme {
  final bool switchValue;

  UiTheme({required this.switchValue});

  Map<String, dynamic> toMap() {
    return {
      'switchValue':
          switchValue ? 1 : 0, // Store as integer (1 for true, 0 for false)
    };
  }

  factory UiTheme.fromMap(Map<String, dynamic> map) {
    return UiTheme(
      switchValue: map['switchValue'] == 1, // Retrieve as boolean
    );
  }
}

class DBHelper {
  DBHelper._();

  static final DBHelper instance = DBHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'calc.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE theme(
      switchValue INTEGER
    )
''');
  }

  Future<int> themeChange(UiTheme theme) async {
    Database db = await database;
    await db.delete('theme'); // Clear previous values
    return await db.insert('theme', theme.toMap());
  }

  Future<List<UiTheme>> getTheme() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('theme');
    return List.generate(maps.length, (index) {
      return UiTheme.fromMap(maps[index]);
    });
  }
}
