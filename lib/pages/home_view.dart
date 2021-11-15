import 'package:dart_lol/lol_api/summoner.dart';
import 'package:flutter/material.dart';
import 'package:dart_lol/lcu/client_manager.dart';
import 'package:dart_lol/lol_api/dart_lol.dart';
import 'package:kronic_desktop_tool/providers/league_client_provider.dart';
import 'package:provider/provider.dart';

class HomeView {
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

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          summoner.summonerName,
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Level: " + summoner.summonerLevel.toString(),
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.normal,
          ),
        ),
        ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.black,
          ),
          itemCount: summoner.rank.ranks.length,
          addAutomaticKeepAlives: true,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            return _buildRankInfo(summoner, i);
          },
        ),
        FutureBuilder<NetworkImage>(
            future: summonerIcon(summoner.profileIconId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CircleAvatar(foregroundImage: snapshot.data, radius: 50);
              }
              return CircleAvatar();
            })
      ],
    );
  }
}
