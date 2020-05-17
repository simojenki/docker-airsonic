FROM ubuntu:18.04

MAINTAINER simojenki

ARG DOCKER_TAG=latest

RUN apt-get update && \
    apt-get install -y \
        locales \
        maven \
        git \
        openjdk-11-jdk-headless

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN git clone -b $(if [ "${DOCKER_TAG}" = "latest" ]; then echo "master-sonos"; else echo "release-${DOCKER_TAG}-sonos"; fi) https://github.com/simojenki/airsonic.git

WORKDIR /airsonic

RUN git status | grep "On branch" && \
    mvn test package

FROM linuxserver/airsonic:latest

RUN apt-get update && \
    apt-get install -y \
        sox

COPY downsample-flac /usr/bin/downsample-flac

COPY --from=0 /airsonic/airsonic-main/target/airsonic.war /app/airsonic/airsonic.war

