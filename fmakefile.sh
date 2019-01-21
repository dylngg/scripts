#!/bin/bash
cp $1 $1.spaces
gunexpand -t 4 $1 | sponge $1
