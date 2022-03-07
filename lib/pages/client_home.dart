import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:kronic_desktop_tool/models/session.dart';
import 'package:kronic_desktop_tool/pages/home_view.dart';
import 'package:kronic_desktop_tool/pages/view_summoner.dart';
import 'package:kronic_desktop_tool/providers/league_client_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:dart_lol/lcu/client_manager.dart';
import 'package:dart_lol/lcu/web_socket_helper.dart';
import 'package:kronic_desktop_tool/pages/champ_select_helper.dart';

var clientRunning = false;
final FirebaseAuth _auth = FirebaseAuth.instance;

class ClientHome extends StatefulWidget {
  static const routeName = '/client_home';
  @override
  _ClientHomeState createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  final introKey = GlobalKey<IntroductionScreenState>();
  TextEditingController userNameController = TextEditingController();
  void _onIntroEnd(SharedPreferences prefs, String summonerName) async{
    if(summonerName == "")
      {
        return;
      }
    await prefs.setString('summonerName', summonerName);
    setState(() {

    });
  }
  @override
  void didChangeDependencies() {
    // check if client was running
    clientRunning = Provider.of<LeagueClientProvider>(context, listen: false)
        .clientRunningCheck;
    print(clientRunning);
    super.didChangeDependencies();
  }

  Widget clientStatus() {
    clientRunning = Provider.of<LeagueClientProvider>(context, listen: true)
        .clientRunningCheck;
    if (clientRunning) {
      return IconButton(
          icon: Icon(Icons.accessible_outlined, color: Colors.green),
          tooltip: 'League Client Running',
          onPressed: () {});
    } else {
      return IconButton(
          icon: Icon(Icons.accessible_outlined, color: Colors.red),
          tooltip: 'League Client Not Running',
          onPressed: () {});
    }
  }
  Widget barCollapsed(){

    return Container(decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0))),
        margin: EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Center(child: Text("Test header")));
  }

  Widget home(BuildContext context) {
    if(clientRunning) {
      var clientManager = Provider.of<LeagueClientProvider>(context, listen: false).clientManager!;
      var clientStream = Provider.of<LeagueClientProvider>(context, listen: false).clientStream!;

      return Container(
        decoration: BoxDecoration(
            color: Color.fromRGBO(28, 22, 46, 1),
            borderRadius: BorderRadius.all(Radius.circular(24.0))

        ),
        margin: EdgeInsets.all(24),
        child: StreamBuilder(
            stream: clientStream,
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
                  print(snapshot.data);
                  return Text("Error");
                }
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              );
            }),
      );
    } else {
      return Container();
    }

  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<LeagueClientProvider>(context, listen: false).preferences;
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0)
    );
    //final channel = IOWebSocketChannel.connect(
    //   'wss://127.0.0.1:${clientManager.getPort()}',
    //  headers: {"Authorization": "Basic ${clientManager.getAuthHeader()}"});
    //channel.sink.add('[5, "OnJsonApiEvent_lol-champ-select_v1_session"]');
    if(prefs!.getString('summonerName') != null)
    {
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
              clientStatus(),
              TextButton(
                onPressed: () {
                  prefs.remove('summonerName');
                  setState(() {

                  });
                },
                child: Text("Clear Prefs"),
              ),
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
              child: SlidingUpPanel(
                minHeight: 50.0,
                backdropEnabled: true,
                renderPanelSheet: false,
                borderRadius: radius,
                collapsed: barCollapsed(),
                panel: home(context),
                body: Center(
                 child: Text("Test"),
               ),
              ))
        //home(clientManager, channel, context)),
      );
    } else {
      //first time setup
      return IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Color.fromRGBO(28, 22, 46, 1),
        pages: [
          PageViewModel(
            title: "Welcome to the Kronic Desktop Tool",
            bodyWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 400, vertical: 0),
              child: Center(
                child: TextFormField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter Summoner Name'
                  ),
                  controller: userNameController,
                ),
              ),
            ),
          ),
        ],
        onDone: () => _onIntroEnd(prefs, userNameController.text),
        showSkipButton: false,
        skipOrBackFlex: 0,
        nextFlex: 0,
        showBackButton: true,
        //rtl: true, // Display as right-to-left
        back: const Icon(Icons.arrow_back),
        skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      );
    }
    return Container();

  }
  @override
  void dispose() {
    super.dispose();
  }
}
