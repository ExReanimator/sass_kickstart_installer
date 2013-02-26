#!/bin/bash

[ "$(whoami)" == 'root' ] && ( echo "Please, don't run this script from root user"; exit 1 )

DLT="************************************************************"

alert() {
  echo -e "$DLT\r\n$1\r\n$DLT"
}

alert "Installing dependencies"
sudo apt-get update && sudo apt-get --no-install-recommends install bash curl git-core patch bzip2 build-essential openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev libgdbm-dev ncurses-dev automake libtool bison pkg-config libffi-dev

alert "Ruby version manager (RVM)"
if [[ ! -s $HOME/.rvm/scripts/rvm ]]
then
  curl -L https://get.rvm.io | bash -s stable
fi

if [[ -s $HOME/.rvm/scripts/rvm ]]
then
  source $HOME/.rvm/scripts/rvm
else
  echo "Can not install RVM"
  exit 1
fi

RVMBIN=$HOME/.rvm/bin

alert "Ruby"
$RVMBIN/rvm list | grep "ruby-1.9.3" 
if [ $? -ne 0 ]; 
then
  $RVMBIN/rvm install ruby-1.9.3
else
  echo "Ruby 1.9.3 already installed"
fi

if [[ ! -s /usr/bin/heroku ]]
then
  alert "Heroku support"
  wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh
fi

source $(rvm 1.9.3 do rvm env --path)

$RVMBIN/rvm rubygems current

echo -e "\n\n\nEnvironment ready!\n"

read -p "Do you want to download and install sass_kickstart project? [Y/n]: " STR
if [[ "$STR" == "n" ]]; 
then
  exit 1
else
  read -p "Where project should be located? [`pwd`/sass_kickstart]: " LOC
  if [[ "$LOC" == "" ]]; 
  then
    LOCATION="`pwd`/sass_kickstart"
  else
    LOCATION=${LOC/\~/$HOME}
  fi

  if [[ ! -d $LOCATION ]]; then
    mkdir -p $LOCATION
  fi
  if [[ ! -d $LOCATION ]]; then
    echo "Can't create directory for project"
    exit 1
  else
    git clone git://github.com/ExReanimator/sass_kickstart.git $LOCATION
  fi

  $RVMBIN/rvm rvmrc trust $LOCATION

  cd $LOCATION

  gem install bundler --no-ri --no-rdoc
  bundle install

  echo "Finished. NOW YOU MUST RELOAD TERMINAL SESSION!"
  echo "After that to run server:"
  echo "$ cd $LOCATION"
  echo "$ unicorn"
fi