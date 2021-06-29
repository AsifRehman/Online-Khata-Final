import 'package:flutter/material.dart';
import 'package:onlinekhata/ui/ledger_detail.dart';
import 'package:onlinekhata/ui/setting_screen.dart';
import 'package:onlinekhata/ui/splash_screen.dart';
import 'package:onlinekhata/ui/home_screen.dart';
import 'package:onlinekhata/ui/sync_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.light,
          primaryColorDark: Colors.blue,
          primaryColor: Colors.blue,//Action and status bar color
          accentColor:Colors.blue,
          primaryColorLight: Colors.blue,
        ),
        //  navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,

        initialRoute: SplashScreen.id,

        routes: {
          SplashScreen.id: (context) => SplashScreen(),
         HomeScreen.id: (context) => HomeScreen(),
          LedgerDetailScreen.id: (context) => LedgerDetailScreen(),
          SyncScreen.id: (context) => SyncScreen(),
          SettingScreen.id: (context) => SettingScreen(),
        });
  }
}

