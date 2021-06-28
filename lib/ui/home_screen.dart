import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onlinekhata/sqflite_database/DbProvider.dart';
import 'package:onlinekhata/sqflite_database/model/PartyModel.dart';
import 'package:onlinekhata/ui/ledger_detail.dart';
import 'package:onlinekhata/utils/custom_loader_dialog.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;

  TextEditingController searchController = TextEditingController();
  DbProvider dbProvider = DbProvider();
  List<PartyModel> partyModelList = [];
  bool _checkConfiguration() => true;

  @override
  void initState() {
    if (_checkConfiguration()) {
      Future.delayed(Duration.zero, () {
        showLoaderDialog(context);
      });
    }
    getDateFromLocalDB();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Colors.blue,
                width: MediaQuery.of(context).size.width - 1,
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
                      child: Container(
                        height: 40,
                        margin: EdgeInsets.fromLTRB(20.0, 15, 0.0, 0.0),
                        child: new Text(
                          'Online Khata',
                          style: TextStyle(
                              fontSize: 21,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.3),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0.0, 0, 10.0, 0.0),
                      child: Image.asset(
                        'assets/splash_logo.png',
                        width: 40,
                        height: 40,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: width * 0.83,
                    height: 37,
                    margin: EdgeInsets.fromLTRB(12.0, 20.0, 5, 25.0),
                    child: TextField(
                      cursorColor: Colors.blue,
                      style: new TextStyle(
                        fontSize: 14.0,
                      ),
                      controller: searchController,
                      autofocus: false,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (v) {
                        if (v.length == 0) {
                          // getParties();
                        }
                      },
                      onChanged: (v) {
                        if (v.length == 0) {
                          // getParties();
                        }
                      },
                      decoration: InputDecoration(
                          labelStyle: new TextStyle(color: Colors.grey),
                          border: new UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.blue)),
                          contentPadding:
                              const EdgeInsets.fromLTRB(12.0, 2.0, 12.0, 10.0),
                          filled: true,
                          hintText: "Search",
                          hintStyle: new TextStyle(
                            color: Colors.blue,
                            fontSize: 14.0,
                          ),
                          fillColor: Colors.white70),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (searchController.text.toString().length > 0) {
                        // onSearchTextChanged(searchController.text.toString());
                        setState(() {
                          loading = true;
                        });
                        dbProvider
                            .fetchPartyLegSumByPartName(
                                searchController.text.toLowerCase().toString())
                            .then((value) {
                          partyModelList = value;

                          setState(() {
                            loading = false;
                          });
                        });
                      } else {
                        setState(() {
                          loading = true;
                        });
                        dbProvider.fetchPartyLegSum().then((value) {
                          partyModelList = value;

                          setState(() {
                            loading = false;
                          });
                        });
                      }
                    },
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: loading == true
                      ? Container()
                      : partyModelList == null
                          ? Center(
                              child: Text('No record found.'),
                            )
                          : partyModelList.length == 0
                              ? Center(
                                  child: Text('No record found.'),
                                )
                              : new ListView.builder(
                                  //      controller: scrollController,
                                  itemCount: partyModelList.length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return new InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LedgerDetailScreen(
                                                      iD: partyModelList[index]
                                                          .partyID,
                                                      partName:
                                                          partyModelList[index]
                                                              .partyName,
                                                    )));
                                      },
                                      child: new PartiesItem(
                                          partyModelList[index], index),
                                    );
                                  },
                                )),
            ],
          ),
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

  getDateFromLocalDB() async {
    dbProvider.fetchPartyLegSum().then((value) {
      partyModelList = value;

      Navigator.pop(context);

      setState(() {
        loading = false;
      });
    });
  }
}

class PartiesItem extends StatelessWidget {
  final PartyModel _item;
  final int index;

  PartiesItem(this._item, this.index);

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      height: 85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Divider(
            height: 3.0,
            color: Colors.grey,
          ),
          Container(
              margin: EdgeInsets.fromLTRB(2.0, 0.0, 13.0, 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            isKeyNotNull(_item.partyName)
                                ? Container(
                                    margin:
                                        EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                    child: Text(
                                      _item.partyName,
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  )
                                : Container(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin:
                                      EdgeInsets.fromLTRB(0.0, 3.0, 3.0, 0.0),
                                  child: Text(
                                    'Pending:',
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                isKeyNotNullAndZero(_item.debit)
                                    ? Container(
                                        margin: EdgeInsets.fromLTRB(
                                            7.0, 3.0, 3.0, 0.0),
                                        child: Text(
                                          'RS ' + _item.debit.toString(),
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        margin: EdgeInsets.fromLTRB(
                                            7.0, 3.0, 3.0, 0.0),
                                        child: Text(
                                          'RS 0',
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin:
                                      EdgeInsets.fromLTRB(0.0, 3.0, 3.0, 0.0),
                                  child: Text(
                                    'Received:',
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                isKeyNotNullAndZero(_item.credit)
                                    ? Container(
                                        margin: EdgeInsets.fromLTRB(
                                            3.0, 3.0, 3.0, 0.0),
                                        child: Text(
                                          'RS ' + _item.credit.toString(),
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        margin: EdgeInsets.fromLTRB(
                                            3.0, 3.0, 3.0, 0.0),
                                        child: Text(
                                          'RS 0',
                                          textAlign: TextAlign.right,
                                          maxLines: 1,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        )),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                        child: Text(
                          'RS ' + _item.total.abs().toString(),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: (int.parse(_item.total.toString())) > 0
                                ? Colors.red
                                : Colors.green,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0.0, 2.0, 3.0, 0.0),
                        child: Text(
                          'Total',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    ],
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

  bool isKeyNotNullAndZero(Object param1) {
    if (param1 != null && param1 != 0)
      return true;
    else
      return false;
  }
}
