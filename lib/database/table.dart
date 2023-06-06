import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';



class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'my_database.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {

    await db.execute('''
      CREATE TABLE user(
        id INTEGER PRIMARY KEY,
        first_name TEXT,
        last_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE message (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      lasttext TEXT,
      date_time INTEGER,
      is_outgoing BOOLEAN,
      FOREIGN KEY (user_id) REFERENCES user (id)
)
''');
  }

  // ...Các mã khác...

  // Future<int> getUserCount() async {
  //   final database = await _initDatabase();
  //   final count = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM user'));
  //   return count ?? 0;
  // }

  // Future<int> getMessageCount() async {
  //   final database = await _initDatabase();
  //   final count = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM message'));
  //   return count ?? 0;
  // }

  // Future<List<Map<String, dynamic>>> getAllUsers() async {
  //   final database = await _initDatabase();
  //   return database.query('user');
  // }

  // Future<List<Map<String, dynamic>>> getAllMessages() async {
  //   final database = await _initDatabase();
  //   return database.query('message');
  // }
}

// TODO: Thêm các phương thức để thực hiện thao tác với cơ sở dữ liệu (thêm, sửa, xóa, truy vấn)
