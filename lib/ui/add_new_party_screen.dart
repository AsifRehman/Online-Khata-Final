import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onlinekhata/sqflite_database/dbprovider.dart';
import 'package:onlinekhata/sqflite_database/model/PartyTypeModel.dart';

class AddNewPartyScreen extends StatefulWidget {
  static String id = 'setting_screen';

  @override
  _AddNewPartyScreenState createState() => _AddNewPartyScreenState();
}

class _AddNewPartyScreenState extends State<AddNewPartyScreen> {
  TextEditingController _partyNameController = TextEditingController();
  TextEditingController _partyTypeIdController = TextEditingController();
  TextEditingController _debitController = TextEditingController();
  TextEditingController _creditController = TextEditingController();

  final partyNameFocus = FocusNode();
  final partyTypeFocus = FocusNode();
  final debitFocus = FocusNode();
  final creditFocus = FocusNode();
  final saveFocus = FocusNode();

  int _selectedPartyTypeId; // Option 2
  DbProvider dbProvider = DbProvider();
  List<PartyTypeModel> partyTypeList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getDataFromLocalDB(true);
  }

  getDataFromLocalDB(bool isPop) async {
    dbProvider.fetchPartyType().then((value) {
      partyTypeList = value;

      //if (isPop) Navigator.pop(context);

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
            backgroundColor: Colors.blue,
            body: Container(
              margin: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  getPartyName(width, context),
                  getPartyTypeId(width, context),
                  getDebit(width, context),
                  getCredit(width, context),
                  getPartyTypeDropDown(width),
                  GestureDetector(
                    onTap: () async {
                      if (isValidField(_partyNameController.text.toString(),
                          _partyTypeIdController.text)) {
                        DbProvider dbProvider = DbProvider();
                        await dbProvider.addNewPartyItem(
                            _partyNameController.text.toString(),
                            int.parse(_partyTypeIdController.text),
                            _debitController.text.isNotEmpty
                                ? int?.parse(_debitController.text)
                                : 0,
                            _creditController.text.isNotEmpty
                                ? int?.parse(_creditController.text)
                                : 0);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: width * 0.93,
                      margin: EdgeInsets.fromLTRB(12.0, 15.0, 0, 0.0),
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                          border: Border.all(color: Colors.white)),
                      height: 43,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  Container getPartyTypeDropDown(double width) {
    return Container(
      decoration: BoxDecoration(color: Colors.white70,
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
      ),
      width: width * 0.93,
      margin: EdgeInsets.fromLTRB(12.0, 10.0, 0, 0.0),
      child: DropdownButton(
        isExpanded: true,

        style: new TextStyle(fontSize: 14.0, color: Colors.grey),
        hint: Text('Please choose a party type'), // Not necessary for Option 1
        value: _selectedPartyTypeId,
        onChanged: (newValue) {
          setState(() {
            _selectedPartyTypeId = newValue;
            _partyTypeIdController.text = newValue.toString();
          });
          FocusScope.of(context).requestFocus(saveFocus);
        },
        items: partyTypeList.map((p) {
          return DropdownMenuItem(
            child: new Text(p.partyTypeName),
            value: p.partyTypeID,
          );
        }).toList(),
      ),
    );
  }

  Container getCredit(double width, BuildContext context) {
    return Container(
      width: width * 0.93,
      margin: EdgeInsets.fromLTRB(12.0, 10.0, 0, 0.0),
      child: TextField(
        style: new TextStyle(fontSize: 14.0, color: Colors.grey),
        controller: _creditController,
        enableSuggestions: false,
        autocorrect: false,
        autofocus: false,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        focusNode: creditFocus,
        onSubmitted: (v) {
          FocusScope.of(context).requestFocus(saveFocus);
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16.0),
            border: new OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 0.0),
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            filled: true,
            hintText: "credit",
            hintStyle: new TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            fillColor: Colors.white70),
      ),
    );
  }

  Container getDebit(double width, BuildContext context) {
    return Container(
      width: width * 0.93,
      margin: EdgeInsets.fromLTRB(12.0, 10.0, 0, 0.0),
      child: TextField(
        style: new TextStyle(fontSize: 14.0, color: Colors.grey),
        controller: _debitController,
        enableSuggestions: false,
        autocorrect: false,
        autofocus: false,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        focusNode: debitFocus,
        onSubmitted: (v) {
          FocusScope.of(context).requestFocus(creditFocus);
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16.0),
            border: new OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 0.0),
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            filled: true,
            hintText: "debit",
            hintStyle: new TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            fillColor: Colors.white70),
      ),
    );
  }

  Container getPartyTypeId(double width, BuildContext context) {
    return Container(
      width: width * 0.93,
      margin: EdgeInsets.fromLTRB(12.0, 10.0, 0, 0.0),
      child: TextField(
        style: new TextStyle(fontSize: 14.0, color: Colors.grey),
        controller: _partyTypeIdController,
        enableSuggestions: false,
        autocorrect: false,
        autofocus: false,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        focusNode: partyTypeFocus,
        onSubmitted: (v) {
          FocusScope.of(context).requestFocus(debitFocus);
          setState(() {
            _selectedPartyTypeId = _partyTypeIdController.text.isNotEmpty
                ? int.parse(_partyTypeIdController.text)
                : null;
          });
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16.0),
            border: new OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 0.0),
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            filled: true,
            hintText: "party type id",
            hintStyle: new TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            fillColor: Colors.white70),
      ),
    );
  }

  Container getPartyName(double width, BuildContext context) {
    return Container(
      width: width * 0.93,
      margin: EdgeInsets.fromLTRB(12.0, 10.0, 0, 0.0),
      child: TextField(
        style: new TextStyle(fontSize: 14.0, color: Colors.grey),
        controller: _partyNameController,
        enableSuggestions: false,
        autocorrect: false,
        autofocus: false,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        focusNode: partyNameFocus,
        onSubmitted: (v) {
          FocusScope.of(context).requestFocus(partyTypeFocus);
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16.0),
            border: new OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 0.0),
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            filled: true,
            hintText: "party name",
            hintStyle: new TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            fillColor: Colors.white70),
      ),
    );
  }

  bool isValidField(String partyName, String partyTypeId) {
    if (partyName.length == 0) {
      showShortToast("Party Name is required");
      return false;
    }
    if (partyTypeId.length == 0) {
      showShortToast("Party Type is required");
      return false;
    }

    return true;
  }

  void showShortToast(String msg) {
    Fluttertoast.showToast(
        msg: msg, toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2);
  }
}
