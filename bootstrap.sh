#!/bin/bash
pushd /vagrant

echo -e "\ninstalling required software packages...\n"
zypper -q -n install update-alternatives ruby-devel make gcc gcc-c++ \
             libxml2-devel libxslt-devel nodejs screen mariadb \
             libmysqld-devel sqlite3-devel imagemagick

echo -e "\ndisabling versioned gem binary names...\n"
echo 'install: --no-format-executable' >> /etc/gemrc

echo -e "\ninstalling bundler...\n"
gem install bundler

echo -e "\ninstalling your bundle...\n"
su - vagrant -c "cd /vagrant/; bundle install --quiet"

# Configure the app if it isn't
if [ ! -f /vagrant/config/config.yml ] && [ -f /vagrant/config/config.yml.example ]; then
  echo "Configuring your app in config/options.yml..." 
  cp config/config.yml.example config/config.yml
else
  echo -e "\n\nWARNING: You have already configured your app in config/options.yml." 
  echo -e "WARNING: Please make sure this configuration works in this vagrant box!\n\n" 
fi 

# Configure the app if it isn't
if [ ! -f /vagrant/config/secrets.yml ] && [ -f /vagrant/config/secrets.yml.example ]; then
  echo "Configuring your secrets in config/secrets.yml..."
  cp config/secrets.yml.example config/secrets.yml
else
  echo -e "\n\nWARNING: You have already configured your secrets in config/secrets.yml."
  echo -e "WARNING: Please make sure this configuration works in this vagrant box!\n\n"
fi

# Configure the database if it isn't
if [ ! -f /vagrant/config/database.yml ] && [ -f /vagrant/config/database.yml.example ]; then
  echo -e "\nSetting up your database from config/database.yml...\n"
  cp config/database.yml.example config/database.yml
  if [ ! -f db/development.sqlite3 ] && [ ! -f db/test.sqlite3 ]; then
    bundle exec rake db:setup
  else
    echo -e "\n\nWARNING: You have already have a development/test database."
    echo -e "WARNING: Please make sure this database works in this vagrant box!\n\n"
  fi 
else
  echo -e "\nnWARNING: You have already configured your database in config/database.yml." 
  echo -e "WARNING: Please make sure this configuration works in this vagrant box!\n\n" 
fi

echo -e "\nProvisioning of your OSEM rails app done!"
echo -e "To start your development OSEM run: vagrant exec rails server -b 0.0.0.0\n"
