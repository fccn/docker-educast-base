#-----
# base image for educast, provides a container with ruby and ffmpeg
# - sets timezone to Europe/Lisbon
# - creates educast user and group
#------
FROM ruby:2.4-alpine
MAINTAINER Paulo Costa <paulo.costa@fccn.pt>

ARG ffmpeg_version
ENV FFMPEG_VERSION=$ffmpeg_version

#add testing and community repositories
RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
  echo '@community http://nl.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \
  echo '@edge http://nl.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories && \
  apk update && apk upgrade --no-cache --available

#------ timezone and users

RUN apk --no-cache add ca-certificates && update-ca-certificates
# Change TimeZone
RUN apk add --update tzdata
ENV TZ=Europe/Lisbon
RUN cp /usr/share/zoneinfo/Europe/Lisbon /etc/localtime

#add educast users and groups
RUN addgroup -g 1000 educastgroup && adduser -u 501 -G educastgroup -D educast && adduser -u 1028 -G educastgroup -D educast_upload

#----- install required components

#build dependencies -- can be removed later
RUN apk add --virtual .build-deps build-base x264 nasm

#required packages
RUN apk add --no-cache --update curl patch nasm tar bzip2 openssh git file \
  nodejs docker bash unzip mariadb-dev imagemagick-dev \
  zlib-dev yasm-dev lame-dev libogg-dev x264-dev libvpx-dev libvorbis-dev \ 
  x265-dev freetype-dev libass-dev libwebp-dev rtmpdump-dev libtheora-dev \ 
  opus-dev fdk-aac-dev@testing bash

#----- install ffmpeg

WORKDIR /tmp/ffmpeg

RUN DIR=$(mktemp -d) && cd ${DIR} && \
  curl -s http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz | tar zxvf - -C . && \
  cd ffmpeg-${FFMPEG_VERSION} && \
  ./configure \
  --enable-version3 --enable-gpl --enable-nonfree --enable-small --enable-libmp3lame --enable-libfdk_aac --enable-libx264 --enable-libx265 --enable-libvpx --enable-libtheora --enable-libvorbis --enable-libopus --enable-libass --enable-libwebp --enable-librtmp --enable-postproc --enable-avresample --enable-libfreetype --disable-debug && \
  make && \
  make install && \
  make distclean && \

  rm -rf ${DIR} && \
  rm -rf /var/cache/apk/* && \
  apk del --update .build-deps
