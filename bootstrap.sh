#!/usr/bin/env bash
sudo apt-get install -q git rake
git clone https://github.com/jeversmann/maximum-awesome-linux.git ~/.maximum-awesome-linux
cd ~/.maximum-awesome-linux

rake
