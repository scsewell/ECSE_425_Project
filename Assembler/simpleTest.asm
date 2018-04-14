Begin:  addi  $1, $0, 1         # n = 1
        sw    $1, 0($0)         # array[0] = n
        addi  $2, $0, 1         # k = 1
        sw    $2, 4($0)         # array[1] = k
        addi  $3, $0, 0         # i = 0
        addi  $4, $0, 40        # j = 40
Loop:   lw    $1, 0($3)         # n = array[i-2]
        lw    $2, 4($3)         # k = array[i-1]
        addi  $1, $1, 5         # n = n+1
        mult  $2, $1            # hi/lo = k*n
        mflo  $2                # k = lo
        sw    $2, 8($3)         # array[i] = k
        addi  $3, $3, 4         # i = i+4
        bne   $3, $4, Loop      # exit loop if i = j
End:    j End                   # loop forver