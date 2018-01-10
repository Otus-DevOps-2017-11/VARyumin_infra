#!/usr/bin/env bash

#Update repo
sudo apt update

#Install ruby and bundler
sudo apt install -y ruby-full ruby-bundler build-essential

# Checked install soft
ruby -v > /dev/null 2>&1
if [ $? -ne 0 ];
then
        echo "Something went wrong, Ruby is not installed"
        exit 1
else
        echo "Сhecked Ruby ... OK!"
        exit 0
fi

bundle -v > /dev/null 2>&1
if [ $? -ne 0 ];
then
        echo "Something went wrong, Bundle is not installed"
        exit 1
else
        echo "Сhecked Bundle ... OK!"
        exit 0
fi
