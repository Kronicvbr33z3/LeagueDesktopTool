// ignore_for_file: unused_field

import 'package:dart_lol/lcu/client_manager.dart';
import 'package:dart_lol/lol_api/summoner.dart';
import 'package:watcher/watcher.dart';
import 'package:flutter/material.dart';
import 'package:dart_lol/lcu/league_client_connector.dart';

class LeagueClientProvider with ChangeNotifier {
  // A provider that watches for changes to the league client.
  // this is used to update the app when the league client launches or closes.

  //Runs command every 5 seconds to check if league client is running.
  String _status;
  FileWatcher _lockfileWatcher;
  var _clientRunning;
  ClientManager _clientManager;
  Summoner _summoner;
  // Construct and initalize client manager
  ClientManager get clientManager => _clientManager;
  Summoner get summoner => _summoner;

  Future<void> makeClientManager(LeagueConnector c) async {
    _clientManager = ClientManager(c);
    _summoner = await _clientManager.getSummoner();
    await _summoner.setupSummoner();
    await _summoner.getRankedInfo();

    notifyListeners();
  }

/*   Stream<bool> clientRunning() {
    StreamController<bool> _clientRunningController;
    Timer timer;
    Duration timerInterval = Duration(seconds: 5);
    _connector = LeagueConnector();
    void startCheck() async {
      timer = Timer.periodic(timerInterval, (timer) async {
        //Brodcast false if client is not running
        var status = await _connector.constructLCUConnector();
        _clientRunningController.add(status);
        if (status) {
          timer.cancel();
        }
      });
    }

    void running() async {}
    _clientRunningController = StreamController<bool>(onListen: startCheck);

    return _clientRunningController.stream;
  } */
}
