#!/bin/sh
# Copies or moves the last downloaded item in ~/Downloads to the current
# directory or the location specified. Copies when $0 is "copydownhere".
cmd="mv"
script="$(basename "$0")"
if [ "$script" = "copydownhere" ] || [ "$script" = "copydownhere.sh" ]; then
    cmd="cp"
fi
here="."
if [ "$1" != "" ]; then
    here="$1"
fi
there="$HOME/Downloads"
last="$(ls -t1 "$there" | head -1)"
"$cmd" "$there/$last" "$here"
if [ -f "$here" ]; then
    echo "$here"  # renamed
else
    echo "$here/$last"
fi
