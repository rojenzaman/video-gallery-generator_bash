#!/bin/bash

mkdir pp-tmp
cd pp-tmp
wget ${1}
tar -xzvf ${2}
cd pp
make
sudo make install
cd ../..
rm -rf pp-tmp
