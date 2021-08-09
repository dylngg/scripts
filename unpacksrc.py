#!/usr/bin/env python
# Prints out shell commands for extracting a compressed source file and
# renaming both the source file and the extracted directory to the given name.
#
# This is useful for consistent naming of tarballs and the extracted directory
# when downloading sources. e.g.
#   $ wget https://github.com/coreutils/coreutils/archive/v8.32.tar.gz
#   $ ls
#   v8.32.tar.gz
#   $ unpacksrc.py v8.32.tar.gz 8.32
#   mv v8.32.tar.gz 8.32.tar.gz && mkdir -p 8.32 && pushd 8.32 \
#       && tar xzf ../8.32.tar.gz . && popd
#   $ !! | sh
#   $ ls -F
#   8.32/ 8.32.tar.gz
#
# Supports both Python 2 and 3.
#
# Usage: ./unpacksrc.py SOURCE NAME
import argparse
import collections
import os
import re
import sys
import textwrap
import time


compression_cmds = {
    ".tar.bz2":  ["tar", "xzjf"],
    ".tarbz2":   ["tar", "xzjf"],
    ".tbz2":     ["tar", "xzjf"],
    ".tar.xz":   ["tar", "xJf"],
    ".tarxz":    ["tar", "xJf"],
    ".txz":      ["tar", "xJf"],
    ".tar.gz":   ["tar", "xzf"],
    ".targz":    ["tar", "xzf"],
    ".tgz":      ["tar", "xzf"],
    ".tar":      ["tar", "xf"],
    ".gz":       ["gunzip"],
    ".bz2":      ["bunzip2"],
    ".bz":       ["bunzip"],
    ".zip":      ["unzip"],
}


def split_by_ext(filename):
    """
    Returns both the name and file extension.
    """
    for compression_ext in compression_cmds:
        if filename.endswith(compression_ext):
            return filename[:-len(compression_ext)], compression_ext


def has_supported_ext(filename):
    """
    Returns whether the filename has a supported compression extension.
    """
    return any(filename.endswith(ext) for ext in compression_cmds)


def escape_sh_arg(arg):
    """
    Returns a shell escaped argument.
    """
    # Keep it simple and readable unless needed
    if re.match("^[0-9a-zA-Z.\-_/]+$", arg):
        return arg

    # Lifted from https://stackoverflow.com/questions/35817/how-to-escape-os-system-calls
    return "'" + arg.replace("'", "'\\''") + "'"


def print_sh_commands(filepath, new_name, ext):
    """
    Writes out the actions in shell out to stdout.
    """
    dirname = os.path.dirname(filepath)
    # If given relative, print relative because it's often easier to read
    if not os.path.isabs(filepath):
        dirname = os.path.relpath(os.getcwd(), dirname)

    if dirname != "." and dirname != os.getcwd():
        sys.stdout.write("pushd " + escape_sh_arg(dirname) + " && ")

    old_filepath = os.path.relpath(filepath, dirname)
    new_filepath = os.path.relpath(os.path.join(dirname, new_name) + ext, dirname)
    decompress_cmd = " ".join(compression_cmds[ext])

    if old_filepath != new_filepath:
        sys.stdout.write("mv %s %s && " % (old_filepath, new_filepath))

    sh = "mkdir -p %s && pushd %s && " + decompress_cmd + " %s . && popd"
    args = (
        new_name,
        new_name,
        os.path.relpath(new_filepath, new_name)
    )
    sys.stdout.write(sh % tuple(map(escape_sh_arg, args)))

    if dirname != ".":
        sys.stdout.write(" && popd")

    sys.stdout.write("\n")


def arguments():
    """
    Parses arguments from argparse and returns it.
    """
    desc = textwrap.fill(
            "Prints out shell commands for extracting a compressed source "
            "file and renaming both the source file and the extracted "
            "directory to the detected source version numbers provided or "
            "present in the filename.", 79)

    epilog = (
        "supported compressions:\n"
        "  - .tar.bz2, .tarbz2, .tbz2\n"
        "  - .tar.xz, .tarxz, .txz\n"
        "  - .tar.gz, .targz, .tgz\n"
        "  - .tar\n"
        "  - .gz\n"
        "  - .bz2\n"
        "  - .bz\n"
        "  - .zip\n"
        "\n"
    )

    parser = argparse.ArgumentParser(
        description=desc,
        epilog=epilog,
        # formatter_class needed so that newlines in epolog are not removed
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("source",
                        help="The source file to extract. ")
    parser.add_argument("name",
                        help="The new name of the source file and the "
                             "extracted directory.")
    return parser.parse_args()


def main(args):
    compressed_filepath = args.source
    if not has_supported_ext(compressed_filepath):
        compression_exts_str = ", ".join(compression_cmds.keys())
        exit("%s has unsupported compression extension. Valid: %s" % (
            compressed_filepath,
            compression_exts_str
        ))

    filename = os.path.basename(compressed_filepath)
    _, ext = split_by_ext(compressed_filepath)

    print_sh_commands(compressed_filepath, args.name, ext)


args = arguments()
main(args)
