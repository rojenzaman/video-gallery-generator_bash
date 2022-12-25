#!/bin/bash

mkdir opt
cd opt
wget ${1}
tar -xzvf ${2}
cd pp
make
