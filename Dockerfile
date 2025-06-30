#-----
# base image for educast, provides a container with ruby and ffmpeg
# - based on jrottenberg/ffmpeg:4.0-scratch image - https://hub.docker.com/r/jrottenberg/ffmpeg/
# - sets timezone to Europe/Lisbon
# - creates educast user and group
#------
FROM        alpine:3.16 AS build

WORKDIR     /tmp/workdir

ARG        PKG_CONFIG_PATH=/opt/ffmpeg/lib/pkgconfig
ARG        LD_LIBRARY_PATH=/opt/ffmpeg/lib
ARG        PREFIX=/opt/ffmpeg
ARG        MAKEFLAGS="-j2"

ENV         FFMPEG_VERSION=5.0.1      \
            LIBVIDSTAB_VERSION=1.1.0  \
            KVAZAAR_VERSION=2.0.0     \
            AOM_VERSION=v3.3.0        \
            SRC=/usr/local

ARG         LIBVIDSTAB_SHA256SUM="14d2a053e56edad4f397be0cb3ef8eb1ec3150404ce99a426c4eb641861dc0bb  v1.1.0.tar.gz"

RUN     buildDeps="autoconf \
                   automake \
                   bash \
                   binutils \
                   bzip2 \
                   cmake \
                   curl \
                   coreutils \
                   diffutils \
                   expat-dev \
                   file \
                   g++ \
                   gcc \
                   gperf \
                   libtool \
                   make \
                   python3 \
                   openssl-dev \
                   tar \
                   yasm \
                   patch \
                   fontconfig-dev \
                   freetype-dev \
                   zlib-dev \
                   libstdc++ \
                   ca-certificates \
                   libcrypto1.1 \
                   build-base \
                   x264-dev \
                   x265-dev \
                   libogg-dev \
                   libass-dev \
                   opus-dev \
                   libtheora-dev \
                   libvorbis-dev \
                   libvpx-dev \
                   xvidcore-dev \
                   fribidi-dev \
                   fdk-aac-dev \
                   aom-dev \
                   lame-dev \
                   opencore-amr-dev \
                   openjpeg-dev \
                   openjpeg-tools \
                   libssl1.1" && \
        apk  add --update ${buildDeps} \
		&& mkdir -p /tmp/patches

## add patches
COPY ./patches /tmp/patches
		
## libvstab https://github.com/georgmartius/vid.stab
RUN  \
        DIR=/tmp/vid.stab && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/georgmartius/vid.stab/archive/v${LIBVIDSTAB_VERSION}.tar.gz &&\
        echo ${LIBVIDSTAB_SHA256SUM} | sha256sum --check && \
        tar -zx --strip-components=1 -f v${LIBVIDSTAB_VERSION}.tar.gz && \
        cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" . && \
        make && \
        make install && \
        rm -rf ${DIR}
## kvazaar https://github.com/ultravideo/kvazaar
RUN \
        DIR=/tmp/kvazaar && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/ultravideo/kvazaar/archive/v${KVAZAAR_VERSION}.tar.gz &&\
        tar -zx --strip-components=1 -f v${KVAZAAR_VERSION}.tar.gz && \
        ./autogen.sh && \
        ./configure -prefix="${PREFIX}" --disable-static --enable-shared && \
        make && \
        make install && \
        rm -rf ${DIR}

## ffmpeg https://ffmpeg.org/
RUN  \
        DIR=$(mktemp -d) && cd ${DIR} && \
        curl -sLO https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 && \
        tar -jx --strip-components=1 -f ffmpeg-${FFMPEG_VERSION}.tar.bz2 && \
        ./configure \
        --disable-debug \
        --disable-doc \
        --disable-ffplay \
        --enable-shared \
        --enable-libopencore-amrnb \
        --enable-libopencore-amrwb \
        --enable-gpl \
        --enable-libass \
        --enable-libfreetype \
        --enable-libvidstab \
        --enable-libmp3lame \
        --enable-libopenjpeg \
        --enable-libopus \
        --enable-libtheora \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libx265 \
        --enable-libxvid \
        --enable-libx264 \
        --enable-nonfree \
        --enable-openssl \
        --enable-libfdk_aac \
        --enable-libkvazaar \
        --enable-libaom --extra-libs=-lpthread \
        --enable-postproc \
        --enable-small \
        --enable-version3 \
        --extra-cflags="-I${PREFIX}/include" \
        --extra-ldflags="-L${PREFIX}/lib" \
        --extra-libs=-ldl \
        --prefix="${PREFIX}" && \
        make && \
        make install && \
        make distclean && \
        hash -r && \
        cd tools && \
        make qt-faststart && \
        cp qt-faststart ${PREFIX}/bin


RUN \
        mkdir -p /tmp/fakeroot/lib  && \
        ldd ${PREFIX}/bin/ffmpeg | cut -d ' ' -f 3 | strings | xargs -I R cp R /tmp/fakeroot/lib/ && \
        for lib in /tmp/fakeroot/lib/*; do strip --strip-all $lib; done && \
        cp -r ${PREFIX}/bin /tmp/fakeroot/bin/ && \
        cp -r ${PREFIX}/share/ffmpeg /tmp/fakeroot/share/ && \
        LD_LIBRARY_PATH=/tmp/fakeroot/lib /tmp/fakeroot/bin/ffmpeg -buildconf

### Release Stage
FROM ruby:2.7.8-alpine3.16 AS educast_base
LABEL maintainer="Paulo Costa <paulo.costa@fccn.pt>"

#add testing and community repositories
#RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
#  echo '@community http://nl.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \
#  echo '@edge http://nl.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories && \
#  apk update && apk upgrade --no-cache --available
#RUN apk add --upgrade apk-tools@edge

#------ timezone and users
ENV TZ=Europe/Lisbon

# Change TimeZone
RUN apk --no-cache add ca-certificates && update-ca-certificates \
  && apk add --update tzdata freetype \
  && cp /usr/share/zoneinfo/Europe/Lisbon /etc/localtime \
  && rm -rf /var/cache/apk/*

#add educast users and groups
RUN addgroup -g 1000 educastgroup && adduser -u 501 -G educastgroup -D educast && adduser -u 1028 -G educastgroup -D educast_upload

#Copy ffmpeg binary from build stage
COPY --from=build /tmp/fakeroot/ /

# sanity tests
RUN ["ffprobe", "-version"]
RUN ["ffmpeg", "-buildconf"]
