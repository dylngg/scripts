#!/bin/bash
# Copies or moves the last item (modtime) in ~/Downloads or ~/Documents to the
# current directory or the destination specified.
#
# Prints the last item, rather than copying/moving, when $0 does not end with "here"
# Uses ~/Documents, rather than ~/Downloads, when $0 contains "doc" instead of "down".
# Copies, rather than moves, when $0 starts with "copy".
#
# Usage: downhere [destdir]             # moves from ~/Downloads
#     or copydownhere [destdir]         # copies from ~/Downloads
#     or dochere [destdir]              # moves from ~/Documents
#     or copydochere [destdir]          # copies from ~/Documents
#     or down                           # Prints the last item in ~/Downloads
#     or doc                            # Prints the last item in ~/Documents
set -e

source="$HOME/Downloads"
cmd="echo"
dest=""

script="$(basename "$0")"
if [[ "$script" == *"here" ]]; then
    cmd="mv"
    if [ "${script:0:4}" = "copy" ]; then
        cmd="cp"
    fi

    dest="."
    if [ "$1" != "" ]; then
        dest="$1"
    fi
fi
if [[ "$script" == *"doc"* ]]; then
    source="$HOME/Documents"
fi

last="$(ls -t1 "$source" | head -1)"

if [ "$dest" != "" ]; then
    "$cmd" "$source/$last" "$dest"

    # Print the name of the file copied
    if [ -f "$dest" ]; then
        echo "$dest"  # renamed
    else
        echo "$last"
    fi
else
    "$cmd" "$source/$last"
fi
