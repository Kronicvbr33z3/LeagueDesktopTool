import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kronic_desktop_tool/models/session.dart';
import 'package:kronic_desktop_tool/pages/home_view.dart';
import 'package:kronic_desktop_tool/pages/view_summoner.dart';
import 'package:kronic_desktop_tool/providers/league_client_provider.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:dart_lol/lcu/client_manager.dart';
import 'package:web_socket_channel/io.dart';
import 'package:dart_lol/lcu/web_socket_helper.dart';
import 'package:kronic_desktop_tool/pages/champ_select_helper.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ClientHome extends StatefulWidget {
  static const routeName = '/client_home';
  @override
  _ClientHomeState createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  @override
  void initState() {
    super.initState();
  }

  Widget home(ClientManager clientManager, WebSocketChannel channel,
      BuildContext context) {
    return StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasError) {
            children = <Widget>[Text("Error has Occurred")];
          } else {
            if (snapshot.hasData) {
              LCUWebSocketResponse response =
                  LCUWebSocketResponse(snapshot.data! as String);

              switch (response.status) {
                // Home Screen
                case 0:
                  {
                    children = <Widget>[
                      Expanded(child: HomeView().homeView(context))
                    ];
                  }
                  break;
                // Champion Select Screen
                case 1:
                  {
                    Session session = Session.fromJson(
                        json.decode(snapshot.data! as String)[2]['data']);

                    children = <Widget>[
                      ChampionSelectHelper().champSelect(clientManager, session)
                    ];
                  }
                  break;
                default:
                  {
                    children = <Widget>[Text("Default")];
                  }
              }
            } else {
              return Text("Error");
            }
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    //ClientManager clientManager =
    //    Provider.of<LeagueClientProvider>(context, listen: true).clientManager;
    //final channel = IOWebSocketChannel.connect(
    //   'wss://127.0.0.1:${clientManager.getPort()}',
    //  headers: {"Authorization": "Basic ${clientManager.getAuthHeader()}"});
    //channel.sink.add('[5, "OnJsonApiEvent_lol-champ-select_v1_session"]');
    return Scaffold(
        drawer: Drawer(),
        appBar: AppBar(
          title: Container(
              width: 250,
              height: 40,
              child: Center(
                child: TextField(
                  onSubmitted: (String value) async {
                    if (value == '') {
                      //Field is Empty Don't Submit
                    } else {
                      //Initialize Summoner with value from text controller
                      Navigator.pushNamed(context, ViewSummoner.routeName,
                          arguments: value);
                    }
                  },
                  decoration: InputDecoration(
                      hintText: "Search for Summoner",
                      prefixIcon: Icon(Icons.search)),
                ),
              )),
          actions: [
            // Add status of league connection here via green/red circle
            StreamBuilder<bool>(
                stream: Provider.of<LeagueClientProvider>(context, listen: true)
                    .clientRunning(),
                builder: (context, AsyncSnapshot<bool>? snapshot) {
                  if (snapshot!.hasData) {
                    if (snapshot.data == true) {
                      Provider.of<LeagueClientProvider>(context, listen: true)
                          .makeClientManager();
                      return IconButton(
                        icon: Icon(Icons.check_circle),
                        onPressed: () {},
                      );
                    } else {
                      return IconButton(
                        icon: Icon(Icons.error),
                        onPressed: () {},
                      );
                    }
                  } else {
                    return IconButton(
                      icon: Icon(Icons.error),
                      onPressed: () {},
                    );
                  }
                }),

            TextButton(
              onPressed: () {
                _auth.signOut();
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text("Sign Out"),
            )
          ],
        ),
        body: Container(
            constraints: BoxConstraints.expand(),
            color: Color.fromRGBO(28, 22, 46, 1),
            child: Container())
        //home(clientManager, channel, context)),
        );
  }
}
