import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kronic_desktop_tool/services/client_manager.dart';
import 'package:kronic_desktop_tool/services/league_client_connector.dart';

class ClientHome extends StatefulWidget {
  static const routeName = '/client_home';
  @override
  _ClientHomeState createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {


  Widget home(ClientManager clientManager) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text("ExampleSummoner"),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    ClientManager clientManager = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          leading: new Container(),
          title: Text("Home", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(28, 22, 46, 1),
          elevation: 0.0,
        ),
      body: Container(
          color: Color.fromRGBO(28, 22, 46, 1),
          child: home(clientManager)),
      bottomNavigationBar: BottomAppBar (
        color: Color.fromRGBO(28, 22, 46, 1),
          child: Row(
            children: [
              Container(height: 50,)
            ],
          )
    ),
      floatingActionButton: FloatingActionButton(backgroundColor:  Color.fromRGBO(184, 88, 88, 1),child:Icon(Icons.accessible_outlined), onPressed: () async {
        var champSelect = await clientManager.champSelect();
        if(champSelect)
        {
          print("In Champ Select");
        } else {
          print("Not In Champ Select");
        }
      },),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
