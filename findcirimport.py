#!/usr/bin/env python3
# A dirty script to find circular imports in the given C/C++ files. Ignores
# ifdefs and blindly strips directories when looking for imports.
#
# Usage: findcirimport files [files ...]

import argparse
import collections
import os
import re
import sys


def parse_args():
    parser = argparse.ArgumentParser(description="Find recursive imports in the given set of C and C++ files.")
    parser.add_argument("files", nargs="+", help="C/C++ files")
    return parser.parse_args()


def parse_include_line(line):
    match_or_none = re.match(r'#include\s+((<(.*)>)|("(.*)"))', line)
    if not match_or_none:
        raise ValueError("Unable to interpret '{}' as #include".format(line))

    return match_or_none.group(5)


def imports_from_file(filepath):
    imports = []
    with open(filepath) as f:
        for line in f.readlines():
            lstripped = line.strip()
            if lstripped.startswith("#include"):
                imports.append(parse_include_line(lstripped))

    return imports


def recursive_import_chain(source, import_set, source_imports_map):
    for import_ in import_set:
        if source == import_:
            return [source]

        chain_list = recursive_import_chain(source, source_imports_map.get(import_, set()), source_imports_map)
        if len(chain_list) > 0:
            return chain_list + [import_]

    return []


def main():
    args = parse_args()

    source_imports_map = {}
    for filename in args.files:
        real_filepath = os.path.realpath(filename)
        if real_filepath in source_imports_map:
            print("Ignoring duplicate file: {} (given {})", real_filepath, filename, file=sys.stderr)
            continue

        source = os.path.basename(real_filepath)
        source_imports_map[source] = set(imports_from_file(real_filepath))

    for source, import_set in source_imports_map.items():
        import_chain_list = recursive_import_chain(source, import_set, source_imports_map)
        if len(import_chain_list) > 0:
            print("Found recursive import chain: {}".format(" -> ".join(import_chain_list)))


if __name__ == "__main__":
    main()
