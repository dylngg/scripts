#!/bin/bash
# Generates a template c file for testing
cat <<EOF | vim - -c 'set filetype=c'
#include "stdio.h"

int main(int argc, char **argv) {
    printf("%d\n", 1);
}
EOF
