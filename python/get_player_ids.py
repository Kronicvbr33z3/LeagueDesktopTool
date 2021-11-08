from riotwatcher import LolWatcher, ApiError
import pandas as pd
from riotwatcher.Handlers.RateLimit.BasicRateLimiter import BasicRateLimiter

watcher = LolWatcher('RGAPI-fe7d0926-6090-4287-a701-7b27bdefc194', rate_limiter = BasicRateLimiter())

my_region = 'na1'
match_region = 'americas'

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
    while count < 30:
        if count == 0:
            me = watcher.summoner.by_name(my_region, 'GeneralSn1per')
        else:
            try:
                me = watcher.summoner.by_account(my_region, play_ids[count])
            except Exception:
                count += 1
                pass
        my_matches = watcher.match.matchlist_by_puuid(match_region, me['puuid'], type="ranked")
    #last_match = my_matches['matches'][0]
    # match_detail = watcher.match.by_id(my_region, last_match['gameId'])

        for match in my_matches:
            print("Match")
            match_detail = watcher.match.by_id(match_region, match)
            
            for row in match_detail['metadata']['participants']:
                play_ids.append(row);

        count += 1
            
            
    remove_dup(play_ids)

    df = pd.DataFrame(play_ids)

    a = open("player_ids.txt", "a")
    for play_id in play_ids:
        if play_id in already_anaylzed:
            pass
        else:
            a.write(play_id + '\n')

    a.close()
    print(df)

 
get_ids()