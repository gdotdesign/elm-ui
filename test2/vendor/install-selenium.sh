#!/bin/bash

wget http://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.1.jar
mv selenium-server-standalone-2.53.1.jar test2/vendor/selenium-server.jar
wget http://chromedriver.storage.googleapis.com/2.23/chromedriver_linux64.zip
unzip chromedriver_linux64.zip -d test2/vendor/
rm chromedriver_linux64.zip
