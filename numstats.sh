#!/bin/bash
# Computes the min, max, mean, total, count, stddev, and variance of the
# numbers in stdin or a file if given. If the command name is min, max, mean,
# total, stddev, or var only that particular statistic is shown.
#
# Usage: ./numstats.sh [FILE]
filter="cat"
script="$(basename "$0")"
if [ "$script" = "min" ] || [ "$script" = "min.sh" ]; then
    filter="grep min"
elif [ "$script" = "max" ] || [ "$script" = "max.sh" ]; then
    filter="grep max"
elif [ "$script" = "mean" ] || [ "$script" = "mean.sh" ]; then
    filter="grep mean"
elif [ "$script" = "total" ] || [ "$script" = "total.sh" ]; then
    filter="grep total"
elif [ "$script" = "stddev" ] || [ "$script" = "stddev.sh" ]; then
   filter="grep stddev"
elif [ "$script" = "var" ] || [ "$script" = "var.sh" ]; then
    filter="grep var"
fi

input_file="/dev/stdin"
if [ "$1" != "" ]; then
    input_file="$1"
    if ! [ -f "$1" ]; then
        printf "%s: No such file" "$1" >/dev/stderr
        exit 1
    fi
fi

awk '
NR == 1 {
    min = $1
    max = $1
}
{
    if ($1 > max)
        max = $1
    if ($1 < min)
        min = $1

    values[count] = $1
    count++
    total += $1
}
END {
    mean = total / count

    for (val in values) {
        dev += (val - mean)**2
    }
    var = 1 / count * dev
    stddev = sqrt(var)
    printf "min:\t%f\nmax:\t%f\nmean:\t%f\nstddev:\t%f\nvar:\t%f\ntotal:\t%f\ncount:\t%f\n", min, max, mean, stddev, var, total, count
}
' "$input_file" | $filter
