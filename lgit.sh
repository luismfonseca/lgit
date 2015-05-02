#!/bin/bash
noColor='\033[0m'
red='\033[0;31m'

$(git status > /dev/null 2>&1)
if [ $? != 0 ]
then
  echo "Not a git repository (or any of the parent directories)"
  exit 1
fi

topdir=$(git rev-parse --show-toplevel)
files=$(git diff --name-only | cat)

for file in $files
do
  clear
  date
  git diff -- $topdir/$file
  git status
  echo "Actions to available perfom:"
  echo -e "  ${red}a${noColor}: Git Add File"
  echo -e "  ${red}i${noColor}: Git Add File Interactive"
  echo -e "  ${red}s${noColor}: Skip this File"
  echo -e "  ${red}r${noColor}: Revert this File"
  echo -e "  ${red}d${noColor}: Revert this File Interactive"
  echo -e "  ${red}q${noColor}: Quit lgit"
  read -n 1 action
  case $action in
  a)
    clear
    git add $topdir/$file
    added=true
  ;;
  i)
    clear
    git add --patch $topdir/$file
    added=true
  ;;
  s)
  ;;
  r)
    git checkout -- $topdir/$file
  ;;
  d)
    git checkout --patch $topdir/$file
  ;;
  q)
    exit
  ;;
  *)
    echo "Unkown command. Ignoring..."
    sleep 0.5
  ;;
  esac
done
if [ $added ]
then
  clear
  date
  git status
  echo "Actions to available perfom:"
  echo -e "  ${red}c${noColor}: Git commit"
  echo -e "  ${red}p${noColor}: Git commit & git push"
  echo -e "  ${red}q${noColor}: Quit lgit"
  read -n 1 action
  case $action in
    c)
      echo ". Commit message: "
      read message
      git commit -m "${message}"
    ;;
    p)
      echo ". Commit message: "
      read message
      git commit -m "${message}"
      git push
    ;;
    q)
    ;;
  esac
else
  echo "Nothing to commit..."
fi
