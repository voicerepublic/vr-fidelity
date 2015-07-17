# Examples on how to build and run this docker container
#
#     docker build -t branch14/fidelity .
#     docker run -v /home/phil/src/vr/fidelity/uat:/audio branch14/fidelity
#
# This starts the docker container with an interactive bash shell
#
#     docker run -v /home/phil/src/vr/fidelity/uat:/audio -i branch14/fidelity:latest /bin/bash

FROM ruby:2.1

MAINTAINER phil@voicerepublic.com

ADD . /fidelity

RUN apt-get -y update \
    && apt-get -y install libav-tools vorbis-tools sox lame \
    && (cd fidelity && bundle install) \
    && gem install auphonic \
    && mkdir /audio

VOLUME ["/audio"]

WORKDIR /fidelity/bin

CMD ./fidelity run /audio/manifest.yml
