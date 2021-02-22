#!/bin/sh
# Copies or moves the last item in ~/Documents to the current directory or the
# location specified. Copies, rather than moves, when $0 is "copydochere".
cmd="mv"
script="$(basename "$0")"
if [ "$script" = "copydochere" ] || [ "$script" = "copydochere.sh" ]; then
    cmd="cp"
fi
here="."
if [ "$1" != "" ]; then
    here="$1"
fi
there="$HOME/Documents"
last="$(ls -t1 "$there" | head -1)"
"$cmd" "$there/$last" "$here"
if [ -f "$here" ]; then
    echo "$here"  # renamed
else
    echo "$last"
fi
