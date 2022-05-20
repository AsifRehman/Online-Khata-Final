import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onlinekhata/sqflite_database/dbprovider.dart';

class AddNewPartyTypeScreen extends StatefulWidget {
  static String id = 'setting_screen';

  @override
  _AddNewPartyTypeScreenState createState() => _AddNewPartyTypeScreenState();
}

class _AddNewPartyTypeScreenState extends State<AddNewPartyTypeScreen> {
  TextEditingController _partyTypeController = TextEditingController();

  final focus = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();

  @override
  void initState() {
    super.initState();
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
                  Container(
                    width: width * 0.93,
                    margin: EdgeInsets.fromLTRB(12.0, 10.0, 0, 0.0),
                    child: TextField(
                      style: new TextStyle(fontSize: 14.0, color: Colors.grey),
                      controller: _partyTypeController,
                      enableSuggestions: false,
                      autocorrect: false,

                      autofocus: false,

                      keyboardType: TextInputType.text,

                      textInputAction: TextInputAction.next,
                      focusNode: focus2,
                      onSubmitted: (v) {
                        FocusScope.of(context).requestFocus(focus3);
                      },
                      decoration: InputDecoration(

                          contentPadding: const EdgeInsets.all(16.0),
                          border: new OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 0.0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                          filled: true,
                          hintText: "partyType",
                          hintStyle: new TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                          fillColor: Colors.white70),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      if (isValidField(_partyTypeController.text.toString())) {
                        DbProvider dbProvider = DbProvider();
                        await dbProvider.addNewPartyTypeItem(_partyTypeController.text.toString());
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

  bool isValidField(String partyType) {
    if (partyType.length == 0) {
      showShortToast("PartyType is required");

      return false;
    }
    return true;
  }

  void showShortToast(String msg) {
    Fluttertoast.showToast(
        msg: msg, toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2);
  }
}
