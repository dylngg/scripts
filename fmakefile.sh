#!/bin/bash
# Formats a space formatted makefile into a tab seperated makefile. Requires
# unexpand.
#
# Note: When angry, you can let the "f" in fmakefile stand for something else,
# if you catch my drift...
EXPAND=unexpand
TAB_SPACE=4
cp $1 $1.spaces
$EXPAND -t $TAB_SPACE $1 | sponge $1
