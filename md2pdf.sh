#!/bin/bash
# A wrapper around pandoc for sane markdown to pdf conversion
pandoc -s $1 -V geometry:margin=1in --mathjax -o `basename $1 .md`.pdf
