#!/usr/bin/env gawk -f
# Wraps scripting comments (# comment) on their own line to 79 characters, or
# the given length.
#
# Trailing comments (not on their own line) that are not in a single or double
# quote and that do not fit within the character limit are moved to the
# previous non-commented line and wrapped.
#
# Any lines that do not contain comments are untouched. Note that hanging
# indents in comments are not properly handled.
#
# Requires GNU Awk and the 'fmt' utility. The latter can be either GNU or BSD.
#
# Usage: ./fmtc.gawk [file] [-WIDTH]
function format_comment(indent, comment) {
    # -2 -> fmt seems to consider the last column usable, and then pound
    width = max_width - length(indent) - 2
    fmt = "fmt -" width

    print comment |& fmt
    close(fmt, "to")

    formatted = ""
    while ((fmt |& getline line) > 0)
        formatted = formatted indent "#" line "\n"

    close(fmt)
    return formatted
}
function lstrip(string) {
    gsub(/^[ \t]*/, "", string)
    return string
}
function rstrip(string) {
    gsub(/[ \t]$/, "", string)
    return string
}
function indentation_of(string) {
    end = length(string) - length(lstrip(string))
    return substr(string, 0, end)
}
function is_number(string) {
    # If string, adds a 0 character, which will no longer be the same string
    return number + 0 == number
}
function debug(context) {
    # print context " with: '" $0 "' (comment: " comment ", indent: " indent ", trailing_comment: " trailing_comment
}
function flush_comment() {
    if (comment != "") {
        formatted_comment = format_comment(indent, comment)
        printf "%s", formatted_comment
        indent = ""
        comment = ""
    }
}
BEGIN {
    FS = "#"
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

    after_fs_mark = "\x01"
}
/^[ \t]*#/ {
    debug("line")

    if (indent == "")
        indent=$1

    # We need all content $2 onwards, since '#' can appear after the first '#'
    line = $1 after_fs_mark # insert special mark char
    for (i = 2; i <=NF; i++)
        line = line "#" $i

    # split after mark (+1 for '#' +1 for mark)
    content = substr(line, index(line, after_fs_mark) + 2)

    if (length(lstrip(content)) == 0) {
        # empty lines need additional newlines so 'fmt' treats them as a
        # separate paragraph
        comment = comment "\n\n"
    }
    else
        comment = comment content

    next
}
/#/ {
    debug("trailing comment")
    flush_comment()

    if (length($0) <= max_width) {
        print $0
        next
    }

    # We care about the first, non-quoted comment (which may not exist)
    split($0, chars, "")
    comment_start_index = -1
    in_single_quote = ""
    in_double_quote = ""
    escaped = ""
    for (char_index in chars) {
        if (escaped == "true") {
            escaped = ""
            continue
        }

        ch = chars[char_index]
        if (ch == "\"") {
            if (in_double_quote)
                in_double_quote = ""
            else if (!in_single_quote)
                in_double_quote = "true"
        }
        else if (ch == "'") {
            if (in_single_quote)
                in_single_quote = ""
            else if (!in_double_quote)
                in_single_quote = "true"
        }
        else if (ch == "\\") {
            escaped = "true"
        }
        else if (ch == "#" && in_double_quote != "true" && in_single_quote != "true") {
            comment_start_index = char_index
            break
        }
    }
    if (comment_start_index == -1) {
        print $0
        next
    }

    comment = ""
    # +1 -> skip #
    for (i = comment_start_index + 1; i <= length(chars); i++)
        comment = comment chars[i]

    indent = indentation_of($0)
    printf "%s", format_comment(indent, comment)
    comment = ""

    # -1 -> skip #
    print rstrip(substr($0, 0, comment_start_index-1))
    next
}
{
    debug("empty")
    flush_comment()

    print $0
    next
}
ENDFILE {
    debug("EOF")
    flush_comment()
}
