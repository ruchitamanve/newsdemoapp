import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:topheadlinesdemo/database/headlines_db_model.dart';

class HeadlineListDBHelper {
  static Database _db;
  static const String ID = 'id';
  static const ListDATA = "listdata";
  static const String TABLE = 'headlinetable';
  static const String DB_NAME = 'news.db';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $ListDATA TEXT)");
  }

  Future<dynamic> save(HeadLineListDbModel model) async {
    var dbClient = await db;
    model.id = await dbClient
        .insert(TABLE, model.toMap())
        .then((value) {})
        .catchError((onError) {});
  }

  Future truncateTable() async {
    Database dbClient = await db;
    await dbClient.execute("DELETE from $TABLE");
  }

  Future<List<HeadLineListDbModel>> getDbData() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ID, ListDATA]);
    List<HeadLineListDbModel> _list = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        _list.add(HeadLineListDbModel.fromMap(maps[i]));
      }
    }

    return _list;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
