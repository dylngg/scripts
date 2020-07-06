#!/bin/sh
# Executes the second-plus arguments in the first given directory.
#
# Note: Be wary of the fact that shell operations such as redirects are
#       interpreted _before_ the '@' command is executed, resulting in those
#       operations happening in the current working directory, rather than the
#       specified directory. e.g. "@ ~/ echo 'foo' > foo.txt" results in
#       foo.txt being written in the current working directory.
if [ "$1" = "" ]; then
    echo "No directory given" > /dev/stderr
    exit 1
fi
cd "$1"
shift
"$@"
