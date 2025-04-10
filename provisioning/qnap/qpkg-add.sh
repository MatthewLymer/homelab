#!/bin/bash

# note: after installation you must
# do ". /etc/profile.d/python3.bash" to
# setup the environment variables

package=$1

if [[ "$package" == "" ]]; then
    echo "Usage: $0 <package>"
    exit 1
fi

status=$(qpkg_cli --status $package)
if [[ "$?" -ne "0" ]]; then
    exit 1
fi

if [[ "$status" == *"is installed"* ]]; then
    echo "Package $package is already installed."
    exit 0
fi

output=$(qpkg_cli --add $package | tee /dev/tty)
if [[ "$output" == *"invalid"* ]]; then
    exit 1
fi

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
