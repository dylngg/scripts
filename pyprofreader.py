#!/usr/bin/env python3
#
# Given a Python cprofile from (e.g. from python3 -m cProfile -o arbcprofile.bin),
# reads the binary profile and prints out the profile ordered by the time spent
# per-function.
#
# Usage: ./pyprofreader.py profile.cprofile
import pstats
import sys

if len(sys.argv) < 2:
    exit("No binary profile given")

p = pstats.Stats(sys.argv[1])
p.strip_dirs()
p.sort_stats(pstats.SortKey.TIME)
try:
    p.print_stats()
except BrokenPipeError:
    # When piping out to 'less' or 'head', pstats freaks out when the
    # pipe is suddenly closed. Don't panic.
    pass
