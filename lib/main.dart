import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kronic_desktop_tool/pages/client_home.dart';
import 'package:kronic_desktop_tool/pages/home.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:kronic_desktop_tool/pages/view_summoner.dart';
import 'package:kronic_desktop_tool/providers/league_client_provider.dart';
import 'package:provider/provider.dart';

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
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ignore: unused_field
  String _windowSize = 'Unknown';

  void initWindow() async {
    await DesktopWindow.setMinWindowSize(Size(1280, 720));
    await DesktopWindow.setMaxWindowSize(Size(1280, 720));
  }

  @override
  void initState() {
    // ignore: unused_local_variable
    LeagueClientProvider _leagueClientConnector = new LeagueClientProvider();
    super.initState();
  }

  // ignore: unused_element
  Future _getWindowSize() async {
    var size = await DesktopWindow.getWindowSize();
    setState(() {
      _windowSize = '${size.width} x ${size.height}';
    });
  }

  @override
  Widget build(BuildContext context) {
    initWindow();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeagueClientProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
            fontFamily: 'Montserrat', colorScheme: ColorScheme.dark()),
        initialRoute: '/home',
        routes: {
          // '/': (context) => Loading(),
          '/home': (context) => Home(),
          ClientHome.routeName: (context) => ClientHome(),
          ViewSummoner.routeName: (context) => ViewSummoner(),
          //   ViewSummoner.routeName: (context) => ViewSummoner(),
          //  ViewTFTSummoner.routeName: (context) => ViewTFTSummoner(),
          // ViewAnalyzedMatch.routeName: (context) => ViewAnalyzedMatch(),
          // '/tier_list': (context) => TierList(),
        },
      ),
    );
  }
}
