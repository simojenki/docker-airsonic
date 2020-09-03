FROM ubuntu:18.04

MAINTAINER simojenki

ARG REPO=${REPO}
ARG BRANCH=${BRANCH}

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

RUN echo "cloning: -b ${BRANCH}@${REPO}" && \
    git clone -b ${BRANCH} ${REPO} airsonic

WORKDIR /airsonic

RUN echo "Building revision: $(git rev-parse HEAD)" && \
    mvn test package -Dcheckstyle.skip

FROM linuxserver/airsonic:latest

RUN apt-get update && \
    apt-get remove openjdk-8-jre && \
    apt-get install -y \
        openjdk-11-jre
        sox

COPY downsample-flac /usr/bin/downsample-flac

COPY --from=0 /airsonic/airsonic-main/target/airsonic.war /app/airsonic/airsonic.war

