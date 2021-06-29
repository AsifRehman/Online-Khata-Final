import 'package:mongo_dart/mongo_dart.dart';
import 'package:onlinekhata/sqflite_database/DbProvider.dart';

var db;
DbProvider dbProvider = DbProvider();

void dbOpen() async {}

Future<void> openDbConnection(String userName,String password,String databaseName) async {
  db = await Db.create(
      'mongodb+srv://$userName:$password@cluster0.k6lme.mongodb.net/$databaseName?retryWrites=true&w=majority');
  await db.open();
}
//      'mongodb+srv://asif:cosoftcon123@cluster0.k6lme.mongodb.net/alkaram?retryWrites=true&w=majority');

Future<void> getPartyData() async {
  try {
    var collection = db.collection('Party');

    await dbProvider.addPartyItem(collection);
  } catch (e) {}
}

Future<void> getLedgerData() async {
  try {
    var ledgerCollection = db.collection('Ledger');
    await dbProvider.addLedgerItem(ledgerCollection);
  } catch (e) {}
}
