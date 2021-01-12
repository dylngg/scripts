#!/bin/sh
# Generates random hex strings of the given length
#
# Usage: ./randhex [LENGTH]
LENGTH=16
if [ "$1" != "" ]; then
    if [ "$1" -gt 0 ] 2>/dev/null; then
        LENGTH="$1"
    else
        echo "Not a positive number." >/dev/stderr
        exit 2
    fi
fi
od -X -A n /dev/random | awk '{ printf "%s%s%s%s\n", $1, $2, $3, $4 }' | cut -b -$LENGTH
