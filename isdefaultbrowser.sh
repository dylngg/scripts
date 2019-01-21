#!/bin/bash
if defaultbrowser | grep "$1" | grep \* > /dev/null; then
  exit 0
else
  exit 1
fi
