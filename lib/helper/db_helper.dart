import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static const _databaseName = "weather.db";
  static const _databaseVersion = 1;

  static const table = 'weather';

  // static const columnId = '_id';
  static const columnName = 'cityName';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE $table($columnName VARCHAR PRIMARY KEY)');
  }

  //Insert Data
  insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(table, row);
  }

  Future<dynamic> fetchCityNameData() async {
    Database? db = await instance.database;
    return await db!.rawQuery("SELECT * FROM $table");
  }

  Future<dynamic> deleteData(String id) async {
    var db = await database;
    return await db?.rawDelete('DELETE FROM $table WHERE $columnName = $id');
  }

}