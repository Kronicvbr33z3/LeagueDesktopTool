import 'package:dart_lol/kronic_desktop_tool/kronic_desktop_server.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dart_lol/lcu/client_manager.dart';
import 'package:kronic_desktop_tool/models/session.dart';
import 'package:kronic_desktop_tool/providers/league_client_provider.dart';

class ChampionSelectHelper {
  Widget championSelected(ClientManager cl, dynamic snapshot) {
    return Container(
      color: Colors.blueGrey,
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Container(
            width: 300,
            height: 280,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, i) {
                      return Padding(
                          padding: EdgeInsets.fromLTRB(6, 0, 6, 8),
                          child: ListTile(title: Text("${snapshot.data[i]} ")));
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: ElevatedButton(
              child: Text("Import Runes"),
              onPressed: () async {
                var champSelect = await cl.champSelect();
                if (champSelect) {
                  var champId = await cl.getCurrentChampId();
                  if (champId == -1 || champId == 0) {
                    print("Choose Champion");
                  } else {
                    var runes = await KronicServer.getRunes(champId);
                    await cl.putRunes(runes);
                  }
                } else {
                  print("Not In Champ Select");
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Future<bool> champSelected(ClientManager cl) async {
    var champSelect = await cl.champSelect();
    if (champSelect) {
      var champId = await cl.getCurrentChampId();
      if (champId == -1 || champId == 0) {
        return false;
      } else {
        return true;
        var runes = await cl.getRunes(champId);
        await cl.putRunes(runes);
      }
    } else {
      return false;
      print("Not In Champ Select");
    }
  }

  Future<List<String>> getSession(ClientManager cl, Session session) async {
    //var request = await cl.getRequest('/lol-champ-select/v1/session');
    // var body = json.decode(request);
    // var f = Session.fromJson(body);
    List<String> names = [];
    for (var teamMember in session.myTeam) {
      var response = await cl
          .getRequest("/lol-summoner/v1/summoners/${teamMember.summonerId}");
      //  await Future.delayed(Duration(seconds: 3));

      names.add(json.decode(response)['displayName']);
    }
    //print(names.length);
    return names;
  }

  Widget champSelect(ClientManager cl, Session session) {
    return FutureBuilder(
        future: getSession(cl, session),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
                future: champSelected(cl),
                builder: (context, champSelected) {
                  if (champSelected.hasData) {
                    if (champSelected.data) {
                      // CHAMP SELECTED
                      return championSelected(cl, snapshot);
                    } else {
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
                                        title: Text("${snapshot.data[i]} ")));
                              },
                            )),
                          ],
                        ),
                      );
                    }
                  } else {
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
                                      title: Text("${snapshot.data[i]} ")));
                            },
                          )),
                        ],
                      ),
                    );
                  }
                });
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
