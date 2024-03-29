// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:dart_lol/lcu/client_manager.dart';
import 'package:dart_lol/lol_api/summoner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcher/watcher.dart';
import 'package:flutter/material.dart';
import 'package:dart_lol/lcu/league_client_connector.dart';
import 'package:web_socket_channel/io.dart';

class LeagueClientProvider with ChangeNotifier {
  // A provider that watches for changes to the league client.
  // this is used to update the app when the league client launches or closes.

  //Runs command every 5 seconds to check if league client is running.
  LeagueClientProvider() {
    clientRunning()
        .listen((data) async {
      if (data) {
        await makeClientManager();
        await initWebSocket();
        _clientRunningCheck = true;
        notifyListeners();
      } else {
        // client is not running
        // check to see if client was previously running
        if(_clientManager != null)
          {
            await leagueChannel!.sink.close();
            leagueChannel = null;
          }
      }
    });
  }


  DirectoryWatcher? _dirWatcher;
  ClientManager? _clientManager;
  Summoner? _summoner;
  String _leagueClientDir = "";
  bool _clientRunningCheck = false;
  IOWebSocketChannel? leagueChannel;
  SharedPreferences? preferences;
  Stream? leagueStream;

  // Construct and initalize client manager
  LeagueConnector? _connector;
  ClientManager? get clientManager => _clientManager!;
  Summoner get summoner => _summoner!;
  bool get clientRunningCheck => _clientRunningCheck;

  Future<bool> makeClientManager() async {
    if(_clientManager != null)
      {
        return true;
      }
    _clientManager = ClientManager(_connector!);
    while (!await _clientManager!.checkClientConnection())
      {
        print("Client not ready trying again in 5 seconds");
        await Future.delayed(Duration(seconds: 5));
      }
    _summoner = await _clientManager?.getSummoner();
    await _summoner?.setupSummoner();
    notifyListeners();
    return true;
  }
  Future<void> initWebSocket() async {
    if(leagueChannel != null)
      {
        return;
      }
    leagueChannel =  IOWebSocketChannel.connect(
        'wss://127.0.0.1:${clientManager!.getPort()}',
        headers: {"Authorization": "Basic ${clientManager!.getAuthHeader()}"});

    leagueChannel!.sink
        .add('[5, "OnJsonApiEvent_lol-champ-select_v1_session"]');
    leagueStream = leagueChannel!.stream.asBroadcastStream();
  }
  Future<void>? initProcessWatcher(StreamController<bool>? stream) {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (await _connector!.constructLCUConnector()) {
      _leagueClientDir = _connector!.path;
      await initLockFileWatcher(_leagueClientDir, stream!);
      stream.add(true);
      print("League Client Directory: $_leagueClientDir");
      timer.cancel();
      }
    });
    return null;
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
        _clientManager?.connector = _connector!;
        while (!await _clientManager!.checkClientConnection())
        {
          print("Client not ready trying again in 5 seconds");
          await Future.delayed(Duration(seconds: 5));
        }

        await initWebSocket();
        stream.add(true);
        _clientRunningCheck = true;
        notifyListeners();
      } else if (event.path.contains("lockfile") &&
          event.type == ChangeType.REMOVE) {
        stream.add(false);
        _clientRunningCheck = false;
        notifyListeners();
        try {
          leagueChannel?.sink.close();
        } catch (e) { }
        return;
      }
    });
    return null;
  }
  Stream<bool> clientRunning() {
    StreamController<bool>? _clientRunningController;
    _connector = LeagueConnector();
    void startCheck() async {
      //get preferences
      // retrieve league install directory if it exists from shared preferences



      if (_leagueClientDir != "") {
        await initLockFileWatcher(_leagueClientDir, _clientRunningController!);
        return;
      }
      if (await _connector!.constructLCUConnector()) {
        _leagueClientDir = _connector!.path;
        await initLockFileWatcher(_leagueClientDir, _clientRunningController!);
        _clientRunningController.add(true);
        print("League Client Directory: $_leagueClientDir");
      } else {
        initProcessWatcher(_clientRunningController);
      }
    }
    void stopCheck() async {
      // cleanup

    }

    _clientRunningController = StreamController<bool>(onListen: startCheck, onCancel: stopCheck);

    return _clientRunningController.stream;
  }
}
