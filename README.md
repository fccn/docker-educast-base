# Docker Educast base image

[![Build Status](https://dev.azure.com/pcosta-fccn/Educast-base-docker/_apis/build/status/fccn.docker-educast-base)](https://dev.azure.com/pcosta-fccn/Educast-base-docker/_build/latest?definitionId=1)

Multi-stage docker image with ruby and FFMpeg.
Used as base image for builing Educast application containers.

## About

The docker image is based on Alpine and has the following specs:

- Alpine 3.8
- Ruby 2.4
- FFMpeg 4.0.2
- Timezone set to Europe/Lisbon
- Creates educast user (501) and group (1000)
- Pre-installs a set of utilities such as: bzip2, openssh, git, nodejs, mariadb, imagemagick

The image size is 765MB

### FFmpeg info

```
ffmpeg version 4.0.2 Copyright (c) 2000-2018 the FFmpeg developers
  built with gcc 6.2.1 (Alpine 6.2.1) 20160822
  configuration: --disable-debug --disable-doc --disable-ffplay --enable-shared --enable-avresample --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-gpl --enable-libass --enable-libfreetype --enable-libvidstab --enable-libmp3lame --enable-libopenjpeg --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx265 --enable-libxvid --enable-libx264 --enable-nonfree --enable-openssl --enable-libfdk_aac --enable-libkvazaar --enable-libaom --extra-libs=-lpthread --enable-postproc --enable-small --enable-version3 --extra-cflags=-I/opt/ffmpeg/include --extra-ldflags=-L/opt/ffmpeg/lib --extra-libs=-ldl --prefix=/opt/ffmpeg
  libavutil      56. 14.100 / 56. 14.100
  libavcodec     58. 18.100 / 58. 18.100
  libavformat    58. 12.100 / 58. 12.100
  libavdevice    58.  3.100 / 58.  3.100
  libavfilter     7. 16.100 /  7. 16.100
  libavresample   4.  0.  0 /  4.  0.  0
  libswscale      5.  1.100 /  5.  1.100
  libswresample   3.  1.100 /  3.  1.100
  libpostproc    55.  1.100 / 55.  1.100

  configuration:
    --disable-debug
    --disable-doc
    --disable-ffplay
    --enable-shared
    --enable-avresample
    --enable-libopencore-amrnb
    --enable-libopencore-amrwb
    --enable-gpl
    --enable-libass
    --enable-libfreetype
    --enable-libvidstab
    --enable-libmp3lame
    --enable-libopenjpeg
    --enable-libopus
    --enable-libtheora
    --enable-libvorbis
    --enable-libvpx
    --enable-libx265
    --enable-libxvid
    --enable-libx264
    --enable-nonfree
    --enable-openssl
    --enable-libfdk_aac
    --enable-libkvazaar
    --enable-libaom
    --extra-libs=-lpthread
    --enable-postproc
    --enable-small
    --enable-version3
    --extra-cflags=-I/opt/ffmpeg/include
    --extra-ldflags=-L/opt/ffmpeg/lib
    --extra-libs=-ldl
    --prefix=/opt/ffmpeg

```

## Install

Clone this project and create a customized deploy.env file using the deploy.env.sample file as sample:
```sh
$ git clone https://github.com/fccn/docker-educast-base.git
$ cd educast_base
$ cp deploy.env.sample deploy.env
```
Use your preferred editor to open the newly created deploy.env file. The following variables can be modified:
- **APP_NAME** - Change the image name to whatever you want (currently is set to educast_base).
- **DOCKER_REPO** - Define the docker repository to store the generated image.

After customizing the build you can either build the image to use it locally

```sh
make build
```

or create a release by building and publishing the `{version}` and `latest` tagged containers to the configured `{docker_repo}`.

```sh
make release
```


## Usage

To use this image as the base for an Educast application just start the application's Dockerfile like this (if APP_NAME is not changed on deploy.env):

```
FROM {docker_repo}/educast_base:latest
...
```

## Author

Paulo Costa

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/fccn/docker-educast-base/tags).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
