# Computes the terms of the fibbonachi sequence while the
# current term is less than 1000
Begin:  addi  $1, $0, 1         # n = 1
        addi  $2, $0, 1         # m = 1
        sw    $1, 0($0)         # array[0] = n
        sw    $2, 4($0)         # array[1] = m
        addi  $3, $0, 0         # i = 0
Loop:   lw    $1, 0($3)         # n = array[i]
        lw    $2, 4($3)         # m = array[i+1]
        add   $4, $1, $2        # n += m
        sw    $4, 8($3)         # array[i] = n
        addi  $3, $3, 4         # increment counter
        addi  $5, $0, 1000      # 
        slt   $6, $4, $5        # 
        bne   $6, $0, Loop      # loop if n < 1000
End:    j End                   # loop forver