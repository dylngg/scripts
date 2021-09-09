#!/bin/bash
# Generates a template c or c++ file for testing
script_name="$(basename "$0")"
if [ "$script_name" = "testc++" ] || [ "$script_name" = "testc++.sh" ]; then
    cat <<EOF | vim - -c 'set filetype=cpp'
#include <iostream>

int main(int argc, char **argv) {
    std::cout << 1 << std::endl;
}
EOF

else
    cat <<EOF | vim - -c 'set filetype=c'
#include "stdio.h"

int main(int argc, char **argv) {
    printf("%d\n", 1);
}
EOF

fi

