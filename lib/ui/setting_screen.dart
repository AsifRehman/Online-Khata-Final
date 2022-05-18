import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onlinekhata/utils/constants.dart';

class SettingScreen extends StatefulWidget {
  static String id = 'setting_screen';

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _databaseNameController = TextEditingController();
  bool showPassword = false;

  final focus = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();

  @override
  void initState() {

    getPassword().then((value) {
      if (value != null && value != "") {
        setState(() {
          _passwordController.text = value;

        });
      }
      else {
        setState(() {
          _passwordController.text = "demo";
        });
      }
    });

    getUserName().then((value) {
      if (value != null && value != "") {
        setState(() {
          _userNameController.text = value;

        });
      }
      else {
        setState(() {
          _userNameController.text = "demo";
        });
      }
    });

    getDatabaseName().then((value) {
      if (value != null && value != "") {
        setState(() {
          _databaseNameController.text = value;

        });
      }
      else {
        setState(() {
          _databaseNameController.text = "demo";
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
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
                      cursorColor: Color(0xff0daf0e),
                      style: new TextStyle(fontSize: 14.0, color: Colors.grey),
                      controller: _userNameController,
                      autofocus: false,
                      textInputAction: TextInputAction.next,
                      focusNode: focus,
                      onSubmitted: (v) {
                        FocusScope.of(context).requestFocus(focus2);
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
                          hintText: "Username",
                          hintStyle: new TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                          fillColor: Colors.white70),
                    ),
                  ),
                  Container(
                    width: width * 0.93,
                    margin: EdgeInsets.fromLTRB(12.0, 10.0, 0, 0.0),
                    child: TextField(
                      style: new TextStyle(fontSize: 14.0, color: Colors.grey),
                      controller: _passwordController,
                      enableSuggestions: false,
                      autocorrect: false,

                      autofocus: false,
                      obscureText: !this.showPassword,

                      keyboardType: TextInputType.text,

                      textInputAction: TextInputAction.next,
                      focusNode: focus2,
                      onSubmitted: (v) {
                        FocusScope.of(context).requestFocus(focus3);
                      },
                      decoration: InputDecoration(

                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.remove_red_eye_rounded,
                              color: this.showPassword ? Colors.blueAccent : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() => this.showPassword = !this.showPassword);
                            },
                          ),
                          contentPadding: const EdgeInsets.all(16.0),
                          border: new OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 0.0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                          filled: true,
                          hintText: "Password",
                          hintStyle: new TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                          fillColor: Colors.white70),
                    ),
                  ),
                  Container(
                    width: width * 0.93,
                    margin: EdgeInsets.fromLTRB(12.0, 10.0, 0, 0.0),
                    child: TextField(
                      style: new TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey
                      ),
                      controller: _databaseNameController,
                      autofocus: false,
                      textInputAction: TextInputAction.done,
                      focusNode: focus3,
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
                          hintText: "Database Name",
                          hintStyle: new TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                          fillColor: Colors.white70),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isValidField(
                          _userNameController.text.toString(),
                          _passwordController.text.toString(),
                          _databaseNameController.text.toString())) {
                        setUserName(_userNameController.text.toString());
                        setPassword(_passwordController.text.toString());
                        setDatabaseName(_databaseNameController.text.toString());
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

  bool isValidField(String userName, String password, String databaseName) {
    if (userName.length == 0) {
      showShortToast("Username is required");

      return false;
    }
    if (password.length == 0) {
      showShortToast("Password is required");

      return false;
    }
    if (databaseName.length == 0) {
      showShortToast("Database is required");

      return false;
    }
    return true;
  }

  void showShortToast(String msg) {
    Fluttertoast.showToast(
        msg: msg, toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2);
  }
}
