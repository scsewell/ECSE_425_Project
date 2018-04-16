# A math heavier example with less density of branhces and less stalls
Begin:  addi  $2, $0, 2         # k = 2
        addi  $3, $0, 0         # i = 0
        addi  $4, $0, 40        # 10 loop iterations
Loop:   div   $3, $2            #
        mflo  $1                # n = i / 2
        mfhi  $5                # m = i % 2
        addi  $6, $0, 1         #
        beq   $5, $6, Even      # make n even if odd
Cont:   addi  $6, $0, 4         # n *= 4
        mult  $1, $6            # 
        mflo  $1                #
        addi  $7, $0, 3         # n /= 3
        mult  $1, $7            #
        mflo  $1                #
        addi  $3, $3, 1         # incement loop counter
        mult  $3, $6            # 
        mflo  $6                #
        sw    $1, 0($6)         # store result
        beq   $6, $4, End       # exit loop if i = j
        j Loop                  # loop
Even:   addi  $1, $1, 1         # n += 1
        j Cont                  # continue loop
End:    j End                   # loop forver