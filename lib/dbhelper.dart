import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_blue_example/telemetry.dart';

class DBHelper {
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "telemetry.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE telemetry(id INTEGER PRIMARY KEY AUTOINCREMENT, serial INTEGER, filename TEXT, dataPoints INTEGER, payload TEXT, downloadDate DATETIME, uploadDate DATETIME)");
    print("Created tables");
  }

  void saveTelemetry(Telemetry telemetry) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO telemetry(serial, filename, dataPoints, payload, downloadDate, uploadDate ) VALUES(' +
              telemetry.serial.toString() +
              ',' +
              '\'' +
              telemetry.filename +
              '\'' +
              ',' +
              telemetry.dataPoints.toString() +
              ',' +
              '\'' +
              telemetry.payload +
              '\'' +
              ',' +
              '\'' +
              telemetry.downloadDate.toIso8601String() +
              '\'' +
              ',' +
              '\'' +
              telemetry.uploadDate.toIso8601String() +
              '\'' +
              ')');
    });
  }

  Future<List<Telemetry>> getFiles() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM telemetry');
    List<Telemetry> files = [];
    for (int i = 0; i < list.length; i++) {
      files.add(new Telemetry(list[i]["id"], list[i]["serial"], list[i]["filename"], list[i]["dataPoints"], list[i]["payload"], DateTime.parse(list[i]["downloadDate"]),DateTime.parse(list[i]["uploadDate"])));
    }
    print(files.length);
    return files;
  }
}