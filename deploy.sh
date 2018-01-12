#!/usr/bin/env bash

# Git clone app
git clone https://github.com/Otus-DevOps-2017-11/reddit.git

#Install app
cd reddit && bundle install

#Run server
puma -d
