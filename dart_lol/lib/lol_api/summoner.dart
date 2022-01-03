library dart_lol;

import 'dart:convert';

import 'package:http/http.dart';

//List of Champs with ID's
Map champs = {
  'Qiyana': '246',
  'Wukong': '62',
  'Jax': '24',
  'Fiddlesticks': '9',
  'Yuumi': '350',
  'Shaco': '35',
  'Warwick': '19',
  'Xayah': '498',
  'Sylas': '517',
  'Nidalee': '76',
  'Zyra': '143',
  'Kled': '240',
  'Brand': '63',
  'Rammus': '33',
  'Illaoi': '420',
  'Corki': '42',
  'Braum': '201',
  'Sejuani': '113',
  'Tryndamere': '23',
  'Miss Fortune': '21',
  'Yorick': '83',
  'Xerath': '101',
  'Sivir': '15',
  'Riven': '92',
  'Orianna': '61',
  'Gangplank': '41',
  'Sett': '875',
  'Malphite': '54',
  'Poppy': '78',
  'Karthus': '30',
  'Jayce': '126',
  'Diana': '131',
  'Trundle': '48',
  'Graves': '104',
  'Zoe': '142',
  'Gnar': '150',
  'Lux': '99',
  'Shyvana': '102',
  'Renekton': '58',
  'Lissandra': '127',
  'Fiora': '114',
  'Jinx': '222',
  'Kalista': '429',
  'Fizz': '105',
  'Kassadin': '38',
  'Sona': '37',
  'Irelia': '39',
  'Viktor': '112',
  'Rakan': '497',
  'Kindred': '203',
  'Cassiopeia': '69',
  'Maokai': '57',
  'Ornn': '516',
  'Thresh': '412',
  'Kayle': '10',
  'Hecarim': '120',
  'Nunu': '20',
  'Khazix': '121',
  'Olaf': '2',
  'Ziggs': '115',
  'Syndra': '134',
  'Dr Mundo': '36',
  'Karma': '43',
  'Annie': '1',
  'Akali': '84',
  'Leona': '89',
  'Yasuo': '157',
  'Kennen': '85',
  'Rengar': '107',
  'Ryze': '13',
  'Shen': '98',
  'Zac': '154',
  'Pantheon': '80',
  'Neeko': '518',
  'Bard': '432',
  'Sion': '14',
  'Vayne': '67',
  'Nasus': '75',
  'Kayn': '141',
  'Twisted Fate': '4',
  'Chogath': '31',
  'Udyr': '77',
  'Lucian': '236',
  'Ivern': '427',
  'Volibear': '106',
  'Caitlyn': '51',
  'Darius': '122',
  'Nocturne': '56',
  'Zilean': '26',
  'Azir': '268',
  'Rumble': '68',
  'Morgana': '25',
  'Skarner': '72',
  'Teemo': '17',
  'Urgot': '6',
  'Amumu': '32',
  'Galio': '3',
  'Heimerdinger': '74',
  'Anivia': '34',
  'Ashe': '22',
  'Velkoz': '161',
  'Singed': '27',
  'Taliyah': '163',
  'Evelynn': '28',
  'Varus': '110',
  'Twitch': '29',
  'Garen': '86',
  'Blitzcrank': '53',
  'Master Yi': '11',
  'Pyke': '555',
  'Elise': '60',
  'Alistar': '12',
  'Katarina': '55',
  'Ekko': '245',
  'Mordekaiser': '82',
  'Lulu': '117',
  'Camille': '164',
  'Aatrox': '266',
  'Draven': '119',
  'Tahm Kench': '223',
  'Talon': '91',
  'Xin Zhao': '5',
  'Swain': '50',
  'Aurelion Sol': '136',
  'Lee Sin': '64',
  'Aphelios': '523',
  'Ahri': '103',
  'Malzahar': '90',
  'Kaisa': '145',
  'Tristana': '18',
  'RekSai': '421',
  'Vladimir': '8',
  'Jarvan IV': '59',
  'Nami': '267',
  'Jhin': '202',
  'Soraka': '16',
  'Veigar': '45',
  'Janna': '40',
  'Nautilus': '111',
  'Senna': '235',
  'Gragas': '79',
  'Zed': '238',
  'Vi': '254',
  'KogMaw': '96',
  'Taric': '44',
  'Quinn': '133',
  'Leblanc': '7',
  'Ezreal': '81',
  'Viego': '234',
  'Samira': '360',
  'Lillia': '876',
  'Seraphine': '147',
  'Yone': '777',
  'Rell': '526'
};
Map queues = {
  420: "Solo/Duo",
  440: "Flex",
  0: "Custom",
  76: "URF",
  400: "Normal",
  430: "Blind",
  450: "ARAM",
  830: "Bots",
  840: "Bots",
  850: "Bots",
  900: "URF",
};

final String apiKey = 'RGAPI-442337c9-dfd8-48b6-90f1-2fdbbe6411c0';

class Summoner {
  static final String apiKey = 'RGAPI-442337c9-dfd8-48b6-90f1-2fdbbe6411c0';
  String summonerName = "";
  int accountId = 0;
  int profileIconId = 0;
  String puuid = "";
  int summonerLevel = 0;
  int lcuSummonerApi = 0;
  //MatchHistory matches;
  late Rank rank;
  late String summonerId;
  Summoner(this.accountId, this.summonerName, this.profileIconId, this.puuid,
      this.summonerLevel, this.lcuSummonerApi);

  Summoner.fromJson(Map<String, dynamic> json) {
    summonerName = json['displayName'];
  }

  Future<void> getAccountId() async {
    // make the request
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
