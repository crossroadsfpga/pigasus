# Pigasus


## Dependencies

Install the dependencies available through packages:

```bash
sudo apt install build-essential cmake libhwloc-dev luajit libluajit-5.1-dev \
    openssl libpcap0.8-dev libpcre3-dev pkg-config zlib1g libtool bison flex
```

Then install `libdaq`

```bash
git clone https://github.com/snort3/libdaq.git
cd libdaq
git checkout 2.x # must use version 2 with this version of Snort
./bootstrap
./configure
make
sudo make install
cd ..
```

To install `libdnet`, first clone the repo:

```
git clone https://github.com/dugsong/libdnet.git
cd libdnet
```

Apply the patch:

```
git apply ../libdnet.patch
```

And finally build and install:
```
./configure
make
sudo make install
cd ..
```

To install hyperscan do:

```
sudo apt install libhyperscan-dev
```


## Build

Make sure `/usr/local/lib` is in the load library path.
```bash
export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
```

### Build with Pigasus

```bash
./configure_cmake.sh --prefix=$installation_path_pigasus --enable-pigasus --builddir=build_pigasus
cd build_pigasus
make -j $(nproc) install
cd ..
```

### Build without Pigasus

```bash
./configure_cmake.sh --prefix=$installation_path_no_pigasus --disable-pigasus --builddir=build_no_pigasus
cd build_no_pigasus
make -j $(nproc) install
cd ..
```


### Debug

During development, it may be useful to enable debugging options and messages

```bash
./configure_cmake.sh --prefix=$installation_path_pigasus --enable-pigasus --enable-debug --enable-debug-msgs --enable-gdb --builddir=build_pigasus
```

## Run

Before running, you should change the config file to enable `hyperscan`. Add the following line to the end of the file located at `$installation_path/etc/snort/snort.lua`

```
search_engine = { search_method = 'hyperscan' }
```


Example command using pcap and one rule file:

```bash
../../snort_install/bin/snort -r ../../pcaps/net-2009-11-15-09_24.pcap --rule-path ../../rules/browser-firefox.rules.rules --daq-dir /usr/local/lib/daq
```

You can also run without a pcap (probably useful for Pigasus)

```bash
../../snort_install/bin/snort --rule-path ../../rules/browser-firefox.rules.rules --daq-dir /usr/local/lib/daq
```

### Running more easily

Add the following to your `.bashrc` or `.zshrc`:

```bash
export installation_path_no_pigasus=/home/hfreitas/sync/research/pigasus/snort_install_without_pigasus
export installation_path_pigasus=/home/hfreitas/sync/research/pigasus/snort_install_with_pigasus
export SNORT_LUA_PATH=/home/hfreitas/sync/research/pigasus/lua
export LUA_PATH="$installation_path_pigasus/include/snort/lua/?.lua;;"

alias snort3="$installation_path_no_pigasus/bin/snort -c $SNORT_LUA_PATH/snort.lua"
alias pigasus="$installation_path_pigasus/bin/snort -c $SNORT_LUA_PATH/snort.lua"
```

Now you can call snort3 using:

```bash
snort3 -r ../../pcaps/net-2009-11-15-09_24.pcap
```

## Run with valgrind 
