#!/bin/bash
# Returns whether the default browser is $1. Requires defaultbrowser (MacOS)
if defaultbrowser | grep "$1" | grep \* > /dev/null; then
  exit 0
else
  exit 1
fi
