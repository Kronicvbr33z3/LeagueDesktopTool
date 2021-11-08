from riotwatcher import LolWatcher, ApiError
import pandas as pd

watcher = LolWatcher('RGAPI-7c9cfb49-1ffd-478e-848d-6d64d02ba6c2')

my_region = 'na1'

latest = watcher.data_dragon.versions_for_region(my_region)['n']['champion']
#Static Champion Info
static_champ_list = watcher.data_dragon.champions(latest, False, 'en_US')

def remove_dup(a):
   i = 0
   while i < len(a):
      j = i + 1
      while j < len(a):
         if a[i] == a[j]:
            del a[j]
         else:
            j += 1
      i += 1

def get_match_data():

    # champ static list data to dict for looking up
    champ_dict = {}
    for key in static_champ_list['data']:
        row = static_champ_list['data'][key]
        champ_dict[row['key']] = row['id']

    f = open("player_ids.txt", "r")
    players_to_analyze = []
    for line in f:
        stripped_line = line.strip()
        players_to_analyze.append(stripped_line)
    f.close()

    #Open Already Analyzed Matches to Make sure Nothing is Duplicated
    f = open("match_ids.txt", "r")
    already_analyzed = []
    for line in f:
        stripped_line = line.strip()
        already_analyzed.append(int(stripped_line))
    f.close()

    matches = []
    match_ids = []
    for player in players_to_analyze:
        try:
            print("retrieving match list")
            match_list = watcher.match.matchlist_by_puuid('americas', player, count=5, type="ranked")
            for match in match_list:
                match_detail = watcher.match.by_id('americas', match)
                print(match_detail['info']['gameMode'])
                if match_detail['info']['gameMode'] == "CLASSIC":
                    match_ids.append(match)
                    matches.append(match_detail)
                    print(match_ids)
        except Exception as e:
            print(e)

    #Remove Duplicates in data collection        
    remove_dup(match_ids)
    remove_dup(matches)

    participants = []

    count = 0
    for match_id in match_ids:
        for already in already_analyzed:
            if match_id == already_analyzed:
                matches.remove(count)
                print("removed dup")
        count += 1

    matches_analyzed = 0
    for match in matches:
        for row in match['info']['participants']:
            participants_row = {}
            participants_row['champion'] = row['championId']
            participants_row['spell1'] = row['summoner1Id']
            participants_row['spell2'] = row['summoner2Id']
            participants_row['win'] = row['win']
            participants_row['kills'] = row['kills']
            participants_row['deaths'] = row['deaths']
            participants_row['assists'] = row['assists']
            participants_row['totalDamageDealt'] = row['totalDamageDealt']
            participants_row['item0'] = row['item0']
            participants_row['item1'] = row['item1']
            participants_row['item2'] = row['item2']
            participants_row['item3'] = row['item3']
            participants_row['item4'] = row['item4']
            participants_row['item5'] = row['item5']
            participants_row['item6'] = row['item6']
            participants_row['perk0'] = row['perks']['styles'][0]['selections'][0]['perk']
            participants_row['perk1'] = row['perks']['styles'][0]['selections'][1]['perk']
            participants_row['perk2'] = row['perks']['styles'][0]['selections'][2]['perk']
            participants_row['perk3'] = row['perks']['styles'][0]['selections'][3]['perk']
            participants_row['perk4'] = row['perks']['styles'][1]['selections'][0]['perk']
            participants_row['perk5'] = row['perks']['styles'][1]['selections'][1]['perk']
            participants_row['statPerk0'] = row['perks']['statPerks']['offense'] 
            participants_row['statPerk1'] = row['perks']['statPerks']['flex']
            participants_row['statPerk2'] = row['perks']['statPerks']['defense']


            participants.append(participants_row)
        matches_analyzed += 1
    

    for row in participants:
        #print(str(row['champion']) + ' ' + champ_dict[str(row['champion'])])
        row['championName'] = champ_dict[str(row['champion'])]

    a = open("match_ids.txt", "a")
    for id in match_ids:
        a.write(str(id) + '\n')

    df = pd.DataFrame(participants)


    df.to_csv("matches.csv")

    print("Matches analyzed: " + str(matches_analyzed))
get_match_data()