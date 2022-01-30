library dart_lol;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// A DataDragon data access.

Future<String> getLatestPatch() async {
  var response = await http
      .get(Uri.parse("https://ddragon.leagueoflegends.com/api/versions.json"));
  var json = jsonDecode(response.body);
  return json[0];
}

Future<NetworkImage> summonerIcon(int id) async {
  var version = await getLatestPatch();
  var url =
      "http://ddragon.leagueoflegends.com/cdn/$version/img/profileicon/$id.png";
  return NetworkImage(url);
}

Future<CircleAvatar> getChampionIcon(String championName) async {
  var version = await getLatestPatch();
  String champ = championName.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
  String path =
      'http://ddragon.leagueoflegends.com/cdn/$version/img/champion/$champ.png';
  return CircleAvatar(
    backgroundImage: NetworkImage(path),
    backgroundColor: Colors.transparent,
  );
}
