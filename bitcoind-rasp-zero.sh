#!/bin/bash

# Create new swapfile and enable it
echo 'Editing the swapfile to increase to 2GB..'
sudo dphys-swapfile swapoff
sudo sed -i '/^CONF_SWAPSIZE=/s/=.*/=2048/' /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# Install dependencies
echo 'Installing dependencies for build..'
sudo apt-get install autoconf libevent-dev libtool libssl-dev libboost-all-dev libminiupnpc-dev -y

# Create temp directory and cd to it
echo 'Creating working directory..'
mkdir bitcoin-rasp-zero
cd bitcoin-rasp-zero

# Get tarball
echo 'Downloading source..'
git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin

# Run autogen and configure
echo 'Running autogen.sh.. This is going to take awhile.. Feel free to come back later.'
./autogen.sh
echo 'Running configure without wallet'
./configure --enable-upnp-default --disable-wallet --with-boost-libdir=/usr/lib/arm-linux-gnueabih

# make and install
echo 'Running make and make install.. This will take a awhile.. Might want to go get a coffee.'
make
sudo make install

# adding bitcoin to cron to start on reboot
echo 'Installing bitcoin start into cron at reboot..'
echo '@reboot bitcoind -daemon -datadir=/var/lib/bitcoin -conf=/var/lib/bitcoin/bitcoin.conf' >> /var/spool/cron/crontabs/root

# Create directory for config and block data
echo 'Creating directory for configuration and block data..'
sudo mkdir /var/lib/bitcoin

# Download and install configuration file
echo 'Downloading default configuration file..'
wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/share/examples/bitcoin.conf
sudo cp bitcoin.conf /var/lib/bitcoin.conf
echo 'Adjusting prune value to fit on a 16GB sdcard..'
sudo sed -i 's/\#prune=550/prune=12000/' /var/lib/bitcoin/bitcoin.conf

# Run bitcoin node
echo 'Starting bitcoin node..'
sudo bitcoind -daemon -datadir=/var/lib/bitcoin -conf=/var/lib/bitcoin/bitcoin.conf

echo 'Done'
