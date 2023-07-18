import 'package:school_pal/models/local_data.dart';
import 'package:school_pal/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

abstract class DatabaseHandlerRepository{
  Future<dynamic> insertData({LocalData apiData});
  Future<LocalData> getData({String title});
  Future<LocalData> getDataByValue({String column, String value});
  Future<List<LocalData>> getAllData();
  Future<dynamic> updateData({LocalData apiData});
  Future<dynamic> deleteData({String title});
  Future<dynamic> deleteAllData();
  Future<dynamic> deleteTable();
}

class DatabaseHandlerOperations extends DatabaseHandlerRepository{
  static DatabaseProvider _dbProvider;
  DatabaseHandlerOperations(){
    _dbProvider=DatabaseProvider();
  }

  @override
  Future<dynamic> insertData({LocalData apiData}) async{
    // TODO: implement insertData
    final db = await _dbProvider.database;
    var res = await db.insert(DatabaseProvider.TABLE_API_DATA, apiData.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    /// OR
    /*var res = await db.rawInsert(
        "INSERT Into ${DatabaseProvider.TABLE_API_DATA} (${DatabaseProvider.COLUMN_ID},${DatabaseProvider.COLUMN_TITLE},${DatabaseProvider.COLUMN_DATA})"
            " VALUES (${apiData.id},${apiData.title},,${apiData.data})");*/
    return res;
  }

  @override
  Future<LocalData> getDataByValue({String column, String value}) async{
    // TODO: implement getDataByTitle
    final db = await _dbProvider.database;
    var res =await  db.query(DatabaseProvider.TABLE_API_DATA, where: "$column = ?", whereArgs: [value]);
    return res.isNotEmpty ? LocalData.fromMap(res.first) : null ;
  }

  @override
  Future<LocalData> getData({String title}) async{
    // TODO: implement getDataTitle
    final db = await _dbProvider.database;
    var res =await  db.query(DatabaseProvider.TABLE_API_DATA, where: "${DatabaseProvider.COLUMN_TITLE} = ?", whereArgs: [title]);
    return res.isNotEmpty ? LocalData.fromMap(res.first) : null ;
  }

  @override
  Future<List<LocalData>> getAllData() async{
    // TODO: implement getAllData
    final db = await _dbProvider.database;
    var res = await db.query(DatabaseProvider.TABLE_API_DATA);
    List<LocalData> list =
    res.isNotEmpty ? res.map((c) => LocalData.fromMap(c)).toList() : [];
    return list;
  }

  @override
  Future updateData({LocalData apiData}) async{
    // TODO: implement updateData
    final db = await _dbProvider.database;
    var res = await db.update(DatabaseProvider.TABLE_API_DATA, apiData.toMap(),
        where: "${DatabaseProvider.COLUMN_TITLE} = ?", whereArgs: [apiData.title]);
    return res;
  }

  @override
  Future deleteData({String title}) async{
    // TODO: implement deleteData
    final db = await _dbProvider.database;
    db.delete(DatabaseProvider.TABLE_API_DATA, where: "${DatabaseProvider.COLUMN_TITLE} = ?", whereArgs: [title]);
  }

  @override
  Future deleteAllData() async{
    // TODO: implement deleteAllData
    List<LocalData> localData=await getAllData();
    for(LocalData data in localData){
      deleteData(title: data.title);
    }
    //final db = await _dbProvider.database;
    //db.execute("Delete * from ${DatabaseProvider.TABLE_API_DATA}");
    //db.rawDelete("Delete * from ${DatabaseProvider.TABLE_API_DATA}");
  }

  @override
  Future deleteTable() async{
    // TODO: implement deleteTable
    final db = await _dbProvider.database;
    db.execute("DROP TABLE ${DatabaseProvider.TABLE_API_DATA}");
  }


}