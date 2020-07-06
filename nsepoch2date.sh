#!/bin/bash
# Given nanoseconds in epoch as the first argument, prints out a nicely
# formatted date for the given epoch.
if [ -z "$1" ]; then
    echo "No ns timestamp given." > /dev/stderr
    exit 1
fi

datecmd="date"
if ! date --date now 2>/dev/null; then
    # date is non-GNU, check for 'g' prefixed variant
    if ! which -s gdate; then
        # GNU date is not available
        echo "'date' command doesn't accept GNU style --date flag" > /dev/stderr
        exit 1
    fi
    datecmd="gdate"
fi

echo "scale=10; $1 * (1/1000000000)" | bc |             # ns to s
    tr -d '\n' |                                        # strip newline
    xargs -0 printf "%s/1\n" | bc |                     # to int
    xargs -0 printf "@%s" | xargs -0 $datecmd -d        # to date
