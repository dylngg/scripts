#!/usr/bin/env gawk -f
# Wraps Python-style multi-line comments to 79 characters, or the given
# length. Any content that appears after or before '"""' on the same line will
# be placed on a new line (this conflicts with PEP8).
#
# Requires GNU Awk and the 'fmt' utility. The latter can be either GNU or BSD.
#
# Usage: ./fmtmc.gawk [file] [-WIDTH]
function format_comment(indent, comment) {
    # -1 -> fmt seems to consider the last column usable
    width = max_width - length(indent) - 1
    fmt = "fmt -" width

    print comment |& fmt
    close(fmt, "to")

    delete formatted
    i = 0
    while ((fmt |& getline line) > 0)
        formatted[i++] = line

    close(fmt)
}
function lstrip(string) {
    gsub(/^[ \t]*/, "", string)
    return string
}
function indentation_of(string) {
    match(string, /^[ \t]*/)
    return substr(string, 0, RLENGTH)
}
BEGIN {
    FS="\"\"\""
    max_width = 79
    for (i = 0; i < ARGC; i++) {
        if (substr(ARGV[i], 0, 1) == "-") {
            split(ARGV[1], parts, "-")
            flag = parts[2]

            if (is_number(flag))
                max_width = parts[2]

            delete ARGV[i]  # awk dont open this file
        }
    }
}
/"""/ {
    # Because FS='"""':
    #
    # '"""content""" -> ["", "content", ""]
    # '"""' -> ["", ""]
    # '"""content' -> ["", "content"]
    # 'content"""' -> ["content", ""]
    content = 1
    if ($0 ~ /^[ \t]*"""/)
        content = 2

    was_in_comment = in_comment
    in_comment = "true"

    if (was_in_comment != "true")  # on first encounter
        indent = indentation_of($0)

    if ($content != "")  # don't mush words
        comment = comment $content " "

    if (was_in_comment != "true" && NF == content)  # missing end '"""'
        next

    in_comment = ""
    # print with newlines because we aren't smart enough to deal with
    # conditionally wrapping the first line 3 characters less
    print indent "\"\"\""
    format_comment(indent, comment)
    nlines = length(formatted)
    for (i in formatted) {
        printf "%s%s", indent, formatted[i]
        if (i != nlines - 1)
            print ""
    }
    # same here
    print "\n" indent "\"\"\""

    comment = ""
    indent = ""
    next
}
/^$/ {
    if (in_comment == "true") {
        old_comment = comment
        # fmt will (rightly) treat a single newline as a space, so it can
        # wrap things correctly. We want to double up our newlines on their
        # own line so that they are preserved and not wrapped.
        comment = comment "\n\n"
    }
    else
        print $0

    next
}
{
    if (in_comment == "true")
        comment = comment $0
    else
        print $0

    next
}
