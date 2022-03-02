import 'package:dart_lol/lol_api/dart_lol.dart';
import 'package:dart_lol/lol_api/summoner.dart';
import 'package:flutter/material.dart';

class ViewSummoner extends StatefulWidget {
  static const routeName = '/view_summoner';
  @override
  _ViewSummonerState createState() => _ViewSummonerState();
}

//TODO Make Rank Look Good
class _ViewSummonerState extends State<ViewSummoner> {
  var version;
  Future<Summoner> setupSummoner(String value) async {
    version = await getLatestPatch();
    Summoner instance = Summoner.fromName(value);
    await instance.setupSearchedSummoner();
    //Check to make sure Data is Valid
    if (instance.accountId == null ||
        instance.summonerName == null ||
        instance.matches == null ||
        instance.rank == null) {
      throw StateError('Error');
    }
    return instance;
  }

  Widget _buildRow(Summoner data, int index) {
    RouteArguments args = RouteArguments(data, index);
    Color getColor(int index) {
      //print(data.matches.matches[index].participants.gameDuration / 60);
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

  Text getQueue(Summoner data, int i) {
    switch (data.rank.ranks[i].queueType) {
      case "RANKED_SOLO_5x5":
        return Text('Solo/Duo',
            style: TextStyle(
                color: Colors.yellowAccent, fontWeight: FontWeight.bold));
      case "RANKED_FLEX_SR":
        return Text('Flex',
            style: TextStyle(
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
            ));
      default:
        return Text('Unknown Queue');
    }
  }

  Widget _buildRankInfo(Summoner data, int i) {
    return Column(
      children: <Widget>[
        getQueue(data, i),
        Text(data.rank.ranks[i].tier,
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text(data.rank.ranks[i].rank,
            style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(data.rank.ranks[i].lp.toString(),
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('LP', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Widget _buildRank(Summoner data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Color.fromRGBO(43, 38, 60, 1),
            ),
            margin: EdgeInsets.fromLTRB(300, 0, 10, 0),
            child: Column(
              children: <Widget>[
                ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey,
                  ),
                  itemCount: data.rank.ranks.length,
                  shrinkWrap: true,
                  addAutomaticKeepAlives: true,
                  itemBuilder: (context, i) {
                    return _buildRankInfo(data, i);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    String? data = ModalRoute.of(context)?.settings.arguments as String?;

    return FutureBuilder<Summoner>(
        future: setupSummoner(data!),
        builder: (BuildContext context, AsyncSnapshot<Summoner> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Color.fromRGBO(28, 22, 46, 1),
              appBar: AppBar(
                title: Text(snapshot.data!.summonerName!,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                elevation: 0.0,
                backgroundColor: Color.fromRGBO(28, 22, 46, 1),
              ),
              body: Column(
                children: <Widget>[
                  Divider(
                    color: Color.fromRGBO(43, 38, 60, 1),
                    thickness: 2,
                  ),
                  _buildRank(snapshot.data!),
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
