library dart_lol;

import 'dart:io';

class LeagueConnector {
  late String process;
  String? pid;
  late String protocol;
  String address = "127.0.0.1";
  String port = "null";
  String username = "riot";
  String password = "";
  late String path;
  late String url;
  late var lockFile;

  late bool success;

  LeagueConnector();

  Future<bool> constructLCUConnector() async {
    RegExp portexp = RegExp("--app-port=([0-9]*)");
    RegExp passexp = RegExp('--remoting-auth-token=([\\w-_]*)');
    RegExp installRegex = RegExp("\"--install-directory=(.*?)\"");
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
          path = installRegex.firstMatch(results.stdout.toString())!.group(1)!;
          url = "https://$username:$password@$address:$port";
          success = true;
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

  Future<bool> constructFromLCUFile(File file) async {
    await file.readAsString().then((String contents) {
      var parts = contents.split(":");
      process = parts[0];
      pid = parts[1];
      port = parts[2];
      password = parts[3];
      protocol = parts[4];
    });
    url = "https://$username:$password@$address:$port";
    print("Finished Connector With File");
    return true;
  }
}
