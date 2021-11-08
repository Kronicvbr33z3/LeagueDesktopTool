import pandas as pd
import numpy as np
from pandas.io.parsers import read_csv
from riotwatcher import LolWatcher, ApiError
from riotwatcher.Handlers.RateLimit.BasicRateLimiter import BasicRateLimiter
import itertools
import operator
import json



def most_common(L):
  # get an iterable of (item, iterable) pairs
  SL = sorted((x, i) for i, x in enumerate(L))
  # print 'SL:', SL
  groups = itertools.groupby(SL, key=operator.itemgetter(0))
  # auxiliary function to get "quality" for an item
  def _auxfun(g):
    item, iterable = g
    count = 0
    min_index = len(L)
    for _, where in iterable:
      count += 1
      min_index = min(min_index, where)
    # print 'item %r, count %r, minind %r' % (item, count, min_index)
    return count, -min_index
  # pick the highest-count/earliest item
  return max(groups, key=_auxfun)[0]



watcher = LolWatcher('RGAPI-fe7d0926-6090-4287-a701-7b27bdefc194')

my_region = 'na1'
latest = watcher.data_dragon.versions_for_region(my_region)['n']['champion']
static_rune_list = watcher.data_dragon.runes_reforged(latest, 'en_US')
static_champ_list = watcher.data_dragon.champions(latest, False, 'en_US')

champ_dict = {}
for key in static_champ_list['data']:
    row = static_champ_list['data'][key]
    champ_dict[row['key']] = row['id']

def json_extract(obj, key):
    """Recursively fetch values from nested JSON."""
    arr = []

    def extract(obj, arr, key):
        """Recursively search for values of key in JSON tree."""
        if isinstance(obj, dict):
            for k, v in obj.items():
                if isinstance(v, (dict, list)):
                    extract(v, arr, key)
                elif k == key:
                    arr.append(v)
        elif isinstance(obj, list):
            for item in obj:
                extract(item, arr, key)
        return arr

    values = extract(obj, arr, key)
    return values


def analyze():


  id = json_extract(static_rune_list, 'id')
  key = json_extract(static_rune_list, 'key')

  id.extend([5001,5002,5003,5005,5007,5008])
  key.extend(["Scaling Health", "Armor", "Magic Resist", "Attack Speed", "Scaling Cooldown Reduction", "Adaptive Force"])

  rune_dict = dict(zip(id, key))


  #print(rune_dict)
  df = pd.read_csv("matches.csv")

  #print(static_rune_list)
  for champ in champ_dict:
    try: 
      championName = champ_dict[champ]
      champion_columns = df[df.values== championName]
      perk0 = most_common(champion_columns["perk0"].to_list())
      perk1 = most_common(champion_columns["perk1"].to_list())
      perk2 = most_common(champion_columns["perk2"].to_list())
      perk3 = most_common(champion_columns["perk3"].to_list())
      perk4 = most_common(champion_columns["perk4"].to_list())
      perk5 = most_common(champion_columns["perk5"].to_list())
      stat_perk0 = most_common(champion_columns["statPerk0"].to_list())
      stat_perk1 = most_common(champion_columns["statPerk1"].to_list())
      stat_perk2 = most_common(champion_columns["statPerk2"].to_list())
      primaryPerkStyle = 0
      secondaryPerkStyle = 0

      if str(perk0).startswith('80'):
        primaryPerkStyle = 8000
      elif str(perk0).startswith('81'):
        primaryPerkStyle = 8100
      elif str(perk0).startswith('82'):
        primaryPerkStyle = 8200
      elif str(perk0).startswith('83'):
        primaryPerkStyle = 8300
      elif str(perk0).startswith('84'):
        primaryPerkStyle = 8400
      elif str(perk0).startswith('91'):
        primaryPerkStyle = 8000
      elif str(perk0).startswith('99'):
        primaryPerkStyle = 8100

      if str(perk5).startswith('80'):
        secondaryPerkStyle = 8000
      elif str(perk5).startswith('81'):
        secondaryPerkStyle = 8100
      elif str(perk5).startswith('82'):
        secondaryPerkStyle = 8200
      elif str(perk5).startswith('83'):
        secondaryPerkStyle = 8300
      elif str(perk5).startswith('84'):
        secondaryPerkStyle = 8400
      elif str(perk5).startswith('91'):
        secondaryPerkStyle = 8000

      temp_json = {
        "perk0": perk0, 
        "perk1": perk1, 
        "perk2": perk2, 
        "perk3": perk3, 
        "perk4": perk4, 
        "perk5": perk5, 
        "statPerk0": stat_perk0, 
        "statPerk1": stat_perk1, 
        "statPerk2": stat_perk2,
        "primaryStyleId": primaryPerkStyle,
        "subStyleId": secondaryPerkStyle
      }
      f = open("champions/"+champ+".json", 'w+')
    
      champ_json = json.dump(temp_json, f )
      f.close()

    except:
      print("error")
      #print(rune_dict[most_common(perk0)])
      #print(rune_dict[most_common(perk1)])
      #print(rune_dict[most_common(perk2)])
      #print(rune_dict[most_common(perk3)])
      #print(rune_dict[most_common(perk4)])
      #print(rune_dict[most_common(perk5)])
      #print(rune_dict[most_common(stat_perk0)])
      #print(rune_dict[most_common(stat_perk1)])
      #print(rune_dict[most_common(stat_perk2)])

    #print(champion_columns["perk0"])


analyze()
