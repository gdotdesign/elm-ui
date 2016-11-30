#!/bin/bash

wget https://selenium-release.storage.googleapis.com/3.0/selenium-server-standalone-3.0.1.jar
mv selenium-server-standalone-3.0.1.jar spec/vendor/selenium-server.jar
wget https://chromedriver.storage.googleapis.com/2.25/chromedriver_linux64.zip
unzip chromedriver_linux64.zip -d spec/vendor/
rm chromedriver_linux64.zip
