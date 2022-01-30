import 'package:dart_lol/lol_api/summoner.dart';
import 'package:flutter/material.dart';
import 'package:dart_lol/lol_api/dart_lol.dart';
import 'package:kronic_desktop_tool/providers/league_client_provider.dart';
import 'package:provider/provider.dart';

class HomeView {
  Widget playerCard(Summoner summoner) {
    double boxHeight = 0;
    if (summoner.rank.ranks.length != 0) {
      boxHeight = (summoner.rank.ranks.length * 250.0);
    } else {
      boxHeight = 170;
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
                      summoner.summonerName,
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
                future: summonerIcon(summoner.profileIconId),
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
        Text(data.rank.ranks[i].tier ?? "Unranked",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text(data.rank.ranks[i].rank ?? "Unranked",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(data.rank.ranks[i].lp.toString() ?? "Not Found",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('LP', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Widget homeView(BuildContext context) {
    var summoner =
        Provider.of<LeagueClientProvider>(context, listen: false).summoner;

    //create list to store ranks
    List<Ranks> rankList = [];
    for (var rank in summoner.rank.ranks) {
      if (rank.tier == null) {
        rankList.add(rank);
      }
      //remove rankList items from summoner.rank.ranks

    }
    for (var rankToRemove in rankList) {
      summoner.rank.ranks.remove(rankToRemove);
    }

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          playerCard(summoner),
        ],
      ),
    );
  }
}
