#!/bin/sh
# Refreshes Qt Creator with new .cpp, .hpp, .c, .h and Makefile files found.
# Must be run in directory with a .creator (Qt Creator Project) file.
#
# Usage ./refresh_qtcreator
creatorfile="$(find . -maxdepth 1 -type f -name "*.creator" 2>/dev/null | head -1)"
if [ "$creatorfile" = "" ]; then
    echo "Qt Creator project not found in directory"
    exit 1
fi
project="$(basename "$creatorfile" .creator)"
find . -type f \( -name '*.c' -o -name '*.h' -o -name '*.cpp' -o -name '*.hpp' -o -name 'Makefile' \) > "$project".files
