#!/bin/bash

# note: after installation you must
# do ". /etc/profile.d/python3.bash" to
# setup the environment variables

package=Python3

status=$(qpkg_cli --status $package)

if [[ "$status" == *"is installed"* ]]; then
    echo "Package $package is already installed."
    exit 0
fi

qpkg_cli --add $package

echo -n "Waiting for $package to be installed."
while true; do
    status=$(qpkg_cli --status $package)
    if [[ "$status" == *"is installed"* ]]; then
        break
    fi

    echo -n "."
    sleep 1
done

echo "done"
