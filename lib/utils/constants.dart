import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences sharedPreferences;

final String databaseName = "online_khata.db";
final String partyTableName = "Party";
final String legderTableName = "Ledger";
final String partyLegCreateViewTableName = "PartyLeg";
final String partyLegSumCreateViewTableName = "PartyLegSum";

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
