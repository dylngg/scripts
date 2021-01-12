#!/bin/sh
# A wrapper around pandoc for sane markdown to pdf conversion
original="$1"
if [ "$(basename $original .md)" != "$original" ]; then
    prefix="$(basename $original .md)"
elif [ "$(basename $original .markdown)" != "$original" ]; then
    prefix="$(basename $original .markdown)"
else
    echo "File given does not end in .md or .markdown." > /dev/stderr
    exit 1
fi

pandoc -s "$original" -f markdown -o "$prefix.pdf" -V geometry:margin=1in -V colorlinks:true
