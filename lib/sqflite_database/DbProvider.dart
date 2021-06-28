import 'dart:io';
import 'dart:async';

import 'package:onlinekhata/mongo_db/db_connection.dart';
import 'package:onlinekhata/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'model/LedgerModel.dart';
import 'model/PartyModel.dart';

class DbProvider {
  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, databaseName);

    return await openDatabase(
      //open the database or create a database if there isn't any
      path,
      version: 1,
      onCreate: (Database sqliteDb, int version) async {
        // await sqliteDb.execute(dateTable);
        await sqliteDb.execute(delRecordTable);
        await sqliteDb.execute(partyTable);
        await sqliteDb.execute(legderTable);
        await sqliteDb.execute(partLegTable);
        await sqliteDb.execute(partLegSumTable);
      },
    );
  }

  static const dateTable = """
          CREATE TABLE IF NOT EXISTS TBL_DATE (
          sDate INTEGER,
          eDate INTEGER
          );""";

  static const delRecordTable = """
          CREATE TABLE IF NOT EXISTS DelRecord (
          partyDelTs INTEGER,
          ledgerDelTs INTEGER,
          receiptDelTs INTEGER,
          paymentDelTs INTEGER
          ); INSERT INTO DelRecord(PartyDelTs, ledgerDelTs, receiptDelTs, paymentDelTs) VALUES(0, 0, 0, 0) """;

  static const partyTable = """
          CREATE TABLE IF NOT EXISTS Party (
          partyID INTEGER PRIMARY KEY,
          partyName TEXT,
          partyTypeId INTEGER,
          debit INTEGER,
          credit INTEGER,
          total INTEGER,
          ts INTEGER
          );""";

  static const legderTable = """
          CREATE TABLE IF NOT EXISTS Ledger (
          id INTEGER PRIMARY KEY,
          partyID INTEGER,
          vocNo INTEGER,
          tType TEXT,
          description TEXT,
          date INTEGER,
          debit INTEGER,
          credit INTEGER,
          ts INTEGER
          );""";

  static const partLegTable = """
          CREATE VIEW IF NOT EXISTS PartyLeg AS SELECT 0 as vocNo, 1420118725000 as date, 'OP' tType, 'OPENING...' as description, partyID, partyName, debit, credit, IFNULL(debit,0)-IFNULL(credit,0) as Bal FROM Party UNION ALL SELECT vocNo, date, tType, description, partyID, Null, debit, credit, IFNULL(debit,0)-IFNULL(credit,0) as Bal FROM Ledger;""";

  static const partLegSumTable = """
          CREATE VIEW IF NOT EXISTS PartyLegSum AS SELECT partyID, MAX(partyName) as partyName, SUM(Bal) as Bal FROM PartyLeg GROUP BY partyID;""";

  Future addPartyItem(var collection) async {
    final sqliteDb = await init(); //open database
    bool isUpdated = false;

    int maxTs = await dbProvider.fetchPartyLastTs();
    await collection
        .find(where.gt('ts', maxTs).sortBy('ts'))
        .forEach((v) async {
      final partyModel = PartyModel(
        partyID: v['_id'],
        partyName: v['PartyName'].toString(),
        partyTypeId: v['PartyTypeId'],
        debit: isKyNotNull(v['Debit'].toString()) ? v['Debit'] : 0,
        credit: isKyNotNull(v['Credit']) ? v['Credit'] : 0,
        ts: v['ts'],
      );

      isUpdated = await isPartyExists(v['_id']);

      if (isUpdated)
        sqliteDb.update(partyTableName, partyModel.toMap(),
            where: 'PartyID=?', whereArgs: [v['_id']]);
      else
        sqliteDb.insert(
          partyTableName,
          partyModel.toMap(),
        );

      // DELETE LOGIC
      //1. GET IDS TO DELETE FROM PARTY
      //2. DELETE FROM PARTY TABLE
      //3. UPDATE DEL PARTY TS.
    });
  }

  //Leger table
  Future addLedgerItem(var ledgerCollection) async {
    final sqliteDb = await init(); //open database
    bool isUpdated = false;
    int maxTs = await dbProvider.fetchLedgerLastTs();

    await ledgerCollection
        .find(where.gt('ts', maxTs).sortBy('ts').limit(1000))
        .forEach((v) async {
      final ledgerModel = LedgerModel(
        id: v['_id'],
        partyID: v['PartyID'],
        vocNo: v['VocNo'],
        tType: v['TType'].toString(),
        description: v['Description'].toString(),
        date: getDateTimeLedgerFormat(v['Date']),
        debit: isKyNotNull(v['Debit']) ? v['Debit'] : 0,
        credit: isKyNotNull(v['Credit']) ? v['Credit'] : 0,
        ts: v['ts'],
      );
      isUpdated = await isLedgerExists(v['_id']);

      if (isUpdated)
        sqliteDb.update(partyTableName, ledgerModel.toMap(),
            where: 'ID=?', whereArgs: [v['_id']]);
      else
        sqliteDb.insert(legderTableName, ledgerModel.toMap());
    });
    var ledgerDelCollection = db.collection('Ledger_Del');
    await delLedgerItem(ledgerDelCollection);
  }

  //Delete Leger table
  Future delLedgerItem(var ledgerDelCollection) async {
    final sqliteDb = await init(); //open database
    int maxTs = await dbProvider.fetchLedgerDelLastTs();

    await ledgerDelCollection
        .find(where.gt('ts', maxTs).sortBy('ts'))
        .forEach((v) async {
      sqliteDb.delete(legderTableName, where: 'ID=?', whereArgs: [v['_id']]);
      maxTs = v['_id'];
    });
    sqliteDb.rawUpdate("UPDATE DelRecord SET LedgerDelTs=$maxTs");
  }

  Future<List<PartyModel>> fetchParties() async {
    final sqliteDb = await init();
    final maps = await sqliteDb.query(partyTableName);

    return List.generate(maps.length, (i) {
      //create a list of Categories
      return PartyModel(
        partyID: maps[i]['partyID'],
        partyName: maps[i]['partyName'],
        debit: maps[i]['debit'],
        credit: maps[i]['credit'],
        total: maps[i]['total'],
      );
    });
  }

  Future<List<PartyModel>> fetchPartyLegSum() async {
    final sqliteDb = await init();
    final maps = await sqliteDb.query(partyLegSumCreateViewTableName);

    return List.generate(maps.length, (i) {
      //create a list of Categories
      return PartyModel(
        partyID: maps[i]['partyID'],
        partyName: maps[i]['partyName'],
        debit: maps[i]['debit'],
        credit: maps[i]['credit'],
        total: maps[i]['Bal'],
      );
    });
  }

  Future<int> fetchPartyLastTs() async {
    final sqliteDb = await init();
    final result = await sqliteDb
        .rawQuery("SELECT IFNULL(MAX(ts),0) as timestamp FROM Party");
    return result[0]["timestamp"];
  }

  Future<bool> isPartyExists(int id) async {
    final sqliteDb = await init();
    final result =
        await sqliteDb.rawQuery("SELECT PartyID as id FROM Party WHERE id=$id");
    return result.isEmpty ? false : result[0]['id'] > 0;
  }

  Future<bool> isLedgerExists(int id) async {
    final sqliteDb = await init();
    final result = await sqliteDb
        .rawQuery("SELECT IFNULL(id,0) as id FROM Ledger WHERE id=$id");
    return result.isEmpty ? false : result[0][id] > 0;
  }

  Future<int> fetchLedgerLastTs() async {
    final sqliteDb = await init();
    final result = await sqliteDb
        .rawQuery("SELECT IFNULL(MAX(ts),0) as timestamp FROM Ledger");
    return result[0]["timestamp"];
  }

  Future<int> fetchLedgerDelLastTs() async {
    final sqliteDb = await init();
    final result = await sqliteDb.rawQuery(
        "SELECT IFNULL(MAX(LedgerTs),0) as timestamp FROM DelRecords");
    return result[0]["timestamp"];
  }

  Future<List<PartyModel>> fetchPartyByPartName(String partyName) async {
    //returns the Categories as a list (array)

    final sqliteDb = await init();
    final maps = await sqliteDb.query(partyTableName,
        where: "LOWER(partyName) LIKE ?", whereArgs: ['%$partyName%']);

    return List.generate(maps.length, (i) {
      //create a list of Categories
      return PartyModel(
        partyID: maps[i]['partyID'],
        partyName: maps[i]['partyName'],
        debit: maps[i]['debit'],
        credit: maps[i]['credit'],
        total: maps[i]['total'],
      );
    });
  }

  Future<List<PartyModel>> fetchPartyLegSumByPartName(String partyName) async {
    //returns the Categories as a list (array)

    final sqliteDb = await init();
    final maps = await sqliteDb.query(partyLegSumCreateViewTableName,
        where: "LOWER(partyName) LIKE ?", whereArgs: ['%$partyName%']);

    return List.generate(maps.length, (i) {
      //create a list of Categories
      return PartyModel(
        partyID: maps[i]['partyID'],
        partyName: maps[i]['partyName'],
        debit: maps[i]['debit'],
        credit: maps[i]['credit'],
        total: maps[i]['Bal'],
      );
    });
  }

  Future<List<LedgerModel>> fetchLedger() async {
    final sqliteDb = await init();
    final maps = await sqliteDb.query(partLegTable);

    return List.generate(maps.length, (i) {
      //create a list of Categories
      return LedgerModel(
        partyID: maps[i]['partyID'],
        vocNo: maps[i]['vocNo'],
        tType: maps[i]['tType'],
        description: maps[i]['description'],
        date: maps[i]['date'],
        debit: maps[i]['debit'],
        credit: maps[i]['credit'],
      );
    });
  }

  Future<List<LedgerModel>> fetchLedgerByPartyId(int partyId) async {
    //returns the Categories as a list (array)

    final sqliteDb = await init();
    final maps = await sqliteDb.query('PartyLeg',
        where: "partyID = ?",
        orderBy: "date DESC",
        whereArgs: [
          partyId
        ]); //query all the rows in a table as an array of maps

    return List.generate(maps.length, (i) {
      //create a list of Categories
      return LedgerModel(
        partyID: maps[i]['partyID'],
        vocNo: maps[i]['vocNo'],
        tType: maps[i]['tType'],
        description: maps[i]['description'],
        date: maps[i]['date'],
        debit: maps[i]['debit'],
        credit: maps[i]['credit'],
      );
    });
  }

  Future closesqliteDbConnection() async {
    final sqliteDb = await init();

    await sqliteDb.close();
  }
}
