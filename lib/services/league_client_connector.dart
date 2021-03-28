
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



Future<void> constructLCUConnector() async {

  RegExp portexp = RegExp("--app-port=([0-9]*)");
  RegExp passexp = RegExp('--remoting-auth-token=([\\w-_]*)');
  if(Platform.isWindows) {
   await Process.run("wmic", ['PROCESS', 'WHERE', "name='LeagueClientUx.exe'", 'GET', 'commandline'] ).then((ProcessResult results) {
     if(portexp.hasMatch(results.stdout))
       {
         
         port = portexp.firstMatch(results.stdout.toString()).group(1);
         password = passexp.firstMatch(results.stdout.toString()).group(1);
       }

    });
  } else {
    await Process.run("ps", ['x', '-o', 'args' ,'|' ,'grep', "\'LeagueClientUx\'"]).then((ProcessResult results) {
      if (portexp.hasMatch(results.stdout)){

        final port = portexp.firstMatch(results.stdout.toString()).group(1);
        final pass = passexp.firstMatch(results.stdout.toString()).group(1);
      }
    });
  }

  url = "https://$username:$password@$address:$port";
  print("Finished Connector With Regex");

}

  /*
}
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
  await getInstallDirectory();

   */
}
