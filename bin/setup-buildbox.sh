#!/usr/bin/env bash

set -e

[ -z "$HOME" ] && echo "set HOME environment variable" && exit 1;

export TEMP="$HOME/Temp"


#----------------Creating Temp direcotry-----------------------------
if [ ! -d $TEMP ];
then
  echo "-- Creating directory $TEMP"
  mkdir -p "$TEMP"
fi
 
#----------------Creating workarea direcotry-----------------------------
if [ ! -d "$HOME/workarea" ];
then
echo "-- Creating directory workarea"
  mkdir -p "$HOME/workarea"
fi


sudo chown -hR `id -u -n`:`id -g -n` $TEMP $HOME/workarea

#sudo -i chef-solo -c  ~/workarea/chef/cookbooks/snapfish/solo.rb -j ~/workarea/chef/cookbooks/snapfish/gatadi-home.json

source ~/.bashrc

p4 client -i < ~/snapfish/p4client

