import 'dart:convert';

import 'package:dart_lol/lcu/client_manager.dart';
import 'package:http/http.dart';

class KronicServer {
  // Get Runes through the API endpoint
  // http://kronicdesktoptool.tplinkdns.com/api/v1/runes?id={id}

  static Future<RuneData> getRunes(int champId) async {
    Response response = await get(Uri.parse(
        "http://kronicdesktoptool.tplinkdns.com/api/v1/runes?id=$champId"));
    if (response.statusCode == 200) {
      return RuneData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load runes');
    }
  }
}
