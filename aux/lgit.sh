#!/bin/bash
noColor='\033[0m'
red='\033[0;31m'
date_format="%Y-%m-%d %H:%M:%S"
export LESS=-R
script_base_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P)

git status > /dev/null 2>&1
if [ $? != 0 ]
then
  echo "Not a git repository (or any of the parent directories)."
  exit 1
fi

topdir=$(git rev-parse --show-toplevel)
files_unformatted=$(git diff --name-only | cat)
files=()
while read file
do
  files+=("$file")
done <<< "$files_unformatted"

untrackedfiles_unformatted=$(git ls-files --others --exclude-standard)
untrackedfiles=()
while read untrackedfile
do
  untrackedfiles+=("$untrackedfile")
done <<< "$untrackedfiles_unformatted"


perform_action_on_file() {
  file=$1
  extra_diff_args=$2
  clear
  date +"$date_format"
  git diff --color $extra_diff_args "$topdir/$file" | $(echo "$script_base_path/diff-highlight/diff-highlight") | less
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

if [ "$files_unformatted" ]
then
  for file in "${files[@]}"
  do
    perform_action_on_file "$file" "--"
  done
fi

if [ "$untrackedfiles_unformatted" ]
then
  clear
  date +"$date_format"
  echo "Untracked files:"
  echo ""
  for untrackedfile in "${untrackedfiles[@]}"
  do
    echo -e "\t${red}$untrackedfile${noColor}"
  done
  echo -e ""
  echo "Do you wish to add them?"
  echo "Actions available to perform:"
  echo -e "  ${red}y${noColor}: Yes"
  echo -e "  ${red}a${noColor}: Yes, all"
  echo -e "  ${red}r${noColor}: No, remove all"
  echo -e "  ${red}s${noColor}: No, skip this"
  echo -e "  ${red}q${noColor}: Quit lgit"
  read -n 1 action
  case $action in
    y)
    for untrackedfile in "${untrackedfiles[@]}"
    do
      perform_action_on_file "$untrackedfile" "--no-index -- /dev/null"
    done
    ;;
    a)
      git ls-files -z -o --exclude-standard | xargs -0 git add
    ;;
    r)
      git clean -df
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
  echo "Actions available to perform:"
  echo -e "  ${red}c${noColor}: Git commit"
  echo -e "  ${red}a${noColor}: Git commit amend"
  echo -e "  ${red}p${noColor}: Git commit & git push"
  echo -e "  ${red}q${noColor}: Quit lgit"
  read -n 1 action
  case $action in
    c)
      git commit
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
