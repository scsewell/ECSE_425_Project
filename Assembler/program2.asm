# A moderately tight loop
Begin:  addi  $2, $0, 200       # n = 200
        addi  $3, $0, 0         # i = 0
        addi  $4, $0, 400       # j = 400
        addi  $5, $0, 1         # m = 1
Loop:   slt   $1, $2, $3        # k = i < n
        bne   $1, $5, Stuff     # skip storing word if i < n
        sw    $3, 0($3)         # array[i] = i
Stuff:  addi  $3, $3, 4         # i = i+4
        bne   $3, $4, Loop      # exit loop if i = j
End:    j End                   # loop forver