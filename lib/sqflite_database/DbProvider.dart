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
import 'model/PartyTypeModel.dart';

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
        await sqliteDb.execute(delRecordTableInsert);
        await sqliteDb.execute(partyTypeTable);
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
          partyTypeDelTs INTEGER,
          partyDelTs INTEGER PRIMARY KEY,
          ledgerDelTs INTEGER,
          receiptDelTs INTEGER,
          paymentDelTs INTEGER
          ); """;

  static const delRecordTableInsert = """
          INSERT INTO DelRecord(PartyTypeDelTs, PartyDelTs, ledgerDelTs, receiptDelTs, paymentDelTs) VALUES(0, 0, 0, 0, 0);
          """;

  static const partyTypeTable = """
          CREATE TABLE IF NOT EXISTS PartyType (
          partyTypeID INTEGER PRIMARY KEY,
          partyTypeName TEXT,
          partyGroup TEXT,
          ts INTEGER
          );""";

  static const partyTable = """
          CREATE TABLE IF NOT EXISTS Party (
          partyID INTEGER PRIMARY KEY,
          partyName TEXT,
          partyTypeId INTEGER,
          debit INTEGER,
          credit INTEGER,
          total INTEGER,
          date INTEGER,
          mobile1 TEXT,
          mobile2 TEXT,
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
          CREATE VIEW IF NOT EXISTS PartyLeg AS SELECT 0 as vocNo, date, 'OP' tType, 
          'OPENING...' as description, partyID, partyName, partyTypeID, mobile1, mobile2, 
          debit, credit, IFNULL(debit,0)-IFNULL(credit,0) as Bal, 0 as ts 
          FROM Party 
          UNION ALL 
          SELECT vocNo, date, tType, 
          description, partyID, Null, null, null, null, 
          debit, credit, IFNULL(debit,0)-IFNULL(credit,0) as Bal, ts 
          FROM Ledger;""";

  static const partLegSumTable = """
          CREATE VIEW IF NOT EXISTS PartyLegSum AS SELECT partyID, MAX(partyName) as partyName, 
          MAX(partyTypeID) as partyTypeID, max(mobile1) as mobile1, max(mobile2) as mobile2, 
          sum(debit) as debit, sum(credit) as credit, SUM(Bal) as Bal, max(ts) as ts 
          FROM PartyLeg GROUP BY partyID;""";

  Future addNewPartyItem(String partyName, int partyTypeId, int debit, int credit) async {
    final sqliteDb = await init(); //open database

    int minusTs = await dbProvider.fetchPartyMinusTs();

    final partyModel = PartyModel(
      partyID: minusTs,
      partyName: partyName,
      partyTypeId: partyTypeId,
      debit: debit,
      credit: credit,
      mobile1: null,
      mobile2: null,
      ts: minusTs,
    );

    sqliteDb.insert(
      partyTableName,
      partyModel.toMap(),
    );
  }

  Future<int> fetchPartyMinusTs() async {
    final sqliteDb = await init();
    final result = await sqliteDb
        .rawQuery("SELECT IFNULL(MIN(ts),0) as timestamp FROM Party");
    if (result[0]["timestamp"] < 0) {
      return result[0]["timestamp"] - 1;
    } else {
      return -1;
    }
  }
 
  Future addNewPartyTypeItem(String partyType) async {
    final sqliteDb = await init(); //open database

    int minusTs = await dbProvider.fetchPartyTypeMinusTs();

    final partyModel = PartyTypeModel(
      partyTypeID: minusTs,
      partyTypeName: partyType,
      partyGroup: null,
      ts: minusTs,
    );

    sqliteDb.insert(
      partyTypeTableName,
      partyModel.toMap(),
    );
  }

  Future<int> fetchPartyTypeMinusTs() async {
    final sqliteDb = await init();
    final result = await sqliteDb
        .rawQuery("SELECT IFNULL(MIN(ts),0) as timestamp FROM PartyType");
    if (result[0]["timestamp"] < 0) {
      return result[0]["timestamp"] - 1;
    } else {
      return -1;
    }
  }

  Future addPartyTypeItem(var collection) async {
    final sqliteDb = await init(); //open database
    bool isUpdated = false;

    int maxTs = await dbProvider.fetchPartyTypeLastTs();
    await collection
        .find(where.gt('ts', maxTs).sortBy('ts'))
        .forEach((v) async {
      final partyModel = PartyTypeModel(
        partyTypeID: v['_id'],
        partyTypeName: v['PartyTypeName'].toString(),
        partyGroup: v['partyGroup'],
        ts: v['ts'],
      );

      isUpdated = await isPartyTypeExists(v['_id']);

      if (isUpdated)
        sqliteDb.update(partyTypeTableName, partyModel.toMap(),
            where: 'PartyTypeID=?', whereArgs: [v['_id']]);
      else
        sqliteDb.insert(
          partyTypeTableName,
          partyModel.toMap(),
        );

      // DELETE LOGIC
      //1. GET IDS TO DELETE FROM PARTY Type
      //2. DELETE FROM PARTY Type TABLE
      //3. UPDATE DEL PARTY Type TS.
    });
  }

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
        date: getDateTimeLedgerFormat(v['Date']),
        mobile1: v['Mobile1'],
        mobile2: v['Mobile2'],
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
        .find(where.gt('ts', maxTs).sortBy('ts'))
        .forEach((v) async {
      final ledgerModel = LedgerModel(
        id: v['_id'],
        partyID: v['PartyId'],
        vocNo: v['VocNo'],
        tType: v['TType'].toString(),
        description: v['Description'].toString(),
        date: getDateTimeLedgerFormat(v['Date']),
        debit: isKyNotNull(v['Debit']) ? v['Debit'] : 0,
        credit: isKyNotNull(v['Credit']) ? v['Credit'] : 0,
        ts: v['ts'],
        // bal: 0,
      );
      isUpdated = await isLedgerExists(v['_id']);

      if (isUpdated)
        sqliteDb.update(legderTableName, ledgerModel.toMap(),
            where: 'id=?', whereArgs: [v['_id']]);
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
      maxTs = v['ts'];
    });
    sqliteDb.rawUpdate("UPDATE DelRecord SET LedgerDelTs=$maxTs");
  }

  Future<List<PartyModel>> fetchPartyLegSum(
      String orderby, String orderByDirection, String cri) async {
    final sqliteDb = await init();
    //String cri = 'Bal>=0 OR Bal<0';
    if (cri == '') cri = '1=1';

    final maps = await sqliteDb.query('PartyLegSum',
        where: '$cri', orderBy: '$orderby $orderByDirection');

    return List.generate(maps.length, (i) {
      //create a list of Categories
      return PartyModel(
        partyID: maps[i]['partyID'],
        partyName: maps[i]['partyName'],
        debit: maps[i]['debit'],
        credit: maps[i]['credit'],
        mobile1: maps[i]['mobile1'],
        mobile2: maps[i]['mobile2'],
        total: maps[i]['Bal'],
      );
    });
  }

  Future<List<PartyTypeModel>> fetchPartyType() async {
    final sqliteDb = await init();

    final maps = await sqliteDb.query('PartyType', orderBy: 'partyTypeName');

    return List.generate(maps.length, (i) {
      //create a list of Categories
      return PartyTypeModel(
        partyTypeID: maps[i]["partyTypeID"],
        partyTypeName: maps[i]["partyTypeName"],
        partyGroup: maps[i]["partyGroup"],
      );
    });
  }

  Future<int> fetchPartyTypeLastTs() async {
    final sqliteDb = await init();
    final result = await sqliteDb
        .rawQuery("SELECT IFNULL(MAX(ts),0) as timestamp FROM PartyType");
    return result[0]["timestamp"];
  }

  Future<int> fetchPartyLastTs() async {
    final sqliteDb = await init();
    final result = await sqliteDb
        .rawQuery("SELECT IFNULL(MAX(ts),0) as timestamp FROM Party");
    return result[0]["timestamp"];
  }

  Future<bool> isPartyTypeExists(int id) async {
    final sqliteDb = await init();
    final result = await sqliteDb
        .rawQuery("SELECT PartyTypeID as id FROM PartyType WHERE id=$id");
    return result.isEmpty ? false : result[0]['id'] > 0;
  }

  Future<bool> isPartyExists(int id) async {
    final sqliteDb = await init();
    final result =
        await sqliteDb.rawQuery("SELECT PartyID as id FROM Party WHERE id=$id");
    return result.isEmpty ? false : result[0]['id'] > 0;
  }

  Future<bool> isLedgerExists(int id) async {
    final sqliteDb = await init();
    final result = await sqliteDb.rawQuery(
      "SELECT IFNULL(id,0) as id FROM Ledger WHERE id=$id",
    );
    return result.isEmpty ? false : true;
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
        "SELECT IFNULL(MAX(LedgerDelTs),0) as timestamp FROM DelRecord");
    return result[0]["timestamp"];
  }

  Future<List<PartyTypeModel>> fetchPartyTypesByPartTypeName(
      String partyTypeName) async {
    //returns the Categories as a list (array)

    final sqliteDb = await init();
    final maps = await sqliteDb.query(partyLegSumCreateViewTableName,
        where: "LOWER(partyName) LIKE ?",
        whereArgs: ['%$partyTypeName%'],
        orderBy: "ts DESC");

    return List.generate(maps.length, (i) {
      //create a list of Categories
      return PartyTypeModel(
        partyTypeID: maps[i]['partyTypeID'],
        partyTypeName: maps[i]['partyTypeName'],
        partyGroup: maps[i]['partyGroup'],
      );
    });
  }

  Future<List<PartyModel>> fetchPartyLegSumByPartName(String partyName) async {
    //returns the Categories as a list (array)

    final sqliteDb = await init();
    final maps = await sqliteDb.query(partyLegSumCreateViewTableName,
        where: "LOWER(partyName) LIKE ?",
        whereArgs: ['%$partyName%'],
        orderBy: "ts DESC");

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
        // bal: maps[i]['Bal'],
      );
    });
  }

  Future<List<LedgerModel>> fetchLedgerByStartAndEndDate(
      int partyId, int startDate, int endDate) async {
    final sqliteDb = await init();
    final maps = await sqliteDb.query('PartyLeg',
        where: "partyID = ? AND date BETWEEN  ? AND  ?",
        orderBy: "date DESC",
        whereArgs: [
          partyId,
          startDate,
          endDate
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
        // bal: maps[i]['Bal'],
      );
    });
  }

  Future<int> fetchLedgerOpening(int partyId, int startDate) async {
    final sqliteDb = await init();
    final result = await sqliteDb.rawQuery(
        "SELECT IFNULL(SUM(Bal),0) as opening FROM PartyLeg WHERE partyID=$partyId AND date<$startDate");
    return result[0]["opening"];
  }

  Future closesqliteDbConnection() async {
    final sqliteDb = await init();

    await sqliteDb.close();
  }
}
