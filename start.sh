#!/bin/bash
# 
# start automatically from .bash_profile with
# source $HOME/securiPi/start.sh
if [ "`ps aux | grep [r]vmsudo.*securiPi`" == '' ]; then 
  cd ~/securiPi
  if [ "$1" == "-f" ]; then
    echo starting securiPi in foreground
    rvmsudo ruby $HOME/securiPi/watcher.rb
  else
    echo starting securiPi in background
    echo you can see the log: tail -f $HOME/securiPi/start.log
    echo you can stop with: $HOME/securiPi/stop.sh
    rvmsudo ruby $HOME/securiPi/watcher.rb >> $HOME/securiPi/start.log &
    # echo $! > $HOME/securiPi/start.pid this does not work since it has different PID
  fi
  cd -
else
  echo secipiPi already started `cat $HOME/securiPi/start.pid`
  echo you can stop with: $HOME/securiPi/stop.sh
fi
