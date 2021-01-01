import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kronic_desktop_tool/pages/client_home.dart';
import 'package:kronic_desktop_tool/pages/home.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'Montserrat',
      brightness: Brightness.dark,
      primaryColor: Color.fromRGBO(28, 22, 46, 1),
      accentColor: Color.fromRGBO(40, 34, 57, 1),
    ),
    initialRoute: '/home',
    routes: {
      // '/': (context) => Loading(),
      '/home': (context) => Home(),
      ClientHome.routeName: (context) => ClientHome(),
      //   ViewSummoner.routeName: (context) => ViewSummoner(),
      //  ViewTFTSummoner.routeName: (context) => ViewTFTSummoner(),
      // ViewAnalyzedMatch.routeName: (context) => ViewAnalyzedMatch(),
      // '/tier_list': (context) => TierList(),
    },
  ));
}
