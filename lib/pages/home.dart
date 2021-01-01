import 'dart:io';

import 'package:flutter/material.dart';
import 'package:filepicker_windows/filepicker_windows.dart' as picker;
import 'package:kronic_desktop_tool/pages/client_home.dart';
import 'package:kronic_desktop_tool/services/client_manager.dart';
import 'package:kronic_desktop_tool/services/league_client_connector.dart';



class Home extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Home> {

  Future<LeagueConnector> constructLeagueConnector(File file) async {
    LeagueConnector instance = LeagueConnector();
    await instance.constructLCUConnector(file);
    return instance;
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
                            Colors.black.withOpacity(.2),
                            BlendMode.dstATop)
                    )
                ), child: Center(
                  child: RaisedButton(
                    padding: EdgeInsets.all(20),
                    onPressed: () {
                          final file = picker.OpenFilePicker();
                          file.forcePreviewPaneOn = true;
                          file.filterSpecification = {'All Files (*.*)': '*'};
                          file.title = 'Navigate to League install Directory and Select lockfile (MAKE SURE CLIENT IS RUNNING)';
                          final result = file.getFile();
                          if(result != null) {
                            constructLeagueConnector(result).then((value) {
                              ClientManager clientManager = ClientManager(value);
                              if (value.port != null){
                                Navigator.pushNamed(context, ClientHome.routeName,
                                    arguments: clientManager);
                            }
                            });
                      }
                    },
              child: Text('Choose League Directory', style: TextStyle(fontSize: 20.0)),
              color: Color.fromRGBO(28, 22, 46, 1),

              ),
                ),
            )
        )
    );
  }
}
