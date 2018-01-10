#!/usr/bin/env bash

# Add key and repo MongoDB. Update repo
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update

# Install the necessary software
sudo apt install -y ruby-full ruby-bundler build-essential mongodb-org

# Enable autostart and start service
systemctl enable mongod
systemctl start mongod

# Download app, install dependencies and start app
cd /home/appuser
git clone https://github.com/Otus-DevOps-2017-11/reddit.git
cd reddit && bundle install
puma -d
