
import 'dart:io';

class LeagueConnector {
  String process;
  String pid;
  String protocol;
  String address = "127.0.0.1";
  String port;
  String username = "riot";
  String password;
  String url;
  var lockFile;
//TODO implement automatic selection for directory.
  LeagueConnector();



Future<void> constructLCUConnector(File file) async {
  await file.readAsString().then((String contents) {
    var parts = contents.split(":");
    print(parts);
    process = parts[0];
    pid = parts[1];
    port = parts[2];
    password = parts[3];
    protocol = parts[4];
  });
  url = "https://$username:$password@$address:$port";
  print("finished league connector");
}








  /* LATER CUZ FUCK THIS
  Future<String> getInstallDirectory() async {
    var shell = Shell(runInShell: true);

    if(Platform.isWindows) {
      command = "WMIC PROCESS WHERE NAME=\'LeagueClientUx.exe\' GET ExecutablePath";
    } else {
      command = 'ps x -o args | grep \'LeagueClientUx\'';
    }
    await shell.run('''WMIC PROCESS WHERE NAME=LeagueClientUx.exe GET ExecutablePath''');

  }
      */
}

