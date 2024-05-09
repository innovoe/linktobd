import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbManager {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    Database db = await openDatabase(path, version: 1, onCreate: _createTables);
    return db;
  }


  void _createTables(Database db, int version) async {
    // This method should handle creating initial tables if needed
  }

  Future<void> ensureTableExists(DbTable table) async {
    // print(table.columnsSql);
    final db = await database;
    var tableExists = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM sqlite_master WHERE type = ? AND name = ?',
        ['table', table.tableName]
    )) ?? 0;

    if (tableExists == 0) {
      await db.execute('CREATE TABLE ${table.tableName} (${table.columnsSql})');
    }
  }

  Future<void> sync(DbTable table, {String whereMatch = 'uuid'}) async {
    final db = await database;
    if (table.rows == null) return;

    for (var row in table.rows!) {
      // Checking if row exists by UUID
      var existingRows = await db.query(
          table.tableName,
          where: '$whereMatch = ?',
          whereArgs: [row['$whereMatch']]
      );

      if (row.containsKey('remove') && row['remove'] == 1) {
        // Delete the row if 'remove' flag is set and row exists
        if (existingRows.isNotEmpty) {
          await db.delete(table.tableName, where: 'uuid = ?', whereArgs: [row['uuid']]);
        }
      } else {
        if (existingRows.isNotEmpty) {
          // Update the row if it exists
          await db.update(
              table.tableName,
              row,
              where: '$whereMatch = ?',
              whereArgs: [row['$whereMatch']]
          );
        } else {
          // Insert the new row if it does not exist
          await db.insert(table.tableName, row, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    }
  }


  Future<List<Map<String, dynamic>>> getData(String tableName, String orderByColumn) async {
    final db = await database;
    return await db.query(
        tableName,
        orderBy: '$orderByColumn DESC',
        limit: 100
    );
  }

  Future<void> dropTable(String tableName) async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<void> insertRows(DbTable table) async {
    final db = await database;
    for (var row in table.rows ?? []) {
      await db.insert(table.tableName, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> updateRows(String tableName, Map<String, dynamic> values, String where, List<dynamic> whereArgs) async {
    final db = await database;
    await db.update(tableName, values, where: where, whereArgs: whereArgs);
  }

  Future<void> deleteRows(String tableName, String where, List<dynamic> whereArgs) async {
    final db = await database;
    await db.delete(tableName, where: where, whereArgs: whereArgs);
  }
}

class DbTable {
  final String tableName;
  final List<String> columns;
  final List<Map<String, dynamic>>? rows;

  DbTable({required this.tableName, required this.columns, this.rows});

  String get columnsSql => columns.map((column) {
    if (column == 'id') {
      return '$column INTEGER PRIMARY KEY AUTOINCREMENT';
    } else {
      return '$column TEXT';
    }
  }).join(', ');
}
