from riotwatcher import LolWatcher, ApiError
import pandas as pd
from riotwatcher.Handlers.RateLimit.BasicRateLimiter import BasicRateLimiter

watcher = LolWatcher('RGAPI-88da60fc-f70c-446c-9bde-9217be3db585', rate_limiter = BasicRateLimiter())

my_region = 'na1'

#me = watcher.summoner.by_name(my_region, 'Doublelift')

#my_matches = watcher.match.matchlist_by_account(my_region, me['accountId'])

#last_match = my_matches['matches'][0]
#match_detail = watcher.match.by_id(my_region, last_match['gameId'])

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

def get_ids():
        
    f = open("player_ids.txt", "r")
    already_anaylzed = []
    for line in f:
        stripped_line = line.strip()
        already_anaylzed.append(stripped_line)
    f.close()

    play_ids = []
    count = 0
    while count < 2:
        if count == 0:
            me = watcher.summoner.by_name(my_region, 'Doublelift')
        else:
            try:
                me = watcher.summoner.by_account(my_region, play_ids[count]['accountId'])
            except Exception:
                count += 1
                pass
        my_matches = watcher.match.matchlist_by_account(my_region, me['accountId'])['matches']
    #last_match = my_matches['matches'][0]
    # match_detail = watcher.match.by_id(my_region, last_match['gameId'])

        for match in my_matches:
            print("Match")
            match_detail = watcher.match.by_id(my_region, match['gameId'])
            participants = []
            for row in match_detail['participantIdentities']:
                participants_row = {}
                participants_row['accountId'] = row['player']["accountId"]
                participants.append(participants_row)
            for partcipant in participants:
                play_ids.append(partcipant)

        count += 1
            
            
    remove_dup(play_ids)

    df = pd.DataFrame(play_ids)

    a = open("player_ids.txt", "a")
    for play_id in play_ids:
        if play_id['accountId'] in already_anaylzed:
            pass
        else:
            a.write(play_id['accountId'] + '\n')

    a.close()
    print(df)

 
