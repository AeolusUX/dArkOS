#!/bin/bash

if [ "$1" == "32" ]; then
  ARCH="arm-linux-gnueabihf"
  CHROOT_DIR="Arkbuild32"
else
  ARCH="aarch64-linux-gnu"
  CHROOT_DIR="Arkbuild"
fi

# Install build dependencies
sudo chroot ${CHROOT_DIR}/ bash -c "apt-get -y update && DEBIAN_FRONTEND=noninteractive eatmydata apt-get install -y \
  alsa-utils \
  autotools-dev \
  brightnessctl \
  build-essential \
  cmake \
  console-setup \
  dialog \
  dos2unix \
  espeak-ng \
  exfatprogs \
  ffmpeg \
  fonts-noto-cjk \
  g++ \
  g++-12 \
  gcc-12 \
  git \
  liba52-0.7.4 \
  libarchive-zip-perl \
  libasound2-dev \
  libboost-date-time-dev \
  libboost-filesystem-dev \
  libboost-locale-dev \
  libboost-system-dev \
  libcurl4-openssl-dev \
  libdrm-dev \
  libeigen3-dev \
  libevdev-dev \
  libfaad2 \
  libfreeimage-dev \
  libfreetype6-dev \
  libmad0 \
  libmpeg2-4 \
  libnl-3-dev \
  libnl-genl-3-dev \
  libnl-route-3-dev \
  libopenal-dev \
  libopenal1 \
  libsdl2-dev \
  libsdl2-image-2.0-0 \
  libsdl2-image-dev \
  libsdl2-mixer-dev \
  libsdl2-net-2.0-0 \
  libsdl2-ttf-2.0-0 \
  libsdl2-ttf-dev \
  libspeechd2 \
  libstdc++-12-dev \
  libtheoradec1 \
  libtool \
  libtool-bin \
  libvlc-dev \
  libvlccore-dev \
  ninja-build \
  p7zip-full \
  premake4 \
  psmisc \
  python3 \
  python3-evdev \
  python3-pip \
  python3-setuptools \
  python3-urwid \
  python3-wheel \
  rapidjson-dev \
  rustc \
  tar \
  unzip \
  vlc-bin \
  wget \
  zip"

# Default gcc and g++ to version 12
sudo chroot ${CHROOT_DIR}/ bash -c "update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 10"
sudo chroot ${CHROOT_DIR}/ bash -c "update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 20"
sudo chroot ${CHROOT_DIR}/ bash -c "update-alternatives --set gcc \"/usr/bin/gcc-12\""
sudo chroot ${CHROOT_DIR}/ bash -c "update-alternatives --set g++ \"/usr/bin/g++-12\""

# Symlink fix for DRM headers
sudo chroot ${CHROOT_DIR}/ bash -c "ln -s /usr/include/libdrm/ /usr/include/drm"

# Install meson
sudo chroot ${CHROOT_DIR}/ bash -c "git clone https://github.com/mesonbuild/meson.git && ln -s /meson/meson.py /usr/bin/meson"

# Build and install librga
sudo chroot ${CHROOT_DIR}/ bash -c "cd /home/ark &&
  git clone https://github.com/christianhaitian/linux-rga.git &&
  cd linux-rga &&
  git checkout 1fc02d56d97041c86f01bc1284b7971c6098c5fb &&
  meson build && cd build &&
  meson compile &&
  cp -r librga.so* /usr/lib/${ARCH}/ &&
  cd .. &&
  mkdir -p /usr/local/include/rga &&
  cp -f drmrga.h rga.h RgaApi.h RockchipRgaMacro.h /usr/local/include/rga/
  "

# Build and install libgo2
sudo chroot ${CHROOT_DIR}/ bash -c "cd /home/ark &&
  git clone https://github.com/OtherCrashOverride/libgo2.git &&
  cd libgo2 &&
  premake4 gmake &&
  make -j$(nproc) &&
  cp libgo2.so* /usr/lib/${ARCH}/ &&
  mkdir -p /usr/include/go2 &&
  cp -L src/*.h /usr/include/go2/
  "
