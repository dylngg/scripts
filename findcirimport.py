#!/usr/bin/env python3
# A dirty script to find circular imports in the given C/C++ files. Ignores
# ifdefs.
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


def unrelative_path(relative_to_dir, path):
    # unrelative_path("foo/", "../bar") -> "bar/"
    # unrelative_path("foo/", "/bar") -> "/bar"
    return os.path.normpath(os.path.join(relative_to_dir, path))


def imports_from_file(filepath):
    import_dir = os.path.dirname(filepath)

    imports = []
    with open(filepath) as f:
        for line in f.readlines():
            lstripped = line.strip()
            if lstripped.startswith("#include"):
                import_path = parse_include_line(lstripped)
                unrel_import_path = unrelative_path(import_dir, import_path)
                imports.append(unrel_import_path)

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
    seen_real_filepaths = set()
    for filepath in args.files:
        real_filepath = os.path.realpath(filepath)
        if real_filepath in seen_real_filepaths:
            print("Ignoring duplicate file: {} (given {})", real_filepath, filepath, file=sys.stderr)
            continue

        seen_real_filepaths.add(real_filepath)
        source_imports_map[filepath] = set(imports_from_file(filepath))

    for source, import_set in source_imports_map.items():
        import_chain_list = recursive_import_chain(source, import_set, source_imports_map)
        if len(import_chain_list) > 0:
            print("Found recursive import chain: {}".format(" -> ".join(import_chain_list)))


if __name__ == "__main__":
    main()
