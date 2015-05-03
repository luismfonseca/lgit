#!/bin/bash
noColor='\033[0m'
red='\033[0;31m'

DIR=$1
last_check_file=$DIR/aux/.last_check

update_threshold_days=7
today=$(date +"%Y%m%d")
version=$(cd "$DIR" && date -j -f "%Y-%m-%d %T %z" "$(git show -s --format=%ci head | cat)" +"%Y%m%d")
next_check=$(date -j -v +"$update_threshold_days"d -f "%Y%m%d" "$version" +"%Y%m%d")

if [ -f "$last_check_file" ]
then
  last_check=$(cat "$last_check_file")
  rm "$last_check_file" > /dev/null 2>&1
else
  last_check=$today
fi
echo "$today" > "$last_check_file"
next_check2=$(date -j -v +"$update_threshold_days"d -f "%Y%m%d" "$last_check" +"%Y%m%d")

if [ "$today" -ge "$next_check" ] || [ "$today" -ge "$next_check2" ]
then
  echo -e "Updating ${red}lgit${noColor}..."
  cd "$DIR" && git pull > /dev/null 2>&1

  latest_version=$(git show -s --format=%ci head | cat | date +"%Y%m%d")
  if [ "$latest_version" -eq "$version" ]
  then
    echo "Already up-to-date."
  else
    echo -e "${red}lgit${noColor} was successfully updated."
  fi
  sleep 0.5
fi
