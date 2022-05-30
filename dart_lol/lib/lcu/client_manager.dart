library dart_lol;

import 'dart:convert';
import 'package:dart_lol/lol_api/summoner.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:dart_lol/lcu/league_client_connector.dart';

class ClientManager {
  LeagueConnector connector;
  ClientManager(this.connector);

  Future<void> postRequest(String endpoint, body) async {
    var url = "${connector.url}$endpoint";
    var req = await http.post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: body);
    print(req.statusCode);
  }

  Future<void> putRequest(String endpoint, body) async {
    var url = "${connector.url}$endpoint";
    var req = await http.put(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: body);
    print(req.statusCode);
  }

  Future<String> getRequest(String endpoint) async {
    var url = "${connector.url}$endpoint";
    var response = await http.get(Uri.parse(url));

    return response.body;
  }

  Future<void> deleteRequest(String endpoint) async {
    var url = "${connector.url}$endpoint";
    var req = await http
        .delete(Uri.parse(url), headers: {"Accept": "application/json"});
    print(req.statusCode);
  }

  Future<void> createCustomBlindPickLobby() async {
    postRequest(
        "/lol-lobby/v2/lobby",
        jsonEncode({
          "customGameLobby": {
            "configuration": {
              "gameMode": "CLASSIC",
              "gameMutator": "",
              "gameServerRegion": "",
              "mapId": 11,
              "mutators": {"id": 1},
              "spectatorPolicy": "AllAllowed",
              "teamSize": 5
            },
            "lobbyName": "Name",
            "lobbyPassword": null
          },
          "isCustom": true
        }));
  }

  Future<bool> champSelect() async {
    var url = "${connector.url}/lol-champ-select/v1/session";
    var response = await http.get(Uri.parse(url));

    if (response.body.contains("No active delegate")) {
      return false;
    } else {
      return true;
    }
  }

  Future<int> _getRuneId() async {
    var url = "${connector.url}/lol-perks/v1/currentpage";
    var response = await http.get(Uri.parse(url));
    var file = json.decode(response.body);
    return file['id'];
  }

  Future<int> getCurrentChampId() async {
    var url = "${connector.url}/lol-champ-select/v1/current-champion";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var id = int.parse(response.body);
      return id;
    }
    return -1;
  }

  Future<Summoner> getSummoner() async {
    var url = "${connector.url}/lol-summoner/v1/current-summoner";
    var response = await http.get(Uri.parse(url));
    var file = json.decode(response.body);
    return Summoner(
        file['accountId'],
        file['displayName'],
        file['profileIconId'],
        file['puuid'],
        file['summonerLevel'],
        file['summonerId']);
  }

  Future<RuneData> getRunes(int champId, [int? id]) async {
    var file = await rootBundle.loadString('python/champions/$champId.json');
    var values = jsonDecode(file);

    return RuneData(
        values['perk0'],
        values['perk1'],
        values['perk2'],
        values['perk3'],
        values['perk4'],
        values['perk5'],
        values['statPerk0'],
        values['statPerk1'],
        values['statPerk2'],
        values['primaryStyleId'],
        values['subStyleId']);
  }

  Future<void> putRunes(RuneData rd) async {
    var runeId = await _getRuneId();
    await deleteRequest('/lol-perks/v1/pages/$runeId');
    postRequest(
        '/lol-perks/v1/pages',
        jsonEncode({
          "autoModifiedSelections": [],
          "current": true,
          "id": 0,
          "isActive": false,
          "isDeletable": true,
          "isEditable": true,
          "isValid": true,
          "lastModified": 0,
          "name": "Kronic Desktop Tool",
          "order": 0,
          "primaryStyleId": rd.primaryStyleId,
          "selectedPerkIds": [
            rd.perk0,
            rd.perk1,
            rd.perk2,
            rd.perk3,
            rd.perk4,
            rd.perk5,
            rd.statPerk0,
            rd.statPerk1,
            rd.statPerk2
          ],
          "subStyleId": rd.subStyleId
        }));
  }

  String getAuthHeader() {
    String credentials = "${connector.username}:${connector.password}";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode(credentials);
  }

  String getPort() {
    return connector.port;
  }
  Future<bool> checkClientConnection() async{
    var url = "${connector.url}/lol-summoner/v1/current-summoner";
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200){
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;

  }
}

class RuneData {
  int perk0;
  int perk1;
  int perk2;
  int perk3;
  int perk4;
  int perk5;
  int statPerk0;
  int statPerk1;
  int statPerk2;
  int primaryStyleId;
  int subStyleId;
  RuneData(
      this.perk0,
      this.perk1,
      this.perk2,
      this.perk3,
      this.perk4,
      this.perk5,
      this.statPerk0,
      this.statPerk1,
      this.statPerk2,
      this.primaryStyleId,
      this.subStyleId);

  static RuneData fromJson(decode) {
    return RuneData(
        decode['perk0'],
        decode['perk1'],
        decode['perk2'],
        decode['perk3'],
        decode['perk4'],
        decode['perk5'],
        decode['statPerk0'],
        decode['statPerk1'],
        decode['statPerk2'],
        decode['primaryStyleId'],
        decode['subStyleId']);
  }
}
