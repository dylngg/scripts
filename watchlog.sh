#!/bin/bash
# Watches a log file every second and tails that file with enough lines to
# fit within the TTY height. If a file is not given, stdin is used.
#
# Requires the 'watch' utility, which is part of the procps utility suite
# (along with pkill, top, w, etc). Not installed by default on MacOS; can be
# installed with 'port install watch' on MacPorts systems.
#
# Usage: ./watchlog.sh [FILE]
towatch="$1"
if [ "$towatch" = "" ] || [ "$towatch" = "-" ]; then
    towatch="/dev/stdin"
fi
lines="$(tput lines)"
tty_height="$(( $lines - 3 ))"

watch -n 1 -c tail -n $tty_height "$towatch"
