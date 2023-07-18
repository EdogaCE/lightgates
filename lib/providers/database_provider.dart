import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:school_pal/res/strings.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  //DatabaseProvider._();
  //static final DatabaseProvider db = DatabaseProvider._();

  static Database _database;
  static const String _DATABASE_NAME = "${MyStrings.appName}.db";
  static const int _DATABASE_VERSION = 1;

  static const String TABLE_API_DATA = "ApiData";
  static const String COLUMN_ID = "id";
  static const String COLUMN_TITLE = "title";
  static const String COLUMN_DATA = "data";

  static const  String _CREATE_TABLE ="CREATE TABLE $TABLE_API_DATA ("
      "$COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,"
      "$COLUMN_TITLE TEXT NOT NULL UNIQUE,"
      "$COLUMN_DATA TEXT"
      ")";

  Future<Database> get database async {
    if (_database != null)
      return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _DATABASE_NAME);
    return await openDatabase(path, version: _DATABASE_VERSION, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute(_CREATE_TABLE);
    });
  }
}