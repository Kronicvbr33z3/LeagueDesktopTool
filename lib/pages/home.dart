import 'dart:io';
import 'package:kronic_desktop_tool/providers/league_client_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:kronic_desktop_tool/pages/client_home.dart';
import 'package:dart_lol/lcu/client_manager.dart';
import 'package:dart_lol/lcu/league_client_connector.dart';


class Home extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Home> {
  Future<LeagueConnector> constructLeagueConnector() async {
    LeagueConnector instance = LeagueConnector();
    await instance.constructLCUConnector();
    return instance;
  }
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Client Not Running'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please make sure the League Client is Running.'),
                //Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: new Scaffold(
            appBar: AppBar(
              leading: new Container(),
              title: Text("League Of Legends Tool, By Kronic",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              centerTitle: true,
              backgroundColor: Color.fromRGBO(28, 22, 46, 1),
              elevation: 0.0,
            ),
            body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/league_home.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(.2), BlendMode.dstATop))),
              child: Center(
                child: ElevatedButton(
                  child: Text('Start', style: TextStyle(fontSize: 20.0)),
                  style: ButtonStyle (
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(28, 22, 46, 1)),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(25))
                  ) ,

                  onPressed: () async {

                    constructLeagueConnector().then((value) {
                      ClientManager clientManager = ClientManager(value);
                      if (value.port != "null") {
                        Navigator.pushNamed(context, ClientHome.routeName,
                            arguments: clientManager);
                      } else
                        {
                          _showMyDialog();
                        }
                    });
                  },
                ),
              ),
            )));
  }

  @override
  void didChangeDependencies() {
    Provider.of<LeagueClientConnector>(context, listen: false).isRunning().listen((state){

      switch (state) {
        case false:

      }

    });
    super.didChangeDependencies();
  }


}
