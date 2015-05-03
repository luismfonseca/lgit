#!/bin/bash

# Get the script's true location
# Copied from: stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in#answer-246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

( exec $DIR/aux/selfupdate.sh "$DIR" )
( exec $DIR/aux/lgit.sh )
