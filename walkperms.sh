#!/bin/bash
# Walks the given path, returning the permissions at each subpath. If no path
# is given, the path to the current directory is used.
#
# Args:
# -r    Resolves the full physical path before walking. Requires 'realpath'.
#
# Works on both MacOS and Linux.
#
# Usage: walkperms.sh [args] [path]
should_resolve=false
if [ "$1" = "-r" ]; then
    should_resolve=true
    if ! command -v realpath >/dev/null; then
        echo "Could not find 'realpath' in \$PATH (not installed by default on MacOS)"
        exit 2
    fi
    shift
fi


if [ "$1" != "" ]; then
    path="$1"
else
    path="."
fi

if "$should_resolve"; then
    path="$(realpath $path)"
    if [ "$?" != "0" ]; then
        exit "$?"
    fi
fi


IFS='/' read -r -a parts <<< "$path"


longest_part=0
for part in "${parts[@]}"; do
    if (( "${#part}" > "${#longest_part}" )); then
        longest_part="$part"
    fi
done
longest_part_length="$(echo "$longest_part" | wc -c)"


if [ "${path:0:1}" == "/" ]; then  # absolute
    curr_path="/"
else
    curr_path="."
fi

for part in "${parts[@]}"; do
    if [ "$part" = "" ]; then  # first pass when /absolute
        continue
    fi

    if ! [ -e "$curr_path/$part" ]; then
        echo "$curr_path/$part: No such file or directory" >&2
        exit 1
    fi

    printf "%-*s\t" "$longest_part_length" "$part"

    if ! ls -laH "$curr_path" | awk '$9 == "'"$part"'" { print $1 "\t" $3 "\t" $4 }'; then
        exit 1
    fi

    curr_path="$curr_path/$part"
done
