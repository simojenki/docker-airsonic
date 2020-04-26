FROM ubuntu:18.04

MAINTAINER simojenki

ARG BRANCH="release-10.6-sonos"

RUN apt-get update && \
    apt-get install -y \
        locales \
        maven \
        git \
        openjdk-8-jdk-headless

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN git clone -b "${BRANCH}" https://github.com/simojenki/airsonic.git

WORKDIR /airsonic

RUN mvn test package

FROM linuxserver/airsonic:latest

RUN apt-get update && \
    apt-get install -y \
        sox

COPY downsample-flac /usr/bin/downsample-flac

COPY --from=0 /airsonic/airsonic-main/target/airsonic.war /app/airsonic/airsonic.war

