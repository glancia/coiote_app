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
    String path = join(documentsDirectory.path, "coiote.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE telemetry(id INTEGER PRIMARY KEY AUTOINCREMENT, serial INTEGER, filename TEXT, dataPoints INTEGER, payload TEXT, downloadDate DATETIME, uploadDate DATETIME)");
    await db.execute(
        "CREATE TABLE user(username TEXT, token TEXT)");
    print("Created tables");
  }

  void saveTelemetry(Telemetry telemetry) async {
    var dbClient = await db;
    var uploadDate = (telemetry.uploadDate != null) ? '\''+telemetry.uploadDate.toIso8601String()+'\'' : 'null';
    var query = 'INSERT INTO telemetry(serial, filename, dataPoints, payload, downloadDate, uploadDate ) VALUES(' +
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
        uploadDate +
        ')';

    await dbClient.transaction((txn) async {
      return await txn.rawInsert(query);
    });
  }

  void markUploaded(Telemetry telemetry) async {
    var uploadDate = DateTime.now().toIso8601String();
    var dbClient = await db;
    dbClient.transaction((txn) async {
      return await txn.rawUpdate('UPDATE telemetry SET uploadDate = \"$uploadDate\" WHERE id = ${telemetry.id}');
    });
  }

  Future<List<TelemetrySummary>> getTelemetrySummary() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT serial, COUNT(filename) as files, SUM(dataPoints) as dataPoints FROM telemetry WHERE uploadDate is null GROUP BY serial');
    // List<Map> list = await dbClient.rawQuery('SELECT * FROM telemetry');
    List<TelemetrySummary> files = [];
    for (int i = 0; i < list.length; i++) {
      files.add(new TelemetrySummary(list[i]["serial"], list[i]["files"], list[i]["dataPoints"]));
    }
    print(files.length);
    return files;
  }

  Future<List<Telemetry>> getTelemetry() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM telemetry WHERE uploadDate is null ORDER by downloadDate');
    List<Telemetry> files = [];
    for (int i = 0; i < list.length; i++) {
      var uploadDate = (list[i]["uploadDate"] != null) ? DateTime.parse(list[i]["uploadDate"]) : null;
      files.add(new Telemetry(list[i]["id"], list[i]["serial"], list[i]["filename"], list[i]["dataPoints"], list[i]["payload"], DateTime.parse(list[i]["downloadDate"]),uploadDate));
    }
    print(files.length);
    return files;
  }

}

