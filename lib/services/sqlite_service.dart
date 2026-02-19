import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteService {
  static final SQLiteService _instance = SQLiteService._internal();
  factory SQLiteService() => _instance;
  SQLiteService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        await db.execute('''
          CREATE TABLE user_image (
            uid TEXT PRIMARY KEY,
            image BLOB
          )
        ''');

        // await db.execute('''
        //   CREATE TABLE menu_image (
        //     id TEXT PRIMARY KEY,
        //     image BLOB
        //   )
        // ''');
      },
    );
  }

  Future<void> saveUserImage(String uid, Uint8List image) async {
    final db = await database;
    await db.insert(
      'user_image',
      {'uid': uid, 'image': image},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Uint8List?> getUserImage(String uid) async {
    final db = await database;
    final maps = await db.query('user_image', where: 'uid = ?', whereArgs: [uid]);
    if (maps.isNotEmpty) return maps.first['image'] as Uint8List;
    return null;
  }

  // Future<void> saveMenuImage(String id, Uint8List image) async {
  //   final db = await database;
  //   await db.insert(
  //     'menu_image',
  //     {'id': id, 'image': image},
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  //   Future<void> updateMenuImage(String id, Uint8List image) async {
  //   final db = await database;

  //   await db.update(
  //     'menu_image',
  //     {'image': image},
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  // Future<void> deleteMenuImage(String id) async {
  //   final db = await database;

  //   await db.delete(
  //     'menu_image',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  // Future<Uint8List?> getMenuImage(String id) async {
  //   final db = await database;
  //   final maps = await db.query('menu_image', where: 'id = ?', whereArgs: [id]);
  //   if (maps.isNotEmpty) return maps.first['image'] as Uint8List;
  //   return null;
  // }
}

