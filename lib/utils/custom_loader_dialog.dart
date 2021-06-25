import 'package:flutter/material.dart';

class CustomLoaderDialog extends StatelessWidget {
  final String title;

  CustomLoaderDialog({
    @required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        elevation: 0.0,
        child: customDialog(context),

      ),
    );
  }

  customDialog(BuildContext context) {
    return Container(
      width:100,
      height: 105,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(top: 20),child:Text("Loading..." ))
        ],
      ),
    );
  }
}
