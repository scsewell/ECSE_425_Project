# This program computes the factorial of the input in $1. The
# result is returned in $2.
# $1: n
# $2: running product (output n!)

Fact:   addi  $1, $0, 5         # input: n = 5
        addi  $2, $0, 1         # initialize output to 1
Loop:   addi  $0, $0, 0         # do nothing
        j Loop                  # and loop