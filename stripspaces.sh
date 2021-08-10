#!/bin/bash
# Given or file, or stdin otherwise, strips trailing whitespace from the given
# file or stdin. Requires sponge from moreutils.
#
# Usage: stripspaces.sh [file]
if [ "$1" != "" ]; then
    sed 's/[[:space:]]*$//' "$1" | sponge "$1"
else
    sed 's/[[:space:]]*$//'
fi
