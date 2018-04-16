# This test switches between taking and not taking a branch after two 
# branches in a row, represening the worst case for the prediction
Begin:  addi  $2, $0, 16        #
        addi  $5, $0, 6         #
        addi  $3, $0, 0         # i = 0
        addi  $4, $0, 400       # 100 loop iterations
Loop:   div   $3, $2            # m = i % 16
        mfhi  $1                #
        slt   $6, $1, $5        # 
        bne   $6, $0, Less      # if m < 6
        addi  $12, $12, 1       # count occurences of m > 6
Less:   addi  $3, $3, 4         # incement loop counter
        bne   $3, $4, Loop      # loop if i = j
End:    j End                   # loop forver