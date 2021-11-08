# kronic_desktop_tool

League Of Legends Desktop Companion

# 10/7/2021 Status
Example usage


https://user-images.githubusercontent.com/18624865/136483694-12ff6a92-ca88-4cf3-95e6-4f546968b5a3.mp4


# Details
The program is built with the flutter framework which uses dart as its programming language. It interfaces with the league of legends client through 
http requests. The start of the prorgam will fetch the required credentials from the running client with some commands and will use those credentials to execute 
requests.




## Data
I have a python script setup to get data from the offiical game api that will get the data of hundreds of games played by highly ranked people in the game
and put the most commonly used rune for each champion inside a json file that is compiled with the program. I have to run this script manually and due to rate 
limiting it takes 10-15 hours to succesfully run.

One of my improvement plans is to turn this into a server based system where the server will refresh the data every so often automatically and the client will be 
able to pull the most up to date data whenever it launches. 

I also want to have a better system then just most commonnly used runes such as by Winrate or other statistics. 

