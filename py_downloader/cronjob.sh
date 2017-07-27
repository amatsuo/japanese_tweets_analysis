#!/bin/bash
# cronjob.sh
# move, zip, the file

cd ~/Desktop/temp/ja_kr_tweets/
DATE=$(date +"%Y%m%d%H%M")
mv tw_json.txt backup/tw_json_$DATE.txt
#bzip2 --best -z backup/tw_json_$DATE.txt
