# A very tight, minimal loop
Begin:  addi  $3, $0, 0         # i = 0
        addi  $4, $0, 40        # j = 40
Loop:   addi  $3, $3, 4         # i += 4
        bne   $3, $4, Loop      # exit loop if i = j
End:    j End                   # loop forver