import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TokenManager {
  static const String tableName = "fcm_tokens";

  // Get the database instance
  Future<Database> _initializeDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "tokens.db");

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, token TEXT)",
        );
      },
    );
  }

  // Add a new token to the SQLite database
  Future<void> addToken(String token) async {
    final db = await _initializeDatabase();
    await db.insert(
      tableName,
      {'token': token},
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if exists
    );
  }

  // Retrieve all tokens
  Future<List<String>> getTokens() async {
    final db = await _initializeDatabase();
    final List<Map<String, dynamic>> result = await db.query(tableName);

    return result.map((row) => row['token'] as String).toList();
  }

  // Remove a token
  Future<void> removeToken(String token) async {
    final db = await _initializeDatabase();
    await db.delete(
      tableName,
      where: "token = ?",
      whereArgs: [token],
    );
  }
}
