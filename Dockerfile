# Examples on how to build and run this docker container
#
#     docker build -t branch14/fidelity .
#     docker run -v /home/phil/src/vr/fidelity/uat:/audio branch14/fidelity
#
# This starts the docker container with an interactive bash shell
#
#     docker run -v /home/phil/src/vr/fidelity/uat:/audio -i branch14/fidelity:latest /bin/bash

FROM debian:jessie-backports

MAINTAINER phil@voicerepublic.com

ADD . /fidelity

RUN apt-get -y update \
    && apt-get -y install vorbis-tools sox lame ffmpeg ruby git wget \
    && gem install bundler --no-rdoc --no-ri

RUN (cd fidelity && bundle install) \
    && gem install auphonic --no-rdoc --no-ri \
    && mkdir /audio

VOLUME ["/audio"]

WORKDIR /fidelity/bin

CMD ./fidelity run /audio/manifest.yml
