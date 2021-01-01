import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kronic_desktop_tool/services/league_client_connector.dart';

class ClientManager {

  LeagueConnector connector;
  ClientManager(this.connector);

  Future<void> postRequest(String endpoint, body) async{
    var url = "${connector.url}$endpoint";
    var response = await http.post(url, headers: {"Content-Type": "application/json"},body: body);
  }
  Future<void> createCustomBlindPickLobby() async{
    postRequest("/lol-lobby/v2/lobby", jsonEncode({

      "customGameLobby": {
        "configuration": {
          "gameMode": "CLASSIC", "gameMutator": "", "gameServerRegion": "", "mapId": 11, "mutators": {"id": 1}, "spectatorPolicy": "AllAllowed", "teamSize": 5
        },
        "lobbyName": "Name",
        "lobbyPassword": null
      },
      "isCustom": true

    }));
  }
  Future<bool> champSelect() async {
    var url = "${connector.url}/lol-champ-select/v1/session";
    var response = await http.get(url);


    if(response.body.contains("No active delegate")) {
      return false;
    } else {
      return true;
    }

  }
}