import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbClient {
  // Open the database and store the reference.
  Future<Database> database = null;

  Future<Database> getDatabaseWithCreatedTable() async {
    database = openDatabase(
      // Set the path to the database.
      join(await getDatabasesPath(), 'owner_db.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          "CREATE TABLE cache(id INTEGER PRIMARY KEY, data TEXT,context TEXT)",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    return database;
  }
}
