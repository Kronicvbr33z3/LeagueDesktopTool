// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:dart_lol/lcu/client_manager.dart';
import 'package:dart_lol/lol_api/summoner.dart';
import 'package:watcher/watcher.dart';
import 'package:flutter/material.dart';
import 'package:dart_lol/lcu/league_client_connector.dart';

class LeagueClientProvider with ChangeNotifier {
  // A provider that watches for changes to the league client.
  // this is used to update the app when the league client launches or closes.

  //Runs command every 5 seconds to check if league client is running.
  DirectoryWatcher? _dirWatcher;
  ClientManager? _clientManager;
  Summoner? _summoner;
  String _leagueClientDir = "";
  // Construct and initalize client manager
  LeagueConnector? _connector;
  ClientManager get clientManager => _clientManager!;
  Summoner get summoner => _summoner!;

  Future<bool> makeClientManager() async {
    _clientManager = ClientManager(_connector!);
    _summoner = await _clientManager?.getSummoner();
    await _summoner?.setupSummoner();
    notifyListeners();
    return true;
  }

  Future<void>? initLockFileWatcher(String dir, StreamController<bool> stream) {
    if (_dirWatcher != null) {
      return null;
    }

    _dirWatcher = DirectoryWatcher(dir);
    _dirWatcher?.events.listen((event) async {
      if (event.path.contains("lockfile") && event.type == ChangeType.ADD) {
        var file = File(event.path);
        await _connector?.constructFromLCUFile(file);
        stream.add(true);
      } else if (event.path.contains("lockfile") &&
          event.type == ChangeType.REMOVE) {
        stream.add(false);
        return;
      }
    });
    return null;
  }

  Stream<bool> clientRunning() {
    StreamController<bool>? _clientRunningController;
    _connector = LeagueConnector();
    void startCheck() async {
      if (_leagueClientDir != "") {
        await initLockFileWatcher(_leagueClientDir, _clientRunningController!);
        return;
      }

      if (await _connector!.constructLCUConnector()) {
        _leagueClientDir = _connector!.path;
        await initLockFileWatcher(_leagueClientDir, _clientRunningController!);
        _clientRunningController.add(true);
        print("League Client Directory: $_leagueClientDir");
      } else {}
    }

    _clientRunningController = StreamController<bool>(onListen: startCheck);

    return _clientRunningController.stream;
  }
}
