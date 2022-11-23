import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_customer_app/nas/constants.dart';
import 'package:flutter_customer_app/nas/utilities/exception.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SQLite {
  static Database? database;

  static Future<void> openDb() async {
    WidgetsFlutterBinding.ensureInitialized();

    if(kIsWeb) {
      var databaseFactory = databaseFactoryFfi;
      database = await databaseFactory.openDatabase(join(await getDatabasesPath(), 'nas_customer_app.db'),
          options: OpenDatabaseOptions(
              onCreate: (db, version) {
                return db.execute(
                  'CREATE TABLE authToken(id INTEGER PRIMARY KEY, access_token TEXT, refresh_token TEXT, created_time LONG)',
                );
              },
              version: 1,
              singleInstance: true
          ));
    } else {
      database = await openDatabase(
        join(await getDatabasesPath(), 'nas_customer_app.db'),
        onCreate: (db, version) {
          db.execute('CREATE TABLE authToken(id INTEGER PRIMARY KEY, access_token TEXT, refresh_token TEXT, created_time LONG)');
          db.execute('CREATE TABLE ageingSummary(id INTEGER PRIMARY KEY, document_id TEXT, created_time LONG, last_updated_time LONG)');
          db.execute('CREATE TABLE ageingSummaryItem(id INTEGER PRIMARY KEY, reference TEXT, date TEXT, amount DOUBLE, ageing_summary_id INTEGER, FOREIGN KEY (ageing_summary_id) REFERENCES ageingSummary(id))');
          db.execute('CREATE TABLE ledgerBalance(id INTEGER PRIMARY KEY, document_id TEXT, balance DOUBLE,  created_time LONG, last_updated_time LONG)');
        },
        onUpgrade: (db, oldVersion, newVersion) {
          if (oldVersion < newVersion) {
            db.execute("CREATE TABLE ageingSummary(id INTEGER PRIMARY KEY, document_id TEXT, created_time LONG, last_updated_time LONG)");
            db.execute("CREATE TABLE ageingSummaryItem(id INTEGER PRIMARY KEY, reference TEXT, date TEXT, amount DOUBLE, ageing_summary_id INTEGER, FOREIGN KEY (ageing_summary_id) REFERENCES ageingSummary(id))");
            db.execute("CREATE TABLE ledgerBalance(id INTEGER PRIMARY KEY, document_id TEXT, balance DOUBLE,  created_time LONG, last_updated_time LONG)");
          }
        },
        version: 2,
      );
    }
  }

  static Future<int> insert(DatabaseExecutor? db, String tableName, dynamic row) async {
    log.info("In Sqlite Insert");
    if (db != null) {
      int id = await db.insert(
        tableName,
        row.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } else {
      await openDb();
      return -1;
    }
  }

  static Future<List<Map<String, Object?>>> get(DatabaseExecutor? db, String tableName, String columnName, dynamic columnValue) async {
    log.info("In Sqlite Get");
    final db = database;
    dynamic result;

    if (db != null) {
      final List<Map<String, Object?>> maps = await db.query(tableName,
          where: '"' + columnName + '"= ?',
          whereArgs: [columnValue]
          );

      result = maps.toList();
    } else {
      await openDb();
    }
    if (result == null || result.isEmpty) {
      throw NoSuchDataException();
    }
    return result;
  }

  static Future<dynamic> getAll(DatabaseExecutor? db, String tableName) async {
    log.info("In Sqlite Get All");
    final db = database;
    dynamic result;

    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query(tableName);
      result = maps;

    } else {
      await openDb();
    }
    if (result == null) {
      throw NoSuchDataException();
    }
    return result;
  }

  static Future<void> update(DatabaseExecutor? db, String tableName, dynamic row, dynamic columnName, dynamic value) async {
    log.info("In Sqlite Update");
    final db = database;

    if (db != null) {
      await db.update(
        tableName,
        row.toMap(),
        where: '"' + columnName + '"= ?',
        whereArgs: [value],
      );
    } else {
      await openDb();
    }
  }

  static Future<void> delete(DatabaseExecutor? db, String tableName, dynamic columnName, dynamic value) async {
    log.info("In Sqlite Delete");
    final db = database;

    if (db != null) {
      if (columnName == null && value == null) {
        await db.delete(tableName);
      } else {
        await db.delete(
          tableName,
          where: '"' + columnName + '"= ?',
          whereArgs: [value],
        );
      }
    } else {
      await openDb();
    }
  }

  static Future<void> deleteAllRowsInTable(DatabaseExecutor? db, String tableName) async {
    log.info("In Sqlite Delete All Rows");
    final db = database;

    if (db != null) {
      await db.rawQuery('DELETE FROM $tableName');
    } else {
      await openDb();
    }
  }
}
