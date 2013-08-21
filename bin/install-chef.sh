#!/bin/sh

set -e

[ -z "$HOME" ] && echo "set HOME environment variable" && exit 1;

export TEMP="$HOME/Temp"


#----------------Creating Temp direcotry-----------------------------
if [ ! -d $TEMP ];
then
  echo "-- Creating directory $TEMP"
  mkdir -p "$TEMP"
  sudo chown -R `id -u -n`:`id -g -n` $TEMP
fi
 
#----------------Running update and upgrade -------------------------
sudo apt-get -y update
sudo apt-get -y upgrade


#----------------Installing build-essential & lib packages-----------
echo "-- Installing build-essential & lib Packages"
sudo apt-get -y install build-essential zlib1g-dev libssl-dev libreadline6-dev libxml2-dev libxslt-dev libyaml-dev libncurses-dev libgdbm-dev tk-dev zlib1g-dev libssl-dev libffi-dev libssl1.0.0 git-core curl


#---------------Installing rbenv, ruby-build-------------------
CURRENT=`pwd`

[ ! -z $RBENV_ROOT ] || RBENV_ROOT=/usr/local/rbenv
[ ! -z $RBENV_VERSION ] || RBENV_VERSION=1.9.2-p290

if [ -d $RBENV_ROOT ]; then
  echo rbenv is already installed.
  #cd $RBENV_ROOT
  #sudo git pull
  #cd plugins/ruby-build
  #sudo git pull
else
  echo Install rbenv to $RBENV_ROOT with install $RBENV_VERSION...
  sudo mkdir -p $RBENV_ROOT
  cd $RBENV_ROOT
 
  sudo git clone https://github.com/sstephenson/rbenv.git .
  sudo mkdir -p plugins
  sudo git clone https://github.com/sstephenson/ruby-build.git plugins/ruby-build
  
  
#----------------Creating Z99-rbenv.sh ----------------------------------
if [ ! -f /etc/profile.d/Z99-rbenv.sh ]; then
  echo Generating /etc/profile.d/Z99-rbenv.sh...
  sudo echo "RBENV_ROOT=$RBENV_ROOT" > /etc/profile.d/Z99-rbenv.sh
  sudo echo 'if [ -d $RBENV_ROOT ]; then' >> /etc/profile.d/Z99-rbenv.sh 
  sudo echo '  export RBENV_ROOT' >> /etc/profile.d/Z99-rbenv.sh
  sudo echo '  PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/Z99-rbenv.sh
  sudo echo '  eval "$(rbenv init -)"' >> /etc/profile.d/Z99-rbenv.sh
  sudo echo 'fi' >> /etc/profile.d/Z99-rbenv.sh
  sudo chmod a+x /etc/profile.d/Z99-rbenv.sh
fi

fi

cd $CURRENT
export RBENV_ROOT
export RBENV_VERSION

if [ `/usr/local/rbenv/shims/ruby -v | grep -c -i "ruby"` -lt 1 ] ; then
  $RBENV_ROOT/bin/rbenv install -v $RBENV_VERSION
  $RBENV_ROOT/bin/rbenv rehash
    $RBENV_ROOT/bin/rbenv global $RBENV_VERSION
else
  echo ruby `/usr/local/rbenv/shims/ruby -v` is already installed
fi


#----------------Updating ruby gems-----------------------------------
echo "-- Updating ruby gems"
sudo -i $RBENV_ROOT/bin/rbenv exec gem update --no-rdoc --no-ri


#----------------installing bundler ----------------------------------
if [ `$RBENV_ROOT/bin/rbenv exec gem list | grep -c -i "bundler"` -lt 1 ] ; then
  echo Install bundler...
  sudo -i $RBENV_ROOT/bin/rbenv exec gem install bundler --no-rdoc --no-ri
fi


#----------------installing ohai ----------------------------------
if [ `$RBENV_ROOT/bin/rbenv exec gem list | grep -c -i "ohai"` -gt 0 ]
then 
   echo "-- ohai gem is already installed"
else
   echo "-- Installing gem ohai"
   sudo -i $RBENV_ROOT/bin/rbenv exec gem install ohai --no-rdoc --no-ri 
fi



#----------------installing chef ----------------------------------
if [ `$RBENV_ROOT/bin/rbenv exec gem list | grep -c -i "chef"` -gt 0 ]
then 
   echo "-- chef gem is already installed"
else
   echo "-- Installing gem chef"
   sudo -i $RBENV_ROOT/bin/rbenv exec gem install chef --no-rdoc --no-ri 
fi


#----------------installing knife-vsphere ----------------------------------
if [ `$RBENV_ROOT/bin/rbenv exec gem list | grep -c -i "knife-vsphere"` -gt 0 ]
then 
   echo "-- knife-vsphere gem is already installed"
else
   echo "-- Installing gem knife-vsphere"
   sudo -i $RBENV_ROOT/bin/rbenv exec gem install knife-vsphere --no-ri --no-rdoc
fi


#----------------installing ruby-shadow ----------------------------------
if [ `$RBENV_ROOT/bin/rbenv exec gem list | grep -c -i "ruby-shadow"` -gt 0 ]
then 
   echo "-- ruby-shadow gem is already installed"
else
   echo "-- Installing gem ruby-shadow"
   sudo -i $RBENV_ROOT/bin/rbenv exec gem install ruby-shadow --no-ri --no-rdoc
fi




#----------------Creating workarea direcotry-----------------------------
if [ ! -d "$HOME/workarea" ];
then
echo "-- Creating directory workarea"
  mkdir -p "$HOME/workarea"  
fi

#-----------------Cloning chef snapfish devox setup cookbook ------------------
if [ -d "$HOME/workarea/chef" ]
then
echo "-- chef repo is already cloned"
else
cd ~/workarea
   git clone https://github.com/sqat/chef.git   
fi

#-----------------Cloning snapfish softwares/binaires ------------------
if [ -d "$HOME/workarea/softwares" ]
then
echo "-- softwares repo is already cloned"
else
cd ~/workarea
   git clone https://github.com/gatadi/softwares.git
fi

sudo chown -R `id -u -n`:`id -g -n` $HOME/workarea



echo "INSTALLATION SUCCESSFUL"
echo "............................---------------------------------------"
echo ""
echo ""
echo ""
echo ""


