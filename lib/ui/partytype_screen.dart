import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlinekhata/sqflite_database/DbProvider.dart';
import 'package:onlinekhata/sqflite_database/model/PartyTypeModel.dart';
import 'package:onlinekhata/ui/home_screen.dart';
import 'package:onlinekhata/utils/custom_loader_dialog.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';

class PartyTypeScreen extends StatefulWidget {
  static String id = 'partytype_screen';
  static String orderBy = 'ts';
  static String orderByDirection = 'DESC';

  @override
  _PartyTypeScreenState createState() => _PartyTypeScreenState();
}

class _PartyTypeScreenState extends State<PartyTypeScreen> {
  bool loading = true;
  String sortByChoose = "ts";
  List sortByOptions = ["ts", "partyName", "Bal"];

  final oCcy = new NumberFormat("#,##0.00", "en_US");

  TextEditingController searchController = TextEditingController();
  DbProvider dbProvider = DbProvider();
  List<PartyTypeModel> partyModelList = [];
  bool _checkConfiguration() => true;

  @override
  void initState() {
    if (_checkConfiguration()) {
      Future.delayed(Duration.zero, () {
        showLoaderDialog(context);
      });
    }
    getDataFromLocalDB(true);

    super.initState();
  }

  getDataFromLocalDB(bool isPop) async {
    dbProvider.fetchPartyType().then((value) {
      partyModelList = value;

      if (isPop) Navigator.pop(context);

      setState(() {
        loading = false;
      });
    });
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
            buildTopBar(context),
            buildSearchBar(context, width),
            buildListview(),
          ],
        ),
      ),
    );
  }

  Container buildTopBar(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: MediaQuery.of(context).size.width - 1,
      child: Row(
        children: [
          Platform.isIOS
              ?
              // iOS-specific code
              Container(
                  child: new IconButton(
                    icon: Image.asset(
                      'assets/ic_back.png',
                      width: 40,
                      height: 40,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              : Container(),
          Container(
            child: Container(
              height: 40,
              margin: EdgeInsets.fromLTRB(10.0, 15, 0.0, 0.0),
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
    );
  }

  Container buildSearchBar(BuildContext context, double width) {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            width: width * 0.63,
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
                if (v.length > 0) {
                  showLoaderDialog(context);

                  setState(() {
                    loading = true;
                  });
                  dbProvider
                      .fetchPartyTypesByPartTypeName(
                          searchController.text.toLowerCase().toString())
                      .then((value) {
                    partyModelList = value;

                    Navigator.pop(context);

                    setState(() {
                      loading = false;
                    });
                  });
                }
              },
              onChanged: (v) {},
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: searchController.clear,
                    icon: Icon(Icons.clear),
                    iconSize: 20,
                  ),
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
                setState(() {
                  loading = true;
                });
                dbProvider
                    .fetchPartyTypesByPartTypeName(
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
                dbProvider.fetchPartyType().then((value) {
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
          DropdownButton(
            icon: Icon(Icons.sort_rounded, color: Colors.blue),
            value: sortByChoose,
            onChanged: (newValue) {
              this.sortByChoose = newValue;
              setState(() {
                this.sortByChoose = newValue;
                HomeScreen.orderBy = this.sortByChoose;
                getDataFromLocalDB(false);
              });
            },
            items: sortByOptions.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Container buildListview() {
    return Container(
      child: Expanded(
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
                          itemBuilder: (BuildContext context, int index) {
                            return new InkWell(
                              onTap: () {
                                HomeScreen.cri = "PartyTypeID=" +
                                    partyModelList[index]
                                        .partyTypeID
                                        .toString();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()));
                              },
                              child: new PartyTypesItem(
                                  partyModelList[index], index),
                            );
                          },
                        )),
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
}

class PartyTypesItem extends StatelessWidget {
  final PartyTypeModel _item;
  final int index;
  final oCcy = new NumberFormat("#,##0", "en_US");

  PartyTypesItem(this._item, this.index);

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              color: index % 2 == 0 ? Color(0xffF5F5F5) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                        margin: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            buildPartyName(),
                          ],
                        )),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget buildPartyName() {
    return isKeyNotNull(_item.partyTypeName)
        ? Container(
            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            child: Text(
              _item.partyTypeName,
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
        : Container();
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
