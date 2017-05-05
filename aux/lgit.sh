#!/bin/bash
noColor='\033[0m'
red='\033[0;31m'
date_format="%Y-%m-%d %H:%M:%S"
export LESS=-R

git status > /dev/null 2>&1
if [ $? != 0 ]
then
  echo "Not a git repository (or any of the parent directories)."
  exit 1
fi

topdir=$(git rev-parse --show-toplevel)
files=$(git diff --name-only | cat)
untrackedfiles=$(git ls-files --others --exclude-standard)

perform_action_on_file() {
  file=$1
  extra_diff_args=$2
  clear
  date +"$date_format"
  git diff $extra_diff_args "$topdir/$file"
  git status
  echo "Actions to available perform:"
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
    git add "$topdir/$file"
  ;;
  i)
    clear
    git add --patch "$topdir/$file"
  ;;
  s)
  ;;
  r)
    git checkout -- "$topdir/$file"
  ;;
  d)
    git checkout --patch "$topdir/$file"
  ;;
  q)
    exit
  ;;
  *)
    echo "Unkown command. Ignoring..."
    sleep 0.5
  ;;
  esac
}

for file in $files
do
  perform_action_on_file "$file" "--"
done

if [ "$untrackedfiles" ]
then
  clear
  date +"$date_format"
  echo "Untracked files:"
  echo ""
  for untrackedfile in $untrackedfiles
  do
    echo -e "\t${red}$untrackedfile${noColor}"
  done
  echo -e ""
  echo "Do you which to add them?"
  echo "Actions to available perfom:"
  echo -e "  ${red}y${noColor}: Yes"
  echo -e "  ${red}a${noColor}: Yes, all"
  echo -e "  ${red}r${noColor}: No, remove all"
  echo -e "  ${red}s${noColor}: No, skip this"
  echo -e "  ${red}q${noColor}: Quit lgit"
  read -n 1 action
  case $action in
    y)
    for untrackedfile in $untrackedfiles
    do
      perform_action_on_file "$untrackedfile" "--no-index -- /dev/null"
    done
    ;;
    a)
      git ls-files -z -o --exclude-standard | xargs -0 git add
    ;;
    r)
      git clean -dfx
    ;;
    s)
    ;;
    q)
      exit
    ;;
    *)
      echo "Unkown command. Ignoring..."
      sleep 0.5
    ;;
  esac
fi

if [ "$(git diff --name-only --cached | cat)" ]
then
  clear
  date +"$date_format"
  git status
  echo "Actions to available perfom:"
  echo -e "  ${red}c${noColor}: Git commit"
  echo -e "  ${red}a${noColor}: Git commit amend"
  echo -e "  ${red}p${noColor}: Git commit & git push"
  echo -e "  ${red}q${noColor}: Quit lgit"
  read -n 1 action
  case $action in
    c)
      echo ". Commit message: "
      read message
      git commit -m "${message}"
    ;;
    a)
      echo " Commit amend"
      git commit --amend
    ;;
    p)
      echo ". Commit message: "
      read message
      git commit -m "${message}"
      git push
    ;;
    q)
    ;;
    *)
      echo "Unkown command. Ignoring..."
      sleep 0.5
    ;;
  esac
else
  echo "Nothing to commit..."
fi
