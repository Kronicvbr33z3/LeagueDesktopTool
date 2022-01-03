library dart_lol;

import 'dart:io';

class LeagueConnector {
  late String process;
  late String pid;
  late String protocol;
  String address = "127.0.0.1";
  String port = "null";
  String username = "riot";
  String password = "";
  late String url;
  late var lockFile;

  late bool success;

  LeagueConnector();

  Future<bool> constructLCUConnector() async {
    RegExp portexp = RegExp("--app-port=([0-9]*)");
    RegExp passexp = RegExp('--remoting-auth-token=([\\w-_]*)');
    if (Platform.isWindows) {
      await Process.run("wmic", [
        'PROCESS',
        'WHERE',
        "name='LeagueClientUx.exe'",
        'GET',
        'commandline'
      ]).then((ProcessResult results) {
        if (portexp.hasMatch(results.stdout)) {
          port = portexp.firstMatch(results.stdout.toString())!.group(1)!;
          password = passexp.firstMatch(results.stdout.toString())!.group(1)!;
          url = "https://$username:$password@$address:$port";
          success = true;
          print("Finished Connector With Regex");
        } else {
          success = false;
        }
      });
    } else {
      await Process.run(
              "ps", ['x', '-o', 'args', '|', 'grep', "\'LeagueClientUx\'"])
          .then((ProcessResult results) {
        if (portexp.hasMatch(results.stdout)) {
          final port = portexp.firstMatch(results.stdout.toString())!.group(1);
          // final pass = passexp.firstMatch(results.stdout.toString())!.group(1);
          url = "https://$username:$password@$address:$port";
          print("Finished Connector With Regex");
          success = true;
        } else {
          success = false;
        }
      });
      success = false;
    }
    return success;
  }
}
