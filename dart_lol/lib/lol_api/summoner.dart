library dart_lol;

import 'dart:convert';

import 'package:http/http.dart';
import 'package:dart_lol/auth/secrets.dart';

final String apiKey = '$riotApiKey';

class Summoner {
  static final String apiKey = '$riotApiKey';
  String summonerName = "";
  int accountId = 0;
  int profileIconId = 0;
  String puuid = "";
  int summonerLevel = 0;
  int lcuSummonerApi = 0;
  //MatchHistory matches;
  late Rank rank;
  late String summonerId;
  late List<Match> matches;
  Summoner(this.accountId, this.summonerName, this.profileIconId, this.puuid,
      this.summonerLevel, this.lcuSummonerApi);
  Summoner.fromName(this.summonerName);

  Summoner.fromJson(Map<String, dynamic> json) {
    summonerName = json['displayName'];
  }

  Future<void> getAccountId() async {
    // make the request
    try {
      Response response = await get(Uri.parse(
          'https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/$summonerName?api_key=$apiKey'));
      Map summoner = jsonDecode(response.body);

      summonerId = summoner['id'];
      summonerName = summoner['name'];
      summonerLevel = summoner['summonerLevel'];
      puuid = summoner['puuid'];
    } catch (e) {
      print('Unable to Load Summoner');
    }
  }

  Future<void> getRankedInfo() async {
    try {
      Response response = await get(Uri.parse(
          'https://na1.api.riotgames.com/lol/league/v4/entries/by-summoner/$summonerId?api_key=$apiKey'));

      rank = new Rank.fromJson(response.body);
    } catch (e) {
      print(e);
    }
  }

  Future<void> setupSummoner() async {
    try {
      Response response = await get(Uri.parse(
          'https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/$summonerName?api_key=$apiKey'));
      Map summoner = json.decode(response.body);

      summonerId = summoner['id'];
    } catch (e) {
      print('Unable to Load Summoner');
      accountId = 0;
    }
    await getRankedInfo();
  }

  Future<void> getMatchHistory() async {
    try {
      Response response = await get(Uri.parse(
          'https://americas.api.riotgames.com/lol/match/v5/matches/by-puuid/$puuid/ids?start=0&count=15&api_key=$apiKey'));
      var matchHistory = json.decode(response.body);
      matches = [];
      for (var match in matchHistory) {
        matches.add(Match(match));
      }
      for (var match in matches) {
        await match.getMatch(puuid);
      }
      //print(matchHistory);
    } catch (e) {
      print(e);
    }
  }

  Future<void> setupSearchedSummoner() async {
    await getAccountId();
    await getRankedInfo();
    await getMatchHistory();
  }
}

class Match {
  String matchId;
  late int gameDuration;
  late int queueId;
  late int gameId;
  late String gameMode;
  late int mapId;
  List<Participant> participants = [];
  late Participant me;
  Match(this.matchId);

  Future<void> getMatch(String puuid) async {
    try {
      Response response = await get(Uri.parse(
          'https://americas.api.riotgames.com/lol/match/v5/matches/$matchId?api_key=$apiKey'));
      var match = json.decode(response.body);
      gameDuration = match['info']['gameDuration'];
      queueId = match['info']['queueId'];
      gameId = match['info']['gameId'];
      gameMode = match['info']['gameMode'];
      mapId = match['info']['mapId'];
      var listOfParticpants = match['info']['participants'] as List;
      for (var participant in listOfParticpants) {
        participants.add(Participant.fromJson(participant));
      }
      for (var participant in participants) {
        if (participant.puuid == puuid) {
          me = participant;
        }
      }
    } catch (e) {
      print(e);
    }
  }
}

class Participant {
  late int championId;
  late String championName;
  late String puuid;
  late String summonerName;
  late int summonerLevel;
  late int kills;
  late int assists;
  late int deaths;
  late int summoner1Id;
  late int summoner2Id;
  late bool win;

  Participant.fromJson(Map<String, dynamic> jsonMap) {
    this.championId = jsonMap['championId'];
    this.championName = jsonMap['championName'];
    this.puuid = jsonMap['puuid'];
    this.summonerName = jsonMap['summonerName'];
    this.summonerLevel = jsonMap['summonerLevel'];
    this.kills = jsonMap['kills'];
    this.assists = jsonMap['assists'];
    this.deaths = jsonMap['deaths'];
    this.summoner1Id = jsonMap['summoner1Id'];
    this.summoner2Id = jsonMap['summoner2Id'];
    this.win = jsonMap['win'];
  }
}

// INFO FROM RANKS (ADD ANYTHING FOR RANKS HERE)
class Ranks {
  late String queueType;
  late int wins;
  late String rank;
  late String tier;
  late int lp;

  Ranks.fromJson(Map<String, dynamic> jsonMap) {
    this.queueType = jsonMap['queueType'];
    this.wins = jsonMap['wins'];
    this.rank = jsonMap['rank'];
    this.tier = jsonMap['tier'];
    this.lp = jsonMap['leaguePoints'];
  }
}

//TOP LEVEL RANK
class Rank {
  late List<Ranks> ranks;
  Rank.fromJson(String jsonStr) {
    final _map = jsonDecode(jsonStr);

    //Takes length of list to create ranks
    var list = _map as List;
    ranks = list.map((i) => Ranks.fromJson(i)).toList();
  }
}
