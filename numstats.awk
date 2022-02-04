#!/usr/bin/env awk -f
# Computes the min, max, mean, total, count, stddev, and variance of the
# numbers in stdin or a file if given. If the command name is min, max, mean,
# total, stddev, or var only that particular statistic is shown.
#
# Usage: ./numstats.awk [FILE]
NR == 1 {
    min = $1
    max = $1
}
$1 ~ /^[0-9]+(.[0-9]+)?$/ {
    if ($1 > max)
        max = $1
    if ($1 < min)
        min = $1

    values[count] = $1
    count += 1
    total += $1
}
END {
    if (count > 0)
        mean = total / count
    else
        mean = 0

    for (val in values) {
        dev += (val - mean)**2
    }
    if (count > 0)
        var = 1 / count * dev
    else
        var = 0

    stddev = sqrt(var)
    printf "min:\t%f\nmax:\t%f\nmean:\t%f\nstddev:\t%f\nvar:\t%f\ntotal:\t%f\ncount:\t%f\n", min, max, mean, stddev, var, total, count
}
