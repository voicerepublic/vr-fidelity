#!/bin/bash

apt-get -y update
apt-get -y install vorbis-tools sox lame ffmpeg ruby git wget
gem install bundler --no-rdoc --no-ri
bundle install
gem install auphonic --no-rdoc --no-ri
