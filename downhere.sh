#!/bin/sh
# Moves the last downloaded item in ~/Downloads to the current directory or
# the directory specified
here="."
if [ "$1" != "" ]; then
    here="$1"
fi
there="$HOME/Downloads"
last="$(ls -t1 "$there" | head -1)"
mv "$there/$last" "$here"
