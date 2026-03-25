import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/providers/analysis_queue_provider.dart'; 

class LocalDBService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, 'malairia_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            imagePath TEXT,
            hn TEXT,
            status INTEGER,
            isPositive INTEGER,
            confidence REAL,
            boxes TEXT,
            errorMessage TEXT
          )
        ''');
      },
    );
  }

  // 1. เซฟงานลงเครื่อง
  static Future<void> insertTask(AnalysisTask task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 2. ดึงงานที่วิเคราะห์เสร็จแล้วแต่ยังไม่ได้ซิงค์
  static Future<List<AnalysisTask>> getUnsyncedTasks() async {
    final db = await database;
    // ดึงเฉพาะ status = 2 (completed) 
    final List<Map<String, dynamic>> maps = await db.query('tasks', where: 'status = ?', whereArgs: [2]);
    return List.generate(maps.length, (i) => AnalysisTask.fromMap(maps[i]));
  }

  // 3. ลบงานทิ้งเมื่อซิงค์ขึ้น Cloud สำเร็จ
  static Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<AnalysisTask>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => AnalysisTask.fromMap(maps[i]));
  }
}