import 'dart:async';

import 'package:dairy_app_owner/models/CacheData.dart';
import 'package:dairy_app_owner/utilities/DbClient.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseOperations {
  // method for inserting items into the cart

  Future<void> insertProfileData(data, context) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    CacheData c = new CacheData(data: data, context: context);

    await db.insert(
      'cache',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //method for getting a list of cart items
  Future<List> getProfileData() async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map> maps = await db
        .rawQuery('select * from cache where context = ?', ["profile_data"]);
    return maps;
  }

  Future<int> checkProfileDataPresent(String productId) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('select * from cache where context = ?', [productId]);
    return maps.length;
  }

  Future<int> updateProfileData(String data, String context) async {
    print(data + context);
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    int count = await db.rawUpdate(
        "UPDATE cache SET data = ? WHERE context = ?", [data, context]);
    print(count);
    return count;
  }

  //messages

  Future<void> insertMessages(data, context) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    CacheData c = new CacheData(data: data, context: context);

    await db.insert(
      'cache',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //method for getting a list of cart items
  Future<List> getMessages() async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map> maps = await db
        .rawQuery('select * from cache where context = ?', ["messages"]);
    return maps;
  }

  Future<int> checkMessagesPresent(String msgContext) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('select * from cache where context = ?', [msgContext]);
    return maps.length;
  }

//settings

  Future<void> insertSettings(data, context) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    CacheData c = new CacheData(data: data, context: context);

    await db.insert(
      'cache',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List> getSettings() async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map> maps = await db
        .rawQuery('select * from cache where context = ?', ["settings"]);
    return maps;
  }

  Future<int> checkSettings(String settingContext) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('select * from cache where context = ?', [settingContext]);
    return maps.length;
  }

  Future<int> updateSettingsData(String data, String context) async {
    print(data + context);
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    int count = await db.rawUpdate(
        "UPDATE cache SET data = ? WHERE context = ?", [data, context]);
    print(count);
    return count;
  }

  //products

  Future<void> insertProducts(data, context) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    CacheData c = new CacheData(data: data, context: context);

    await db.insert(
      'cache',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List> getProducts() async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map> maps = await db
        .rawQuery('select * from cache where context = ?', ["products"]);
    return maps;
  }

  Future<int> checkProducts(String productContext) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('select * from cache where context = ?', [productContext]);
    return maps.length;
  }

  Future<int> updateProductData(String data, String context) async {
    print(data + context);
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    int count = await db.rawUpdate(
        "UPDATE cache SET data = ? WHERE context = ?", [data, context]);
    print(count);
    return count;
  }

//Areas

  Future<void> insertAres(data, context) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    CacheData c = new CacheData(data: data, context: context);
    await db.insert(
      'cache',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List> getAreas() async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map> maps =
        await db.rawQuery('select * from cache where context = ?', ["areas"]);
    return maps;
  }

  Future<int> checkAreas(String areaContext) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('select * from cache where context = ?', [areaContext]);
    return maps.length;
  }

  Future<int> updateAreaData(String data, String context) async {
    print(data + context);
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    int count = await db.rawUpdate(
        "UPDATE cache SET data = ? WHERE context = ?", [data, context]);
    print(count);
    return count;
  }

//milkman

  Future<void> insertMilkman(data, context) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    CacheData c = new CacheData(data: data, context: context);
    await db.insert(
      'cache',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List> getMilkman() async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map> maps =
        await db.rawQuery('select * from cache where context = ?', ["milkman"]);
    return maps;
  }

  Future<int> checkMilkmanPresent(String milkmanContext) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('select * from cache where context = ?', [milkmanContext]);
    return maps.length;
  }

  Future<int> updateMilkmanData(String data, String context) async {
    print(data + context);
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    int count = await db.rawUpdate(
        "UPDATE cache SET data = ? WHERE context = ?", [data, context]);
    print(count);
    return count;
  }

  //user
  Future<void> insertUser(data, context) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    CacheData c = new CacheData(data: data, context: context);
    await db.insert(
      'cache',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List> getUser() async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map> maps =
        await db.rawQuery('select * from cache where context = ?', ["user"]);
    return maps;
  }

  Future<int> checkUserPresent(String userContext) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('select * from cache where context = ?', [userContext]);
    return maps.length;
  }

  Future<int> updateUserData(String data, String context) async {
    print(data + context);
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    int count = await db.rawUpdate(
        "UPDATE cache SET data = ? WHERE context = ?", [data, context]);
    print(count);
    return count;
  }

  //purchase sale detail list

  Future<void> insertPurchaseSaleDetails(data, context) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    CacheData c = new CacheData(data: data, context: context);
    await db.insert(
      'cache',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List> getPurchaseSaleDetails() async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map> maps = await db.rawQuery(
        'select * from cache where context = ?', ["purchaseSaleDetails"]);
    return maps;
  }

  Future<int> checkPurchaseSaleDetailsPresent(String ctx) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('select * from cache where context = ?', [ctx]);
    return maps.length;
  }

  Future<int> updatePurchaseSalesDat(String data, String context) async {
    print(data + context);
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    int count = await db.rawUpdate(
        "UPDATE cache SET data = ? WHERE context = ?", [data, context]);
    print(count);
    return count;
  }

//milkman past transaction details

  Future<void> insertPastTransaction(data, context) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    CacheData c = new CacheData(data: data, context: context);
    await db.insert(
      'cache',
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List> getPastTransaction() async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map> maps = await db.rawQuery(
        'select * from cache where context = ?', ["past_transaction"]);
    return maps;
  }

  Future<int> checkPastTransaction(String pastTransactionCtx) async {
    DbClient dbClient = new DbClient();
    final Database db = await dbClient.getDatabaseWithCreatedTable();
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'select * from cache where context = ?', [pastTransactionCtx]);
    return maps.length;
  }

  // //method for updating cart items
  // Future<void> updateCartData(String c, int qty) async {
  //   DbClient dbClient = new DbClient();
  //   final Database db = await dbClient.getDatabaseWithCreatedTable();
  //   int count = await db
  //       .rawUpdate("UPDATE cart SET qty = ? WHERE productid = ?", [qty, c]);
  //   print(count);
  // }
}
