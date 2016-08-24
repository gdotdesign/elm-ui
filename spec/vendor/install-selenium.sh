#!/bin/bash

wget http://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.1.jar
mv selenium-server-standalone-2.53.1.jar spec/vendor/selenium-server.jar
wget http://chromedriver.storage.googleapis.com/2.23/chromedriver_linux64.zip
unzip chromedriver_linux64.zip -d spec/vendor/
rm chromedriver_linux64.zip
