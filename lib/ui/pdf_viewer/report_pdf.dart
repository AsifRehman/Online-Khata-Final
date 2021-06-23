import 'package:intl/intl.dart';
import 'package:onlinekhata/model/report_model.dart';
import 'package:onlinekhata/sqflite_database/model/LedgerModel.dart';
import 'package:onlinekhata/ui/pdf_viewer/pdf_viewer_page.dart';
import 'package:onlinekhata/utils/constants.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart' as material;
import 'package:pdf/widgets.dart';
import 'package:share/share.dart';

generatePdfReport(context, String partName, List<LedgerModel> list,
    String viewOrDownload) async {
  final Document pdf = Document();
  final baseColor = PdfColors.cyan;
  const tableHeaders = [
    'VocNo',
    'TType',
    'Date',
    'Detail',
    'Debit',
    'Credit',
    'Total Balance'
  ];
  int totalBal = 0, totalDebit = 0, totalCredit = 0;
  List<ReportModel> ledgerList = [];

  ledgerList.clear();

  // Timestamp t;
  // DateTime d;

  for (int i = list.length - 1; i >= 0; i--) {
    // if (isKeyNotNull(list[i].date)) {
    //   t = list[i].data["Date"];
    //   d = t.toDate();
    // }

    totalDebit =
        isKyNotNull(list[i].debit) ? totalDebit + list[i].debit : totalDebit;
    totalCredit = isKyNotNull(list[i].credit)
        ? totalCredit + list[i].credit
        : totalCredit;

    totalBal = isKyNotNull(list[i].debit) ? totalBal + list[i].debit : totalBal;
    totalBal =
        isKyNotNull(list[i].credit) ? totalBal - list[i].credit : totalBal;

    ledgerList.add(new ReportModel(
        isKeyNotNull(list[i].vocNo) ? list[i].vocNo : 0,
        isKeyNotNull(list[i].tType) ? list[i].tType : "",
        isKeyNotNull(list[i].date) ? getDateTimeFormat(list[i].date) : "",
        isKeyNotNull(list[i].description) ? list[i].description : "",
        isKyNotNull(list[i].debit) ? list[i].debit : 0,
        isKyNotNull(list[i].credit) ? list[i].credit : 0,
        totalBal));
  }

  // pdf.addPage(pw.Page(
  //     pageFormat: PdfPageFormat.a4,
  //
  //     build: (pw.Context context) {
  //       return  pw.Text("Hello World"); // Center
  //     })); // Page

  // Data table
  final table = pw.Table.fromTextArray(
    border: null,
    headers: tableHeaders,
    data: List<List<dynamic>>.generate(
      ledgerList.length,
      (index) => <dynamic>[
        ledgerList[index].vocNo,
        ledgerList[index].tType,
        ledgerList[index].date,
        ledgerList[index].desc,
        ledgerList[index].debit,
        ledgerList[index].credit,
        ledgerList[index].totalBalance < 0
            ? ledgerList[index].totalBalance.abs()
            : ledgerList[index].totalBalance
      ],
    ),
    headerStyle: pw.TextStyle(
      color: PdfColors.white,
      fontWeight: pw.FontWeight.bold,
    ),
    headerDecoration: pw.BoxDecoration(
      color: baseColor,
    ),
    rowDecoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(
          color: baseColor,
          width: .3,
        ),
      ),
    ),
    cellAlignment: pw.Alignment.center,
    // defaultColumnWidth: FixedColumnWidth(400.0),
    columnWidths: {
      0: FlexColumnWidth(3),
      1: FlexColumnWidth(3),
      2: FlexColumnWidth(4.6),
      3: FlexColumnWidth(7),
      4: FlexColumnWidth(4),
      5: FlexColumnWidth(4),
      6: FlexColumnWidth(4),
    },

    cellAlignments: {0: pw.Alignment.centerLeft},
  );

  pdf.addPage(MultiPage(
      // pageFormat: PdfPageFormat.a4,
      pageFormat:
          PdfPageFormat.a4.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      crossAxisAlignment: CrossAxisAlignment.start,
      header: (Context context) {
        if (context.pageNumber == 1) {
          return null;
        }
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            // decoration: const BoxDecoration(
            //     border: BoxBorder(bottom: true, width: 0.5, color: PdfColors.grey)),
            child: Text('Ledger Report',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.black)));
      },
      footer: (Context context) {
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      build: (Context context) => <Widget>[
            Header(
                level: 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Online Khata',
                          textScaleFactor: 2,
                          style: Theme.of(context)
                              .defaultTextStyle
                              .copyWith(color: PdfColors.blue)),
                      // PdfLogo(),
                    ])),
            Header(
                level: 4,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Ledger Report Detail',
                      style: Theme.of(context).defaultTextStyle.copyWith(
                          color: PdfColors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold))
                ])),

            Header(
                level: 4,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                      margin: EdgeInsets.fromLTRB(0.0, 25, 0.0, 0.0),
                      child: Text('Customer Name',
                          style: Theme.of(context).defaultTextStyle.copyWith(
                              color: PdfColors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold))),
                  Container(
                      margin: EdgeInsets.fromLTRB(10.0, 25, 0.0, 0.0),
                      child: Text(partName,
                          style: Theme.of(context).defaultTextStyle.copyWith(
                              color: PdfColors.grey900, fontSize: 13)))
                ])),

            Header(
                level: 4,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text('Total Debit(-):',
                      style: Theme.of(context).defaultTextStyle.copyWith(
                          color: PdfColors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  Container(
                      margin: EdgeInsets.fromLTRB(10.0, 0, 0.0, 0.0),
                      child: Text(totalDebit.toString(),
                          style: Theme.of(context).defaultTextStyle.copyWith(
                              color: PdfColors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)))
                ])),

            Header(
                level: 4,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text('Total Credit(+):',
                      style: Theme.of(context).defaultTextStyle.copyWith(
                          color: PdfColors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  Container(
                      margin: EdgeInsets.fromLTRB(10.0, 0, 0.0, 0.0),
                      child: Text(totalCredit.toString(),
                          style: Theme.of(context).defaultTextStyle.copyWith(
                              color: PdfColors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)))
                ])),

            Container(
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 25.0),
                child: Header(
                    level: 4,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Total Amount:',
                              style: Theme.of(context)
                                  .defaultTextStyle
                                  .copyWith(
                                      color: PdfColors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                          Container(
                              margin: EdgeInsets.fromLTRB(10.0, 0, 0.0, 0.0),
                              child: Text(
                                  totalBal < 0
                                      ? totalBal.abs().toString()
                                      : totalBal.toString(),
                                  style: Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(
                                          color: totalBal < 0
                                              ? PdfColors.red
                                              : PdfColors.green,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)))
                        ]))),

            // Table.fromTextArray(context: context, data: const <List<String>>[
            //   <String>['Year', 'Ipsum', 'Lorem'],
            //   <String>['2000', 'Ipsum 1.0', 'Lorem 1'],
            //   <String>['2001', 'Ipsum 1.1', 'Lorem 2'],
            //   <String>['2002', 'Ipsum 1.2', 'Lorem 3'],
            //   <String>['2003', 'Ipsum 1.3', 'Lorem 4'],
            //   <String>['2004', 'Ipsum 1.4', 'Lorem 5'],
            //   <String>['2004', 'Ipsum 1.5', 'Lorem 6'],
            //   <String>['2006', 'Ipsum 1.6', 'Lorem 7'],
            //   <String>['2007', 'Ipsum 1.7', 'Lorem 8'],
            //   <String>['2008', 'Ipsum 1.7', 'Lorem 9'],
            // ]),

            table
          ]));

  //save PDF
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);

  String folderName = "Online khata Reports";
  var dirPath = "storage/emulated/0/$folderName";
  var createReportDir = await new Directory(dirPath).create();

  // var dir = (await getExternalStorageDirectory());
  // var createReportDir = await new Directory('${dir.path}/Online khata Reports').create(recursive: true);

  final String filePath = '${createReportDir.path}/Report_$formattedDate.pdf';
  final File file = File(filePath);

  await file.writeAsBytes(pdf.save()).then((value) {
    if (viewOrDownload == "from_share") {
      // List<int> imageBytes = file.readAsBytesSync();
      //  print(imageBytes);
      //
      // final bytes = Io.File(path).readAsBytesSync();

      // String base64Image = base64Encode(imageBytes);
      //  String base64Image = "data:image/jpeg;base64,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";
// String base64Image = "data:document/pdf;base64,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2tiLBtWtQs+eKIDDaVAAQhBGIRlkDED2ag+cuc914/T7o4vpjZ0d7mHKdVwJDjQbQmDLfdK8renPICY3dgaaSAB0l90IWPU5m0Pgy4fgEJP7MziA5pqLbA6NycHNxLqrDOABG7GxM7ibB+RS2v1N4CAIImpjZ3BHEyjon2gCG8xDmMAHVDQEhDOB3TXzuvy2LsMHXsyNToYdXa5JGLW5VnexTcufV6HjVAQkT0Y9Xy2X4bWeALFWmsQTOXH6CdfDMwaSfnp8D8q1sapNhQ1jfR9OxQpJBKVJ6wtC7mG7Gr/aJG4Q+/twOHD0jzztu4awvoMwiMmNncEdrS+3fADrWx8j1qm38+2Vy3sMoP4J91la/aO/xfcC39/3DpH/HbGxA/Cm10j38ksbgajp7YYWN73SEGZMK+h75np9edaeN6NkdsRGXzKCaG2co3Q2lrcWwNHLg9nJrRJAp+vCuNt2W2tgevBh9qQpA+dFFVFKoBd1Vk41TyJjblSh9jMmVGNHq13m5p+u1hJDW932y5PZQWicOUaZZNS7kxez0DgzvMMyN83uBeVmGUapjbfvXlPidCszeEuWFjPTvaxcYgDTAvRWWiyh1k0QqrdH24JPD6Z/Hx/HZtjdvLTNMPGYa3uGd+9Dqhny/6wP+X/QPv2a35V8t5ax1e7KjX2v9c1a976gAPQQzVo91LcJGRB21cYOwXdq3RCG6NSGALCrNnYAdZuWuDkq0DK3TePFq9Z3uasQsQlpXgNvngAFr4v7c8vJuxzRhncj2pzLFK2H7+bZCb6Z/AN/QuMaCmVuZHN0cmVhbQplbmRvYmoKeHJlZgowIDE2CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDAxNyAwMDAwMCBuIAowMDAwMDAwMDk1IDAwMDAwIG4gCjAwMDAwMDAxMjUgMDAwMDAgbiAKMDAwMDAwMDIxMSAwMDAwMCBuIAowMDAwMDAwMzg5IDAwMDAwIG4gCjAwMDAwMDIzNDQgMDAwMDAgbiAKMDAwMDAwMjQ0MCAwMDAwMCBuIAowMDAwMDAyNTQxIDAwMDAwIG4gCjAwMDAwMDI3MTkgMDAwMDAgbiAKMDAwMDAwNTIyMCAwMDAwMCBuIAowMDAwMDA1NDAwIDAwMDAwIG4gCjAwMDAwMDc0MzggMDAwMDAgbiAKMDAwMDAwNzYxOCAwMDAwMCBuIAowMDAwMDA5OTQ4IDAwMDAwIG4gCjAwMDAwMTAxMjggMDAwMDAgbiAKdHJhaWxlcgo8PC9TaXplIDE2L1Jvb3QgMyAwIFIvSURbPDYwODExOTE3NjNmMDllY2E0NTJmMWZiZGFkZTVjNzVlZjQ4YTQ5NmNiMzM1OWIyNzQyMWY4MDllNjQ1MjZmZjk+PDYwODExOTE3NjNmMDllY2E0NTJmMWZiZGFkZTVjNzVlZjQ4YTQ5NmNiMzM1OWIyNzQyMWY4MDllNjQ1MjZmZjk+XT4+CnN0YXJ0eHJlZgoxMTQxOAolJUVPRgo=";

      // FlutterShareMe().shareToWhatsApp(base64Image: base64Image, msg: "Share Ledger Report");
      Share.shareFiles(['${createReportDir.path}/Report_$formattedDate.pdf'],
          text: '');
    } else {
      material.Navigator.of(context).push(
        material.MaterialPageRoute(
          builder: (_) => PdfViewerPage(path: filePath),
        ),
      );
    }
  });
}

String getDateTimeFormat(int date) {
  DateTime datetime = DateTime.fromMicrosecondsSinceEpoch(date);
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  String formatted = formatter.format(datetime);

  return formatted;
}
