from riotwatcher import LolWatcher, ApiError
import pandas as pd

watcher = LolWatcher('RGAPI-88da60fc-f70c-446c-9bde-9217be3db585')

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
            match_list = watcher.match.matchlist_by_account(my_region, player, end_index=5)['matches']
            for match in match_list:
                match_detail = watcher.match.by_id(my_region, match['gameId'])
                if match_detail['gameMode'] == "CLASSIC":
                    match_ids.append(match['gameId'])
                    matches.append(match_detail)
        except Exception:
            print("User Not Found")

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
        for row in match['participants']:
            participants_row = {}
            participants_row['champion'] = row['championId']
            participants_row['spell1'] = row['spell1Id']
            participants_row['spell2'] = row['spell2Id']
            participants_row['win'] = row['stats']['win']
            participants_row['kills'] = row['stats']['kills']
            participants_row['deaths'] = row['stats']['deaths']
            participants_row['assists'] = row['stats']['assists']
            participants_row['totalDamageDealt'] = row['stats']['totalDamageDealt']
            participants_row['item0'] = row['stats']['item0']
            participants_row['item1'] = row['stats']['item1']
            participants_row['item2'] = row['stats']['item2']
            participants_row['item3'] = row['stats']['item3']
            participants_row['item4'] = row['stats']['item4']
            participants_row['item5'] = row['stats']['item5']
            participants_row['item6'] = row['stats']['item6']
            participants_row['perk0'] = row['stats']['perk0']
            participants_row['perk1'] = row['stats']['perk1']
            participants_row['perk2'] = row['stats']['perk2']
            participants_row['perk3'] = row['stats']['perk3']
            participants_row['perk4'] = row['stats']['perk4']
            participants_row['perk5'] = row['stats']['perk5']
            participants_row['statPerk0'] = row['stats']['statPerk0']
            participants_row['statPerk1'] = row['stats']['statPerk1']
            participants_row['statPerk2'] = row['stats']['statPerk2'] 


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
