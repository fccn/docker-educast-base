# Docker Educast base image

Minimal docker image from which Educast application containers can be built.

## About

The docker image is based on Alpine and has the following specs:

- Ruby 2.4
- FFMpeg 3.3.5
- Timezone set to Europe/Lisbon
- Creates educast user (501) and group (1000)
- Pre-installs a set of utilities such as: bzip2, openssh, git, nodejs, mariadb, imagemagick

The image size is 765MB

### FFmpeg info

```
ffmpeg version 3.3.5 Copyright (c) 2000-2017 the FFmpeg developers
  built with gcc 5.3.0 (Alpine 5.3.0)
  configuration: --enable-version3 --enable-gpl --enable-nonfree --enable-small --enable-libmp3lame --enable-libfdk_aac --enable-libx264 --enable-libx265 --enable-libvpx --enable-libtheora --enable-libvorbis --enable-libopus --enable-libass --enable-libwebp --enable-librtmp --enable-postproc --enable-avresample --enable-libfreetype --disable-debug
  libavutil      55. 58.100 / 55. 58.100
  libavcodec     57. 89.100 / 57. 89.100
  libavformat    57. 71.100 / 57. 71.100
  libavdevice    57.  6.100 / 57.  6.100
  libavfilter     6. 82.100 /  6. 82.100
  libavresample   3.  5.  0 /  3.  5.  0
  libswscale      4.  6.100 /  4.  6.100
  libswresample   2.  7.100 /  2.  7.100
  libpostproc    54.  5.100 / 54.  5.100

  configuration:
    --enable-version3
    --enable-gpl
    --enable-nonfree
    --enable-small
    --enable-libmp3lame
    --enable-libfdk_aac
    --enable-libx264
    --enable-libx265
    --enable-libvpx
    --enable-libtheora
    --enable-libvorbis
    --enable-libopus
    --enable-libass
    --enable-libwebp
    --enable-librtmp
    --enable-postproc
    --enable-avresample
    --enable-libfreetype
    --disable-debug

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
- **FFMPEG_VERSION** - Change the FFMpeg version (currently is set to 3.3.2).

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
