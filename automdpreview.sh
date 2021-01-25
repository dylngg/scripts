#!/bin/bash
# Given a markdown file, print a preview in the terminal and update it when
# modified.
#
# MacOS only. Requires 'lynx' and 'fswatch'.
#
# Usage: ./automdpreview.sh markdown
set -e

if [ "$1" = "" ]; then
    echo "No markdown file given" >/dev/stderr
    exit 2
fi
target="$1"
if [ ! -f "$target" ]; then
    echo "Markdown file does not exist." >/dev/stderr
    exit 1
fi

trap "clear; exit;" SIGINT SIGTERM
while true; do
    clear
    pandoc -s "$target" -f markdown 2>/dev/null | lynx -stdin -dump 2>/dev/null
    fswatch -1 "$target" 2>&1 >/dev/null
done
