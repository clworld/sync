#!/bin/sh
find . -type f -executable | grep -v /vendor/bundle/ | grep -v /node_modules/ | sed -e 's/^\.\///g;'
