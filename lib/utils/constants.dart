import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences sharedPreferences;

final String databaseName = "online_khata.db";
final String partyTypeTableName = "PartyType";
final String partyTableName = "Party";
final String legderTableName = "Ledger";
final String partyLegCreateViewTableName = "PartyLeg";
final String partyLegSumCreateViewTableName = "PartyLegSum";
final String partyTypeLegSumCreateViewTableName = "PartyTypeLegSum";

setLocalDb(bool localDb) async {
  sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setBool("localDb", localDb);
  // ignore: deprecated_member_use
  sharedPreferences.commit();
}

Future<bool> getLocalDb() async {
  sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getBool("localDb");
}

setLastSyncDateTime(String lastSyncDateTime) async {
  sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("lastSyncDateTime", lastSyncDateTime);
  // ignore: deprecated_member_use
  sharedPreferences.commit();
}

Future<String> getLastSyncDateTime() async {
  sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("lastSyncDateTime");
}

setUserName(String userName) async {
  sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("userName", userName);
  // ignore: deprecated_member_use
  sharedPreferences.commit();
}

Future<String> getUserName() async {
  sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("userName");
}

setPassword(String password) async {
  sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("password", password);
  // ignore: deprecated_member_use
  sharedPreferences.commit();
}

Future<String> getPassword() async {
  sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("password");
}

setDatabaseName(String databaseName) async {
  sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("databaseName", databaseName);
  // ignore: deprecated_member_use
  sharedPreferences.commit();
}

Future<String> getDatabaseName() async {
  sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("databaseName");
}

String getDateTimeFormat(String date) {
  final DateTime now = DateTime.parse(date);
  // final DateFormat formatter = DateFormat('dd MMM yyyy h:mm a');
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  final String formatted = formatter.format(now);

  return formatted;
}

int getDateTimeLedgerFormat(DateTime date) {
  int milliseconds = date.millisecondsSinceEpoch;

  return milliseconds;
}

String getDateFromMillisecound(int milliseconds) {
  DateTime datetime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  String formatted = formatter.format(datetime);

  return formatted;
}

String getDateFromMillisecoundDate(int milliseconds) {
  DateTime datetime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  String formatted = formatter.format(datetime);
  return formatted;
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd-MM-yyyy').format(now);

  return formattedDate;
}

bool isKeyNotNull(Object param1) {
  if (param1 != null && param1 != "")
    return true;
  else
    return false;
}

bool isKyNotNull(Object param1) {
  if (param1 != null)
    return true;
  else
    return false;
}
