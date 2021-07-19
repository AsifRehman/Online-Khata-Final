import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:onlinekhata/sqflite_database/DbProvider.dart';
import 'package:onlinekhata/sqflite_database/model/LedgerModel.dart';
import 'package:onlinekhata/ui/pdf_viewer/report_pdf.dart';
import 'package:onlinekhata/utils/constants.dart';
import 'package:onlinekhata/utils/custom_loader_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class LedgerDetailScreen extends StatefulWidget {
  static String id = 'ledger_detail_screen';

  final int iD;
  final String partName;
  final String partyMobileNo1;
  final String partyMobileNo2;

  const LedgerDetailScreen(
      {Key key,
      this.iD,
      this.partName,
      this.partyMobileNo1,
      this.partyMobileNo2})
      : super(key: key);

  @override
  _LedgerDetailScreenState createState() => _LedgerDetailScreenState(
      iD: this.iD,
      partName: this.partName,
      partyMobileNo1: this.partyMobileNo1,
      partyMobileNo2: this.partyMobileNo2);
}

int totalDebit = 0;
int totalCredit = 0;
int totalBalance = 0;

class _LedgerDetailScreenState extends State<LedgerDetailScreen> {
  int iD;
  String partName;
  String partyMobileNo1;
  String partyMobileNo2;

  bool loading = true;

  int opening = 0;
  int closing = 0;

  DbProvider dbProvider = DbProvider();
  List<LedgerModel> ledgerModelList = [];

  bool _checkConfiguration() => true;
  int startDateMilli, endDateMilli,startDateForCalendarMilli;
  String startDateStr = "", endDateStr = "";

  String smsMessage = "";
  List<String> recipients = [];

  _LedgerDetailScreenState(
      {this.iD, this.partName, this.partyMobileNo1, this.partyMobileNo2});

  @override
  void dispose() {
    totalDebit = 0;
    totalCredit = 0;
    totalBalance = 0;

    super.dispose();
  }

  @override
  void initState() {
    getLocalDb().then((value) {
      if (value != null && value == true) {
        if (_checkConfiguration()) {
          Future.delayed(Duration.zero, () {
            showLoaderDialog(context);
          });
        }
        getLedgerDataFromLocalDB(widget.iD);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buildTopBar(context, width),
            buildDates(context),
            buildOpeningClosing(context),
            buildLedgerHeading(context),
            buildLedgerDetail(),
            ledgerModelList != null && ledgerModelList.length > 0
                ? buildPDFbuttons(context, width)
                : Container()
          ],
        ),
      ),
    );
  }

  Container buildPDFbuttons(BuildContext context, double width) {
    return Container(
      margin: EdgeInsets.fromLTRB(0.0, 0, 0.0, 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              var status = await Permission.storage.status;
              try {
                if (await Permission.storage.request().isGranted) {
                  if (await _requestPermission(Permission.storage)) {
                    generatePdfReport(
                        context, widget.partName, ledgerModelList, "from_view");
                  } else {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Alert"),
                            content: new Text(
                                "Please grant Storage permission from settings."),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  openAppSettings();
                                },
                              ),
                            ],
                          );
                        });
                  }
                } else {
                  if (status.isPermanentlyDenied) {
                    // The user opted to never again see the permission request dialog for this
                    // app. The only way to change the permission's status now is to let the
                    // user manually enable it in the system settings.
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Alert"),
                            content: new Text(
                                "Please grant Storage permission from settings."),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  openAppSettings();
                                },
                              ),
                            ],
                          );
                        });
                  }
                  // You can can also directly ask the permission about its status.
                  else if (status.isRestricted) {
                    // The OS restricts access, for example because of parental controls.
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Alert"),
                            content: new Text(
                                "Please grant Storage  permission from settings."),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  } else if (status.isDenied) {
                    // The OS restricts access, for example because of parental controls.
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Alert"),
                            content: new Text(
                                "Please grant Storage permission from settings."),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  } else if (e
                      .toString()
                      .contains('The getter \'path\' was called on null')) {
                    return;
                  } else {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Alert"),
                            content: new Text(
                                "Please grant Storage  permission from settings."),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  }
                }
              } catch (e) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text("Alert"),
                        content: new Text(
                            "Please grant Storage  permission from settings."),
                        actions: <Widget>[
                          new TextButton(
                            child: new Text('OK'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              }
            },
            child: Container(
              width: 105,
              height: 35,
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/ic_view.png",
                      width: 16, height: 16, color: Colors.blueAccent),
                  Container(
                      margin: EdgeInsets.fromLTRB(2.0, 0, 0.0, 0.0),
                      child: Text(
                        'Download',
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 13),
                      )),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              recipients.clear();

              if (isKeyNotNull(partyMobileNo1)) {
                recipients.add(partyMobileNo1);
              }
              if (isKeyNotNull(partyMobileNo2)) {
                recipients.add(partyMobileNo2);
              }

              _sendSMS(getMsgLedgerFormat(), recipients);
            },
            child: Container(
              width: 85,
              height: 35,
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/ic_sms.png",
                      width: 16, height: 16, color: Colors.blueAccent),
                  Container(
                      margin: EdgeInsets.fromLTRB(4.0, 0, 0.0, 0.0),
                      child: Text(
                        'Sms',
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 13),
                      )),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              var status = await Permission.storage.status;
              try {
                if (await Permission.storage.request().isGranted) {
                  generatePdfReport(
                      context, widget.partName, ledgerModelList, "from_share");
                } else {
                  if (status.isPermanentlyDenied) {
                    // The user opted to never again see the permission request dialog for this
                    // app. The only way to change the permission's status now is to let the
                    // user manually enable it in the system settings.
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Alert"),
                            content: new Text(
                                "Please grant Storage permission from settings."),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  openAppSettings();
                                },
                              ),
                            ],
                          );
                        });
                  }
                  // You can can also directly ask the permission about its status.
                  else if (status.isRestricted) {
                    // The OS restricts access, for example because of parental controls.
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Alert"),
                            content: new Text(
                                "Please grant Storage  permission from settings."),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  } else if (status.isDenied) {
                    // The OS restricts access, for example because of parental controls.
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Alert"),
                            content: new Text(
                                "Please grant Storage permission from settings."),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  } else if (e
                      .toString()
                      .contains('The getter \'path\' was called on null')) {
                    return;
                  } else {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Alert"),
                            content: new Text(
                                "Please grant Storage  permission from settings."),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  }
                }
              } catch (e) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text("Alert"),
                        content: new Text(
                            "Please grant Storage  permission from settings."),
                        actions: <Widget>[
                          new TextButton(
                            child: new Text('OK'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              }
            },
            child: Container(
              width: 85,
              height: 35,
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/ic_share.png",
                      width: 16, height: 16, color: Colors.blueAccent),
                  Container(
                      margin: EdgeInsets.fromLTRB(4.0, 0, 0.0, 0.0),
                      child: Text(
                        'Share',
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 13),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getMsgLedgerFormat() {
    final oCcy = new NumberFormat("#,##0", "en_US");

    smsMessage += "Payment Request";
    smsMessage += "\n\n";

    smsMessage += "Dear,";
    smsMessage += "\n";
    smsMessage += "Balance RS " +
        oCcy.format(closing.abs()).toString() +
        " is outstanding in your ledger.";
    smsMessage += "\n";

    smsMessage += "Thank for your cooperation.";

    return smsMessage;
  }

  Expanded buildLedgerDetail() {
    return Expanded(
      child: loading == true
          ? Container()
          : ledgerModelList == null
              ? Center(
                  child: Text('No record found.'),
                )
              : ledgerModelList.length == 0
                  ? Center(
                      child: Text('No record found.'),
                    )
                  : new ListView.builder(
                      //  controller: scrollController,
                      itemCount: ledgerModelList.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return new InkWell(
                          child: new LedgerItem(ledgerModelList[index], index),
                        );
                      },
                    ),
    );
  }

  Container buildLedgerHeading(BuildContext context) {
    final oCcy = new NumberFormat("#,##0", "en_US");

    return Container(
      margin: EdgeInsets.fromLTRB(15.0, 15.0, 12.0, 10.0),
      color: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 0.0),
              width: MediaQuery.of(context).size.width * 0.5,
              child: Text(
                "Ledger Detail",
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      "Debit",
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ledgerModelList == null || ledgerModelList.length == 0
                      ? Container()
                      : Container(
                          child: Text(
                            "" + oCcy.format(totalDebit).toString(),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      "Credit",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ledgerModelList == null || ledgerModelList.length == 0
                      ? Container()
                      : Container(
                          child: Text(
                            "" + oCcy.format(totalCredit).toString(),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildDates(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(14.0, 15.0, 14.0, 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              selectStartDate(context);
            },
            child: Container(
              child: Row(
                children: [
                  Container(
                    child: Text(
                      'Start Date',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      startDateStr,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              selectEndDate(context);
            },
            child: Container(
              child: Row(
                children: [
                  Container(
                    child: Text(
                      'End Date',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      endDateStr,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendSMS(String message, List<String> recipients) async {
    String _result = await sendSMS(message: message, recipients: recipients)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  Container buildOpeningClosing(BuildContext context) {
    final oCcy = new NumberFormat("#,##0", "en_US");

    return Container(
      margin: EdgeInsets.fromLTRB(14.0, 15.0, 14.0, 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                Container(
                  child: Text(
                    'Opening',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    oCcy.format(opening.abs()).toString(),
                    style: TextStyle(
                      color: opening >= 0 ? Colors.red : Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: [
                Container(
                  child: Text(
                    'Closing:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blueAccent,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    oCcy.format(closing.abs()).toString(),
                    style: TextStyle(
                      color: closing >= 0 ? Colors.red : Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container buildTopBar(BuildContext context, double width) {
    return Container(
      height: 60,
      margin: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
      width: MediaQuery.of(context).size.width - 1,
      color: Colors.blue,
      child: Container(
        margin: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(5.0, 0, 0.0, 0.0),
              child: new IconButton(
                icon: Image.asset(
                  'assets/ic_back.png',
                  width: 40,
                  height: 40,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Container(
              width: width * 0.7,
              margin: EdgeInsets.fromLTRB(10.0, 0, 0.0, 0.0),
              child: new Text(
                partName,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showLoaderDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          CustomLoaderDialog(title: "Loading..."),
    );
  }

  selectStartDate(BuildContext context) async {
    try {
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(startDateForCalendarMilli);
      DateTime initialDate = new DateTime.fromMillisecondsSinceEpoch(startDateMilli);

      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: date,
        lastDate: DateTime(2040),
      );
      if (picked != null && picked != DateTime.now())
        setState(() {
          if (picked.day <= 9) {
            startDateStr = "0" + picked.day.toString() + "-";
          } else {
            startDateStr = picked.day.toString() + "-";
          }

          if (picked.month <= 9) {
            startDateStr +=
                "0" + picked.month.toString() + "-" + picked.year.toString();
          } else {
            startDateStr +=
                picked.month.toString() + "-" + picked.year.toString();
          }

          startDateMilli = picked.millisecondsSinceEpoch;
          getFetchLedgerOpeningBalance(widget.iD, startDateMilli);
        });
    } catch (e) {
      int i = 0;
    }
  }

  void getFetchLedgerOpeningBalance(int partID, int startDateMilli) {
    dbProvider.fetchLedgerOpening(widget.iD, startDateMilli).then((value) {
      if (value != null) {
        setState(() {
          opening = value;
        });
      }
    });
  }

  selectEndDate(BuildContext context) async {
    try {
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(startDateForCalendarMilli);

      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), // Refer step 1
        firstDate: date,
        lastDate: DateTime.now(),
      );
      if (picked != null && picked != DateTime.now())
        setState(() {
          if (picked.day <= 9) {
            endDateStr = "0" + picked.day.toString() + "-";
          } else {
            endDateStr = picked.day.toString() + "-";
          }
          if (picked.month <= 9) {
            endDateStr +=
                "0" + picked.month.toString() + "-" + picked.year.toString();
          } else {
            endDateStr +=
                picked.month.toString() + "-" + picked.year.toString();
          }

          loading = true;
        });
      endDateMilli = picked.millisecondsSinceEpoch;
      showLoaderDialog(context);

      getBetweenDatesData(startDateMilli, endDateMilli);
    } catch (e) {
      int i = 0;
    }
  }

  void getBetweenDatesData(int startDateMilli, int endDate) {
    dbProvider
        .fetchLedgerByStartAndEndDate(widget.iD, startDateMilli, endDate)
        .then((value) {
      ledgerModelList = value;

      setState(() {
        for (int i = 0; i < ledgerModelList.length; i++) {
          if (isKyNotNull(ledgerModelList[i].debit)) {
            totalDebit = totalDebit + ledgerModelList[i].debit;
          }
          if (isKyNotNull(ledgerModelList[i].credit)) {
            totalCredit = totalCredit + ledgerModelList[i].credit;
          }
          closing = opening + totalDebit - totalCredit;
        }

        loading = false;
      });
      Navigator.pop(context);
    });
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  getLedgerDataFromLocalDB(int iD) async {
    dbProvider.fetchLedgerByPartyId(iD).then((value) {
      ledgerModelList = value;

      setState(() {
        for (int i = 0; i < ledgerModelList.length; i++) {
          if (isKyNotNull(ledgerModelList[i].debit)) {
            totalDebit = totalDebit + ledgerModelList[i].debit;
          }
          if (isKyNotNull(ledgerModelList[i].credit)) {
            totalCredit = totalCredit + ledgerModelList[i].credit;
          }
          startDateMilli = ledgerModelList[i].date;
          startDateForCalendarMilli = ledgerModelList[i].date;
        }
        if (isKeyNotNull(startDateMilli)) {
          startDateStr = getDateFromMillisecound(startDateMilli);
        }
        endDateStr = getCurrentDate();
        closing = opening + totalDebit - totalCredit;

        loading = false;
      });

      getFetchLedgerOpeningBalance(widget.iD, startDateMilli);

      Navigator.pop(context);
    });
  }
}

class LedgerItem extends StatelessWidget {
  final LedgerModel _item;
  final int index;

  LedgerItem(this._item, this.index);

  @override
  Widget build(BuildContext context) {
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(_item.date);
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    String formatted = formatter.format(datetime);
    final oCcy = new NumberFormat("#,##0", "en_US");

    totalBalance =
        isKyNotNull(_item.debit) ? totalBalance + _item.debit : totalBalance;
    totalBalance =
        isKyNotNull(_item.credit) ? totalBalance - _item.credit : totalBalance;

    return new Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Divider(
            height: 2.0,
            color: Colors.grey,
          ),
          Container(
              margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.47,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              isKeyNotNull(_item.vocNo)
                                  ? Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0.0, 0.0, 0.0, 0.0),
                                            child: Text(
                                              'VocNo:',
                                              maxLines: 3,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                2.0, 0.0, 0.0, 0.0),
                                            child: Text(
                                              _item.vocNo.toString(),
                                              maxLines: 1,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              isKeyNotNull(_item.tType)
                                  ? Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0.0, 2.0, 0.0, 0.0),
                                            child: Text(
                                              'TType:',
                                              maxLines: 1,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                2.0, 2.0, 0.0, 0.0),
                                            child: Text(
                                              _item.tType.toString(),
                                              maxLines: 3,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Row(
                                  children: [
                                    Container(
                                      color: Color(0xffDCDCDC),
                                      margin: EdgeInsets.fromLTRB(
                                          0.0, 2.0, 0.0, 0.0),
                                      child: Text(
                                        'Balance:  ',
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Color(0xffDCDCDC),
                                      margin: EdgeInsets.fromLTRB(
                                          0.0, 2.0, 0.0, 0.0),
                                      child: Text(
                                       "RS " + oCcy.format(totalBalance.abs()).toString(),
                                       //  "RS " + _item.bal.abs().toString(),
                                        maxLines: 2,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              isKeyNotNull(_item.description)
                                  ? Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      margin: EdgeInsets.fromLTRB(
                                          0.0, 2.0, 0.0, 0.0),
                                      child: Text(
                                        _item.description
                                            .toString()
                                            .replaceAll("\n", " "),

                                        //  "ddfdf ddfd fdf ",
                                        maxLines: 3,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    )
                                  : Container(),
                              isKeyNotNull(_item.date)
                                  ? Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0.0, 2.0, 0.0, 0.0),
                                      child: Text(
                                        formatted.toString(),
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        isKeyNotNull(_item.debit) && _item.debit != 0
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                margin:
                                    EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  oCcy.format(_item.debit).toString(),
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Text(
                                  "",
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                        isKeyNotNull(_item.credit) && _item.credit != 0
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Text(
                                  oCcy.format(_item.credit).toString(),
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Text(
                                  "",
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  bool isKeyNotNull(Object param1) {
    if (param1 != null && param1 != "")
      return true;
    else
      return false;
  }
}
