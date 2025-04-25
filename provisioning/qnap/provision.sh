#!/bin/bash

sudo ln -s $(which docker) /usr/bin/docker

./qpkg-add.sh Python3 || exit 1
