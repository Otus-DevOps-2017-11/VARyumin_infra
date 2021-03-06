#!/usr/bin/env bash

# Added key
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

# Added repo Mongodb 3.2
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'

# Update repo
sudo apt update

# Install mongod
sudo apt install -y mongodb-org

# Enable autostart and start service
sudo systemctl enable mongod
sudo systemctl start mongod
