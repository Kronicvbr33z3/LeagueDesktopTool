import 'package:flutter/material.dart';
import 'dart:convert';
import 'client_manager.dart';
import 'package:kronic_desktop_tool/models/session.dart';



class ChampionSelectHelper {


  Future<List<String>> getSession(ClientManager cl, Session session) async {
    //var request = await cl.getRequest('/lol-champ-select/v1/session');
   // var body = json.decode(request);
   // var f = Session.fromJson(body);
    List<String> names = [];
    for(var teamMember in session.myTeam)
      {
        var response = await cl.getRequest(
            "/lol-summoner/v1/summoners/${teamMember.summonerId}");
        //  await Future.delayed(Duration(seconds: 3));

        names.add(json.decode(response)['displayName']);

      }
        //print(names.length);
    return names;
  }


    Widget champSelect(ClientManager cl, Session session) {
      return FutureBuilder(
          future: getSession(cl, session),
          builder: (context,  snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              return Container(
                color: Colors.blueGrey,
                alignment: Alignment.centerRight,
                width: 300,
                height: 280,
                child: Row(
                  children: [
                    Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, i) {
                            return Padding(
                                padding: EdgeInsets.fromLTRB(6, 0, 6, 8),
                                child: ListTile(
                                    title: Text(
                                        "${snapshot.data[i] } ")));
                          },
                        )),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Container(
                color: Colors.blueGrey,
                alignment: Alignment.centerRight,
                width: 300,
                height: 280,
                child: Row(
                  children: [
                    Expanded(
                        child: ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, i) {
                            return Padding(
                                padding: EdgeInsets.fromLTRB(6, 0, 6, 8),
                                child: ListTile(title: Text("Snapshot Error")));
                          },
                        )),
                  ],
                ),
              );
            } else {
              return Container();
            }
          });
    }
}