#!/bin/sh
# Builds go code much like "go build" except for when go files are not passed
# as arguments. In that case, the final executable is named after the current
# directory's parent, rather than just the current directory (which is the
# default behavior for "go build"). See the first two paragraphs of
# "go help build" for more detail on golang's building behavior.
#
# This is useful if you've structured your source directories like:
# "<project>/<version>/"
# rather than
# "<project>/"
# which would ordinarilly result in your executable being named "<version>"...
#
# Usage: ./gobuild.sh [go-build-args ...]
use_parent=false
args="$@"
if test -n "$args"; then
  use_parent=true
fi

while test $# -gt 0 && ! $use_parent; do
  case "$1" in
  # shift out the arguments with req params
  -p | --p)
    shift
    ;;
  -asmflags | --asmflags)
    shift
    ;;
  -buildmode | --buildmode)
    shift
    ;;
  -compiler | --compiler)
    shift
    ;;
  -gccgoflags | --gccgoflags)
    shift
    ;;
  -gcflags | --gcflags)
    shift
    ;;
  -installsuffix | --installsuffix)
    shift
    ;;
  -ldflags | --ldflags)
    shift
    ;;
  -mod | --mod)
    shift
    ;;
  -pkgdir | --pkgdir)
    shift
    ;;
  -tags | --tags)
    shift
    ;;
  -toolexec | --toolexec)
    shift
    ;;
  # If it starts with a '-' it's probably a flag
  --*)
    ;;
  *)
    use_parent=true
    ;;
  esac
  shift
done

if ! $use_parent; then
  go build $args
else
  go build -o `pwd | xargs dirname | xargs basename` $args
fi
