class Session {
  int gameId;
  List<MyTeam> myTeam;
  Session.fromJson(Map<String, dynamic> json) {
    gameId = json['gameId'];
    final info = json['myTeam'];
    myTeam = [];
    for(var i = 0; i < info.length; i++) {
      myTeam.add(MyTeam.fromJson(info[i]));
    }

  }


}

class MyTeam {
  String assignedPosition;
  int cellId;
  int championId;
  int championPickIntent;
  int spell1Id;
  int spell2Id;
  int summonerId;
  int team;
  int wardSkinId;
  String summonerName;

  MyTeam.fromJson(Map<String, dynamic> json) {
    assignedPosition = json['assignedPosition'];
    cellId = json['cellId'];
    championId = json['championId'];
    championPickIntent = json['championPickIntent'];
    spell1Id = json ['spell1Id'];
    spell2Id = json ['spell2Id'];
    summonerId = json['summonerId'];
    team = json['team'];
    wardSkinId = json['wardSkinId'];
  }
}