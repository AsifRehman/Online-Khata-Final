import 'package:flutter/material.dart';
import 'package:onlinekhata/ui/sync_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  static String id = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    startTime();
  }

  startTime() async {
    var _duration = new Duration(seconds: 1);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed(SyncScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.asset(
                'assets/splash_logo.png',
                color: Colors.blue,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0.0, 1, 0.0, 0.0),
              child: Container(
                child: new Text(
                  'Online Khata',
                  style: TextStyle(
                      fontSize: 26,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
