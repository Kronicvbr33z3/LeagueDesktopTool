import 'package:dart_lol/lol_api/dart_lol.dart';
import 'package:dart_lol/lol_api/summoner.dart';
import 'package:flutter/material.dart';
import 'package:kronic_desktop_tool/pages/home_view.dart';

class ViewSummoner extends StatefulWidget {
  static const routeName = '/view_summoner';
  String? summoner;
  ViewSummoner();
  ViewSummoner.fromPlayer(this.summoner);
  @override
  _ViewSummonerState createState() => _ViewSummonerState();
}

class _ViewSummonerState extends State<ViewSummoner> {
  var version;
  Future<Summoner> setupSummoner(String value) async {
    version = await getLatestPatch();
    Summoner instance = Summoner.fromName(value);
    await instance.setupSearchedSummoner();
    //Check to make sure Data is Valid
    if (instance.accountId == null || instance.summonerName == null) {
      throw StateError('Error');
    }
    return instance;
  }

  Widget _buildRow(Summoner data, int index) {
    Color getColor(int index) {
      if (data.matches[index].me.win) {
        return Color.fromRGBO(65, 111, 201, 1);
      } else {
        return Color.fromRGBO(184, 88, 88, 1);
      }
    }

    CircleAvatar getChampionIcon(String championName) {
      String champ = championName.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
      String path =
          'http://ddragon.leagueoflegends.com/cdn/$version/img/champion/$champ.png';
      return CircleAvatar(
        backgroundImage: NetworkImage(path),
        backgroundColor: Colors.transparent,
      );
    }

    String getKDA() {
      double kda;
      kda = (data.matches[index].me.kills + data.matches[index].me.assists) /
          (data.matches[index].me.deaths);
      String skda = kda.toStringAsFixed(3);
      String n = ":1";
      var finalKDA = "$skda$n KDA";
      return finalKDA;
    }

    String getMinuteString(double decimalValue) {
      return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
    }

    String getHourString(int flooredValue) {
      return '${flooredValue % 60}'.padLeft(2, '0');
    }

    String getGameDuration() {
      double gameDuration = data.matches[index].gameDuration / 60;
      int flooredValue = gameDuration.floor();
      double decimalValue = gameDuration - flooredValue;
      String hourValue = getHourString(flooredValue);
      String minuteString = getMinuteString(decimalValue);

      return '$hourValue:$minuteString';
    }

    return Container(
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: getColor(index),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(5),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                  (() {
                    if (data.matches[index].me.win) {
                      return "Victory";
                    }
                    return "Defeat";
                  }()),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18)),
              Text(
                  (() {
                    if (data.matches[index].gameMode != null) {
                      return data.matches[index].gameMode;
                    }
                    return "Unknown";
                  }()),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 6)),
            ],
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 15,
            ),
            Text(
              data.matches[index].me.kills.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18),
            ),
            Text('/',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18)),
            Text(data.matches[index].me.deaths.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18)),
            Text('/',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18)),
            Text(data.matches[index].me.assists.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18)),
          ],
        ),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 5,
            ),
            Text(
              getKDA(),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 80,
            ),
            Spacer(flex: 1),
            Text(getGameDuration()),
          ],
        ),
        trailing: getChampionIcon(data.matches[index].me.championName),
      ),
    );
  }

  int getQueue(int soloOrFlex, Summoner data) {
    if (data.rank.ranks.length == 0) {
      return -1;
    }
    if (soloOrFlex == 1) {
      for (int i = 0; i <= data.rank.ranks.length - 1; i++) {
        if (data.rank.ranks[i].queueType == "RANKED_SOLO_5x5") {
          return i;
        }
      }
      // No Solo Duo Rank
      return -1;
    } else {
      for (int i = 0; i <= data.rank.ranks.length - 1; i++) {
        if (data.rank.ranks[i].queueType == "RANKED_FLEX_SR") {
          return i;
        }
      }
      // No Flex Rank
      return -1;
    }
  }

  Widget _buildRankInfo(Summoner data, int i) {
    if (i == 0) {
      var currentQueue = getQueue(1, data);
      if (currentQueue == -1) {
        return Text("Unranked");
      }
      // Solo Duo on Top
      return Column(
        children: <Widget>[
          Text('Solo/Duo',
              style: TextStyle(
                  color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
          Text(data.rank.ranks[currentQueue].tier,
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(data.rank.ranks[currentQueue].rank,
              style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(data.rank.ranks[currentQueue].lp.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('LP', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      );
    } else {
      // Flex on Bottom
      var currentQueue = getQueue(2, data);
      if (currentQueue != -1) {
        return Column(
          children: <Widget>[
            Text('Flex',
                style: TextStyle(
                    color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
            Text(data.rank.ranks[currentQueue].tier,
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(data.rank.ranks[currentQueue].rank,
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(data.rank.ranks[currentQueue].lp.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('LP', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        );
      }
      return Column(
        children: <Widget>[
          Text('Flex',
              style: TextStyle(
                  color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
          Text("Unranked",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          SizedBox(
            height: 40,
          )
        ],
      );
    }
  }

  Widget _buildMatchHistory(Summoner data) {
    return ListView.builder(
        controller: new ScrollController(),
        itemCount: 15,
        padding: const EdgeInsets.all(0),
        itemBuilder: (context, i) {
          return Padding(
              padding: EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: _buildRow(data, i));
        });
  }

  Widget playerCard(Summoner summoner) {
    double boxHeight = 0;
    if (summoner.rank.ranks.length != 0) {
      boxHeight = 150 + (summoner.rank.ranks.length * 80);
    } else {
      boxHeight = 150;
    }
    return Stack(
      children: <Widget>[
        Card(
          margin: const EdgeInsets.only(top: 20.0),
          child: SizedBox(
              height: boxHeight,
              width: 300,
              child: Padding(
                padding: const EdgeInsets.only(top: 45.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      summoner.summonerName!,
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Level: " + summoner.summonerLevel.toString()),
                    ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.yellow,
                      ),
                      itemCount: summoner.rank.ranks.length,
                      addAutomaticKeepAlives: true,
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        if (summoner.rank.ranks[i].tier == null) {
                          return Container();
                        }
                        return _buildRankInfo(summoner, i);
                      },
                    ),
                  ],
                ),
              )),
        ),
        Positioned(
          top: .0,
          left: .0,
          right: .0,
          child: Center(
            child: FutureBuilder<NetworkImage>(
                future: summonerIcon(summoner.profileIconId!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return CircleAvatar(
                      radius: 30,
                      foregroundImage: snapshot.data,
                    );
                  }
                  return CircleAvatar();
                }),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String? data;
    if (widget.summoner == null) {
      data = ModalRoute.of(context)?.settings.arguments as String?;
    } else {
      data = widget.summoner;
    }

    return FutureBuilder<Summoner>(
        future: setupSummoner(data!),
        builder: (BuildContext context, AsyncSnapshot<Summoner> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                  elevation: 0, backgroundColor: Color.fromRGBO(28, 22, 46, 1)),
              backgroundColor: Color.fromRGBO(28, 22, 46, 1),
              body: Row(
                children: <Widget>[
                  playerCard(snapshot.data!),
                  Expanded(
                    child: Container(
                      width: 500,
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: _buildMatchHistory(snapshot.data!),
                    ),
                  ),
                  //Divider(color: Color.fromRGBO(43, 38, 60, 1), thickness: 2,),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
                backgroundColor: Color.fromRGBO(28, 22, 46, 1),
                appBar: AppBar(
                  title: Text("Summoner Not Found!"),
                ),
                body: Container(
                  decoration: BoxDecoration(),
                ));
          } else {
            return Scaffold(
                backgroundColor: Color.fromRGBO(28, 22, 46, 1),
                appBar: AppBar(
                  title: Text("Loading!"),
                ),
                body: Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    width: 60,
                    height: 60,
                  ),
                ));
          }
        });
  }
}

class RouteArguments {
  Summoner data;
  int index;

  RouteArguments(this.data, this.index);
}
