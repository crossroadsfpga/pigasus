#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# we download the libraries to the directory pigasus is in
cd $SCRIPT_DIR/..

sudo apt-get update
sudo apt-get install -y build-essential cmake libhwloc-dev \
      luajit libluajit-5.1-dev openssl libpcap0.8-dev \
      libpcre3-dev pkg-config zlib1g libtool \
      libhyperscan-dev git

# libdaq
git clone https://github.com/snort3/libdaq.git
cd libdaq
git checkout 2.x
./bootstrap
./configure
make
sudo make install
cd ..

# libdnet
git clone https://github.com/dugsong/libdnet.git
cd libdnet
./configure
make
sudo make install
cd ..

sudo ldconfig -v

