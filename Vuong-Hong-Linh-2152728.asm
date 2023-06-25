
   .data

   # The .word assembler directive reserves space
   # in memory for a single 4-byte word (or multiple 4-byte words)
   # and assigns that memory location an initial value
   # (or a comma separated list of initial values)
   
   # Messages
   getNum:  .asciiz "Enter two positive numbers to initialize the random number generator.\n"
   getNum1: .asciiz "Number 1: "
   getNum2: .asciiz "Number 2: "
   legend1: .asciiz "Player 1 (X)"
   legend2: .asciiz "\nPlayer 2 (O)"
   game1:   .asciiz "\nCoin toss... Player 1 goes first.\n\n"
   game2:   .asciiz "\nCoin toss... Player 2 goes first.\n"
   board1:  .asciiz "\n  1 2 3 4 5 6 7\n"	
   board2:  .asciiz "  -------------\n"
   board3:  .asciiz " "
   getCol:  .asciiz "What column would you like to drop token into? Enter 1-7 (X): "
   getCol2: .asciiz "What column would you like to drop token into? Enter 1-7 (O): "
   error:   .asciiz "\nERROR 100: Selected Column is Full or Does Not Exist. Try Again.\n\n"
   comp1:   .asciiz "Computer player selected column "
   draw:    .asciiz "Draw!"
   lost:    .asciiz "Player 1 wins"
   won:     .asciiz "Player 2 wins"
   newline: .asciiz "\n"
   ask: .asciiz "Do you want to reverse your turn? (Enter 0 if yes - 1 if no): "
   clear:  .byte   0x1B,0x5B,0x33,0x3B,0x4A,0x1B,0x5B,0x48,0x1B,0x5B,0x32,0x4A
        .byte 0x00
   
   
   # Global Variables
 
   ROW: .word 6                              # Allocating 6 32-bit value for ROW
   COL: .word 8                   # Allocating 9 32-bit value for COL
   colSpaceTrack: .word 5, 5, 5, 5, 5, 5, 5, 5  # Initializing array colSpaceTrack[7]
   gameBoard: .space 48                  # Initializing array gameBoard[6][7] (Total bytes = 7*6 = 42)
   currPlayer: .space 1                      # Initializing currPLayer

.text
   .globl main


main:

   # Register Map for main:
     
   # $s2: ROW (global)
   # $s3: COL (global)
   # $s4: Base Address of gameBoard (global)
   # $s5: Base Address of colSpaceTrack (global)
   # $s6: currPlayer (global)
   # $t0: i (Outer Loop Counter), Return Value of isGameOver()
   # $t1: j (Inner Loop Counter), Return Value of isDraw()
   # $t2: tossResult
   # $t3: Value of gameBoard[i][j]
   # $t4: '.'
   # $t5: 2 (For i % 2)
   # $t6: i % 2
   # $t7: 'O'
   # $t8: 'X'
   
   # Initialize Registers

   lw $s2, ROW                  # Load memory ROW to $s2
   lw $s3, COL                  # Load memory COL to $s3
   la $s4, gameBoard            # Load address of gameBoard to $s4
   la $s5, colSpaceTrack        # Load address of colSpaceTrack to $s5
   lb $s6, currPlayer           # Load memory currPlayer to $s6
   li $t0, 0                    # i = 0
   li $t4, '.'                   # $t4 = '.'
   li $t5, 2                 # $t5 = 2
   li $t7, ' '                  # $t7 = ' '
   li $t8, ' '                  # $t8 = ' '
   #clear the screen
  
   
   # Operations for Storing '.' in gameBoard[i][j]
   # Outer FOR-LOOP
   FORi: bge $t0, $s2, RESET    # if(i >= ROW(6)), Branch to FORi1
         li $t1, 0              # j = 0
   
      # Inner FOR-LOOP
      FORj: bge $t1, $s3, endFOR   # if (j >= COL(8)), Branch to endFOR
            mul $t3, $t0, $s3      # $t3 = i * COL
            add $t3, $t3, $t1      # $t3 += j
            add $t3, $s4, $t3      # $t3 = &gameBoard[i][j] (Base + Offset)
            sb $t4, 0($t3)         # gameBoard[i][j] = '.' (Store '.' in gameBoard[i][j])
            addi $t1, $t1, 1       # j++
            j FORj                 # jump to FORj
   
      endFOR: addi $t0, $t0, 1     # i++
              j FORi               # jump to FORi
           
   RESET: li $t0, 0                # i = 0
   
   # Operations for Populating First and Last Column with Alternating Player Tokens
 	  FORi1: bge $t0, $s2, getRAND # if(i >= ROW(6)), Branch to getRAND
          div $t0, $t5          # i/2
          mfhi $t6              # $t6 = i % 2
          
          # Store ' ' in gameBoard[i][0] such that i % 2 = 0
         
          mul $t3, $t0, $s3     # $t3 = i * COL
          add $t3, $s4, $t3     # $t3 = &gameBoard[i][j] (Base + Offset)
          sb $t7, 0($t3)        # gameBoard[i][0] = 'O' (Store 'O' in gameBoard[i][0])
          
          mul $t3, $t0, $s3     # $t3 = i * COL
          addi $t3, $t3, 8      # $t3 += 8
          add $t3, $s4, $t3     # $t3 = &gameBoard[i][j] (Base + Offset)
          sb $t7, 0($t3)        # gameBoard[i][8] = 'O' (Store 'O' in gameBoard[i][8])
          addi $t0, $t0, 1      # i++
          j FORi1               # jump to FORi1
          
          
   
   # Print Messages and Ask For Two Random Numbers From The User
   getRAND:
   li $v0, 4                    # print_string syscall code = 4
   la $a0, getNum               # load the address of getNum
   syscall                      # system call
   
   li $v0, 4                    # print_string syscall code = 4
   la $a0, getNum1              # load the address of getNum1
   syscall                      # system call
   
   # Get First Number From The User and Save
   li $v0, 5                    # read_int syscall code = 5
   syscall                      # system call
   move $s0, $v0                # $s0 (m_w) = $v0 (User Input)
   
   li $v0, 4                    # print_string syscall code = 4
   la $a0, getNum2              # load the address of getNum2
   syscall                      # system call
   
   # Get Second Number From The User and Save
   li $v0, 5                    # read_int syscall code = 5
   syscall                      # system call
   move $s1, $v0                # $s1 (m_z) = $v0 (User Input)
   
   # Print Game Legend
   li $v0, 4                    # print_string syscall code = 4
   la $a0, legend1              # load the address of legend1
   syscall                      # system call
   
   li $v0, 4                    # print_string syscall code = 4
   la $a0, legend2              # load the address of legend2
   syscall                      # system call
   
   # Call random_in_range To Generate Random Number Between 0 and 1
   li $a0, 0                    # $a0 = 0
   li $a1, 1                    # $a1 = 1
   jal random_in_range_2         # Function Call to random_in_range
   move $t2, $v0               # $t2 (tossResult) = return value of random_in_range_2
   
   # If Coin Toss Generates 0, Then Player 2 Plays First, Else Player 1 First
   # Consists of Do-While Loop Which Keeps Looping Until Game is Over
   # Consistently Asks Computer For a Move First Followed by the User or Human
   # Prints Board After Each Player's Turn
   bne $t2, $zero, ELSE_USER_1   # if(tossResult != 0), Branch to ELSE_USER_1
   
   # Print Result of Coin Toss When tossResult = 0
                       # system call
   
   # Keeps Looping Until Either Computer or Human Wins or When The Game is a Draw
   		 li $v0, 4                    # print_string syscall code = 4
   		la $a0, game2                # load the address of game1
   		syscall 	
   DO_USER_2: 
	    
	    
	    
   	    jal U2Move              # Function Call to U2Move() to Compute Computer's Move First
            jal printGameBoard        # Function Call to printGameBoard
                 #ask if the player wants to reverse
            # Check Game Status
            jal isGameOver            # Function Call to isGameOver
            move $t0, $v0             # $t0 = $v0 (Return Value of isGameOver())
            jal isDraw                # Function Call to isDraw to Check if Game is a Draw
            move $t1, $v0             # $t1 = $v0 (Return Value of isDraw())
            
            # if(isGameOver() == 0 || isDraw() == 0), Break from Do-While Loop
            beq $t0, $zero, END_GAME  # if(isGameOver() == 0), Branch to END_GAME
            beq $t1, $zero, END_GAME  # if(isDraw() == 0), Branch to END_GAME
            
            # Get User's Move and Print Board
            jal userMove              # Function Call to userMove to get User's Move
            jal printGameBoard        # Function Call to printGameBoard
            
            
            
            
            
            
            # Check Game Status
            jal isGameOver            # Function Call to isGameOver
            move $t0, $v0             # $t0 = $v0 (Return Value of isGameOver())
            jal isDraw                # Function Call to isDraw to Check if Game is a Draw
            move $t1, $v0             # $t1 = $v0 (Return Value of isDraw())
            
            # Loop if Game is Not Over, Branch to END_Game Otherwise
            beq $t0, $zero, END_GAME  # if(isGameOver() == 0), Branch to END_GAME
            beq $t1, $zero, END_GAME  # if(isDraw() == 0), Branch to END_GAME
            j DO_USER_2                 # jump to DO_USER_2 if (isGameOver() != 0 && isDraw() != 0)
   
   # If Coin Toss Generates 1, User Plays First
   # Print Result of Coin Toss When tossResult = 1 and Print Initial Board
   # Consists of Do-While Loop Which Keeps Looping Until Game is Over
   # Prints Board After Each Player's Turn
    		
   ELSE_USER_1: 
   		              # system call
                 # Function Call to printGameBoard
               
               # Keeps Looping Until Either Computer or Human Wins or When The Game is a Draw
               li $v0, 4              # print_string syscall code = 4
               la $a0, game1         # load the address of game2
               syscall  
               DO_USER: 
               		
               		jal userMove          # Function Call to userMove() to Compute User's Move First
                       jal printGameBoard 
                      
                   # Check Game Status
                   jal isGameOver             # Function Call to isGameOver
                   move $t0, $v0              # $t0 = $v0 (Return Value of isGameOver())
                   jal isDraw                 # Function Call to isDraw to Check if Game is a Draw
                   move $t1, $v0              # $t1 = $v0 (Return Value of isDraw())
                    
                   # if(isGameOver() == 0 || isDraw() == 0), Branch to EXIT_LOOP
                   beq $t0, $zero, EXIT_GAME  # if(isGameOver() == 0), Branch to EXIT_GAME
                   beq $t1, $zero, EXIT_GAME  # if(isDraw() == 0), Branch to EXIT_GAME
                        
                   # Get Computer's Move and Print Board
                   jal U2Move               # Function Call to userMove to get User's Move
                   jal printGameBoard         # Function Call to printGameBoard
                        
                   # Check Game Status
                   jal isGameOver             # Function Call to isGameOver
                   move $t0, $v0              # $t0 = $v0 (Return Value of isGameOver())
                   jal isDraw                 # Function Call to isDraw to Check if Game is a Draw
                   move $t1, $v0              # $t1 = $v0 (Return Value of isDraw())
                    
                   # Loop if Game is Not Over, Branch to END_GAME Otherwise
                   beq $t0, $zero, END_GAME   # if(isGameOver() == 0), Branch to END_GAME
                   beq $t1, $zero, END_GAME   # if(isDraw() == 0), Branch to END_GAME
                   j DO_USER                  # jump to DO_USER_2 if (isGameOver() != 0 && isDraw() != 0)
                        
   # Print Board When User Plays First and Wins
   EXIT_GAME: jal printGameBoard        # Function Call to printGameBoard
   
   # Print Appropriate Results
   END_GAME: beq $t1, $zero, PRINT_DRAW # if(isDraw() == 0), Branch to PRINT_DRAW
        li $t7, 'X'                     # $t7 = 'O'
             beq $s6, $t7, PRINT_LOST   # if(currPlayer == 'O'), Branch to PRINT_LOST
             j PRINT_WON                # jump to PRINT_WON
   
   # Print Message to Indicate That Game is a Draw
   PRINT_DRAW: li $v0, 4                # print_string syscall code = 4
          la $a0, draw                  # load the address of draw
          syscall                       # system call
          j EXIT                        # jump to EXIT
   
   # Print Message to Indicate That the User Has Lost the Game
   PRINT_LOST: li $v0, 4                # print_string syscall code = 4
          la $a0, lost                  # load the address of lost
          syscall                       # system call
          j EXIT                        # jump to EXIT
   
   # Print Message to Indicate That the User Has Won the Game
   PRINT_WON: li $v0, 4                 # print_string syscall code = 4
         la $a0, won                    # load the address of won
         syscall                        # system call
        
   # Update Register Values in Memory
   EXIT:
         sb $s6, currPlayer             # Update memory currPlayer from $s6
    
   # Exit the program by means of a syscall.
   li $v0, 10 # Sets $v0 to "10" to select exit syscall
   syscall    # Exit


   random_in_range_2:
	li $v0, 42
	li $a1, 2
	syscall
	move $v0, $a0	
	jr $ra
	
  
   	
printGameBoard:

   # Register Map for get_random:
   # $s2: ROW (global)
   # $s3: COL (global)
   # $s4: Base Address of gameBoard (global)
   # $t0: i
   # $t1: j
   # $t3: Address of &gameBoard[i][j]
        
   # Storing Current $t0 and $t1 in Stack
   addi $sp, $sp, -4                    # Adjust Stack Pointer
   sw $t0, 0($sp)                       # Save current $t0 (Loop Counter i in main)
   addi $sp, $sp, -4                    # Adjust Stack Pointer
   sw $t1, 0($sp)                       # Save current $t1 (Loop Counter j in main)
   
   # Initializing Registers
   li $t0, 0                            # i = 0
            
   # Print Board Column Numbers
   li $v0, 4                            # print_string syscall code = 4
   la $a0, board1                       # load the address of board1
   syscall                              # system call
   
   # Print Board Borders
   li $v0, 4                            # print_string syscall code = 4
   la $a0, board2                       # load the address of board1
   syscall                              # system call
   
   # Outer FOR-LOOP
   FOR_PRINT_i: bge $t0, $s2, RETURN    # if(i >= ROW(6)), Branch to RETURN
                li $t1, 0               # j = 0
   
      # Inner FOR-LOOP
      # Access gameBoard[i][j]
      FOR_PRINT_j: bge $t1, $s3, NWLINE # if (j >= COL(8)), Branch to NWLINE
              
              mul $t3, $t0, $s3         # $t3 = i * COL
              add $t3, $t3, $t1         # $t3 += j
              add $t3, $s4, $t3         # $t3 = &gameBoard[i][j] (Base + Offset)
              
              # Print Board Array
              li $v0, 11                # print_char syscall code = 11
              lb $a0, 0($t3)            # $a0 = gameBoard[i][j]
              syscall                   # system call
              
              # Print Space in Board for Formatting Purposes
              li $v0, 4                 # print_string syscall code = 4
              la $a0, board3            # load the address of board3
              syscall                   # system call
             
              addi $t1, $t1, 1          # j++
              j FOR_PRINT_j             # jump to FORPRINTj
   
      # Print New Line and Jump to Outer Loop
      NWLINE:  li $v0, 4                # print_string syscall code = 4
               la $a0, newline          # load the address of board3
               syscall                  # system call
               addi $t0, $t0, 1         # i++
               j FOR_PRINT_i            # jump to Outer Loop
   
   # Restore Register Values From Stack and Return to main
   # Print Board Borders
   RETURN: li $v0, 4                    # print_string syscall code = 4
           la $a0, board2               # load the address of board2
           syscall                      # system call
   
           # Restore Saved Register Values of $t0 and $t1 from Stack in Opposite Order
           lw $t1, 0($sp)               # Restore $t1 (Loop Counter j in main)
           addi $sp, $sp, 4             # Adjust Stack Pointer
           lw $t0, 0($sp)               # Restore $t0 (Loop Counter i in main)
           addi $sp, $sp, 4             # Adjust Stack Pointer
           jr $ra                       # Return to main
      
# Check if Either Player or Computer has Won the Game
# Detect if 5 Tokens are Connected Either Horizontally, Vertically, or Diagonally
# Requires 0 Arguments
isGameOver:

   # Register Map for isGameOver:

   # $s2: ROW (global)
   # $s3: COL (global)
   # $s4: Base Address of gameBoard (global)
   # $s5: Base Address of colSpaceTrack (global)
   # $s6: currPlayer (global)
   # $t0: i (Outer Loop Counter)
   # $t1: j (Middle Loop Counter)
   # $t2: k (Inner Loop Counter)
   # $t3: Value of gameBoard[i][j]
   # $t4: numHori (Number of Horizontal Matches)
   # $t5: numVert (Number of Vertical Matches)
   # $t6: numRD (Number of Right Diagonal Matches)
   # $t7: numLD (Number of Left Diagonal Matches)
   # $t8: 5 (Inner Loop Limit)
   # $t9: j + k, j - k
   # $s7: i + k
   # $a0: 2
   # $a1: 3
   
   # Initializing Registers
   li $t0, 0                                     # i = 0
   li $t1, 0                                     # j = 0
   li $t8, 4                                  # $t8 = 5
   li $a0, 2                                     # $a0 = 2
   li $a1, 2                                 # $a1 = 3
   
   # Outer For-Loop
   FOR_OUT: bge $t0, $s2, RETURN_CONT            # if (i >= ROW), Branch to RETURN_CONT
            li $t1, 0                            # j = 0
             
      # Middle For-Loop
      FOR_MID: bge $t1, $s3, INCi                # if (j >= COL), Branch to INCi
               li $t2, 0                         # k = 0
               li $t4, 0                         # numHori = 0
               li $t5, 0                         # numVert = 0
               li $t6, 0                         # numRD = 0
               li $t7, 0                         # numLD = 0

         FOR_IN: bge $t2, $t8, IS_WIN            # if(k >= 4), Branch to IS_WIN
                 add $s7, $t0, $t2               # $s7 = i + k
                 add $t9, $t1, $t2               # $t9 = j + k
                 
                 # Check if 5 Tokens are Connected Horizontally
                 IF_HOR:  bge $t1, $t8, IF_VER   # if(j >= 5), Branch to IF_VER
                          
                          # Access gameBoard[i][j + k]
                          # If gameBoard[i][j + k] != currPlayer, G
                          mul $t3, $t0, $s3      # $t3 = i * COL
                          add $t3, $t3, $t9      # $t3 += (j + k)
                          add $t3, $s4, $t3      # $t3 = &gameBoard[i][j + k] (Base + Offset)
                          lb $t3, 0($t3)         # $t3 = gameBoard[i][j + k]
                          bne $t3, $s6, IF_VER   # if(gameBoard[i][j + k] != currPlayer), Branch to IF_VER
                                   
                          # If gameBoard[i][j + k] = currPlayer, Increment numHori
                          addi $t4, $t4, 1       # numHori++
                        

                 # Check if 5 Tokens are Connected Vertically
                 IF_VER: bge $t0, $a0, IF_RD     # if(i >= 2), Branch to IF_RD
                        
                         # Access gameBoard[i + k][j]
                         # If gameBoard[i + k][j] != currPlayer, Break from Loop
                         mul $t3, $s7, $s3       # $t3 = (i + k) * COL
                         add $t3, $t3, $t1       # $t3 += j
                         add $t3, $s4, $t3       # $t3 = &gameBoard[i + k][j] (Base + Offset)
                         lb $t3, 0($t3)          # $t3 = gameBoard[i + k][j]
                         bne $t3, $s6, IF_RD     # if(gameBoard[i + k][j] != currPlayer), Branch to IF_RD
                                   
                         # If gameBoard[i + k][j] = currPlayer, Increment numVert
                         addi $t5, $t5, 1        # numVert++
                
                 # Check if 5 Tokens are Connected Right-Diagonally
                 IF_RD:  bge $t0, $a0, IF_LD     # if(i >= 2), Branch to IF_LD
                         bge $t1, $t8, IF_LD     # if(j >= 5), Branch to IF_LD
                         
                         # Access gameBoard[i + k][j + k]
                         # If gameBoard[i + k][j + k] != currPlayer, Break from Loop
                         mul $t3, $s7, $s3       # $t3 = (i + k) * COL
                         add $t3, $t3, $t9       # $t3 += (j + k)
                         add $t3, $s4, $t3       # $t3 = &gameBoard[i + k][j + k] (Base + Offset)
                         lb $t3, 0($t3)          # $t3 = gameBoard[i + k][j + k]
                         bne $t3, $s6, IF_LD     # if(gameBoard[i + k][j + k] != currPlayer), Branch to IF_LD
                                   
                         # If gameBoard[i + k][j + k] = currPlayer, Increment numRD
                         addi $t6, $t6, 1        # numRD++
                
                 # Check if 5 Tokens are Connected Left-Diagonally
                 IF_LD:  bge $t0, $a0, INCk      # if(i >= 2), Branch to INCk
                         ble $t1, $a1, INCk      # if(j <= 3), Branch to INCk
                         sub $t9, $t1, $t2       # $t9 = j - k
                         
                         # Access gameBoard[i + k][j - k]
                         # If gameBoard[i + k][j + k] != currPlayer, Break from Loop
                         mul $t3, $s7, $s3       # $t3 = (i + k) * COL
                         add $t3, $t3, $t9       # $t3 += (j - k)
                         add $t3, $s4, $t3       # $t3 = &gameBoard[i + k][j - k] (Base + Offset)
                         lb $t3, 0($t3)          # $t3 = gameBoard[i + k][j - k]
                         bne $t3, $s6, INCk      # if(gameBoard[i + k][j - k] != currPlayer), Branch to INCk
                                   
                         # If gameBoard[i + k][j - k] = currPlayer, Increment numLD, k, and Loop
                         addi $t7, $t7, 1        # numLD++
                         
                         # Increment k, Continue to Iterate in Inner Loop
                         INCk: addi $t2, $t2, 1  # k++
                               j FOR_IN          # jump to FOR_IN
                               

         # Check If There Are 5 Tokens in a Row
         # If Match Not Found, Continue to Iterate in Middle Loop
         IS_WIN: beq $t4, $t8, RETURN_WIN        # if(numHori == 5), Branch to RETURN_WIN
                 beq $t5, $t8, RETURN_WIN        # if(numVert == 5), Branch to RETURN_WIN
                 beq $t6, $t8, RETURN_WIN        # if(numRD == 5), Branch to RETURN_WIN
                 beq $t7, $t8, RETURN_WIN        # if(numLD == 5), Branch to RETURN_WIN
                 addi $t1, $t1, 1                # j++
                 j FOR_MID                       # jump to FOR_MID
      
      # Increment i, Continue to Iterate in Outer Loop
      INCi: addi $t0, $t0, 1                     # i++
            j FOR_OUT                            # jump to FOR_OUT
   
   # Return 1, if 5 Tokens in a Row is Not Detected
   RETURN_CONT: li $v0, 1                        # $v0 (Return Value) = 1
                jr $ra                           # Return to main

   
   # Return 0, if 5 Tokens in a Row is Detected
   RETURN_WIN: li $v0, 0                         # $v0 (Return Value) = 0
               jr $ra                            # Return to main


# Detect if Game is a Draw
# Consists of a For-Loop Which Traverses The Array To Check if Any '.' is Present
# If '.' is Not Present, Game is a Draw
# Requires 0 Arguments
isDraw:
        # Register Map for isDraw:
        # $s2: ROW (global)
   # $s3: COL (global)
   # $s4: Base Address of gameBoard (global)
        # $t3: Value of gameBoard[i][j]
        # $t4: '.'
        # $t5: i (Outer Loop Counter)
        # $t6: j (Inner Loop Counter)
        
        # Initializing Registers
        li $t4, '.'  # $t4 = '.'
        li $t5, 0    # i = 0
        
        # Operations for Check if any '.' is Present in gameBoard[i][j]
   # Outer FOR-LOOP
   FORi_DRAW: bge $t5, $s2, RETURN_D0    # if(i >= ROW(6)), Branch to RETURN_D0
              li $t6, 0                  # j = 0
   
      # Inner FOR-LOOP
      # Access gameBoard[i][j]
      FORj_DRAW: bge $t6, $s3, end_DRAW  # if (j >= COL(9)), Branch to end_DRAW
            mul $t3, $t5, $s3            # $t3 = i * COL
            add $t3, $t3, $t6            # $t3 += j
            add $t3, $s4, $t3            # $t3 = &gameBoard[i][j] (Base + Offset)
            lb $t3, 0($t3)               # $t3 = gameBoard[i][j]
            beq $t3, $t4, RETURN_D1      # if(gameBoard[i][j] == '.'), Branch to RETURN_D1
            addi $t6, $t6, 1             # j++
            j FORj_DRAW                  # jump to FORj_DRAW

   end_DRAW:  addi $t5, $t5, 1           # i++
              j FORi_DRAW                # jump to FORi_DRAW
   
   # Return 1 to Indicate That Game is a Draw
   RETURN_D0: li $v0, 0                  # $v0 (Return Value = 0)
              jr $ra                     # Return to main
              
   # Return 1 to Indicate That Game is Not a Draw
   RETURN_D1: li $v0, 1                  # $v0 (Return Value = 1)
              jr $ra                     # Return to main
       
# Validates and Inserts User's Move in Board
# Requires 0 Arguments
userMove:
        # Register Map for userMove
        # $s4: Base Address of gameBoard (global)
        # $s5: Base Address of colSpaceTrack (global)
        # $s6: currPlayer (global)
        # $t2: userCol
        # $t3: Value of gameBoard[i][j]
        # $t4: &colSpaceTrack[]
        # $t5: userCol - 1
        # $t6: 4
        # $t7: colSpaceTrack[]
        # $t8: 1
        # $t9: 7
        
        # Initializing Registers
        li $s6, 'X'                    # currPlayer = 'X'
        li $s7, '.'
        li $t6, 4                      # $t6 = 4
        li $t8, 1                   # $t8 = 1 ->check for bound
        li $t9, 7                # $t9 = 7
   	li $t1, 3		#$t1 = 3 -> check for error		
   # Print, Ask and Validate User's Move. Loop if Invalid.
   DO_UMOVE: li $v0, 4                 # print_string syscall code = 4
             la $a0, getCol            # load the address of getCol
             syscall                   # system call
             
             # Ask User to Enter Column Number Between 1-7
             li $v0, 5                 # read_int syscall code = 5
             syscall                   # system call
             move $t2, $v0             # $t2 (userCol) = $v0 (User Input)
             
             blt $t2, $t8, ERROR_U     # if(userCol < 1), Branch to ERROR_U
             bgt $t2, $t9, ERROR_U     # if(userCol > 7), Branch to ERROR_U
             
             # Operations for obtaining colSpaceTrack[userCol - 1]
             # Check if colSpaceTrack[userCol - 1] is less than 0
             addi $t5, $t2, -1         # $t5 = userCol - 1
             mul $t4, $t5, $t6         # $t4 = i(userCol - 1) * 4 (index times 4 bytes)
             add $t4, $s5, $t4         # $t4 = &colSpaceTrack[userCol - 1] (Base + Offset)
             lw $t7, 0($t4)            # $t7 = colSpaceTrack[userCol - 1]
             blt $t7, $zero, ERROR_U   # if(colSpaceTrack[userCol - 1] < 0), Branch to ERROR_U
             j BREAK_U                 # jump to BREAK_U if Above Condtions are Not Met
             
             # If Any of the Above Conditions are Not Satisfied, Print Error Message and Loop
             ERROR_U: li $v0, 4        # print_string syscall code = 4
                      la $a0, error    # load the address of error
                      syscall          # system call
                      addi $t1, $t1, -1
                      bgt $t1,0, DO_UMOVE       # jump to DO_UMOVE
		      beq  $t1, 0,PRINT_LOST
   # Set Next Available Row in userCol to 'X'
   # Store 'X' in gameBoard[colSpaceTrack[userCol - 1]][userCol]
   BREAK_U: mul $t3, $t7, $s3          # $t3 = $t7(colSpaceTrack[userCol - 1]) * COL
            add $t3, $t3, $t2          # $t3 += $t2 (userCol)
            add $t3, $s4, $t3          # $t3 = &gameBoard[i][j] (Base + Offset)
            sb $s6, 0($t3)             # gameBoard[i][0] = 'X' (Store 'X' in gameBoard[i][userCol])
   
            # Decrement by 1 to Indicate the Next Row in userCol Which is Available
            addi $t7, $t7, -1          # colSpaceTrack[userCol - 1]--
            sw $t7, 0($t4)             # Store $t7 in Array 	[userCol - 1]
            jr $ra                     # Return to main
    break_1:
    	   mul $t3, $t7, $s3          # $t3 = $t7(colSpaceTrack[userCol - 1]) * COL
            add $t3, $t3, $t2          # $t3 += $t2 (userCol)
            add $t3, $s4, $t3          # $t3 = &gameBoard[i][j] (Base + Offset)
            sb $s7, 0($t3)             # gameBoard[i][0] = 'X' (Store 'X' in gameBoard[i][userCol])
   
            # Decrement by 1 to Indicate the Next Row in userCol Which is Available
            addi $t7, $t7, 1          # colSpaceTrack[userCol - 1]--
            sw $t7, 0($t4)             # Store $t7 in Array 	[userCol - 1]
            jr $ra               # Return to main
# Randomly Generates a Valid Move For The Computer
# Requires 0 Arguments
    
U2Move:

        # Register Map for U2Move:
        # $s4: Base Address of gameBoard (global)
        # $s5: Base Address of colSpaceTrack (global)
        # $s6: currPlayer (global)
        # $a0: 1 (Lower Limit)
        # $a1: 7 (Upper Limit)
        # $t2: compCol
        # $t3: Value of gameBoard[i][j]
        # $t4: &colSpaceTrack[]
        # $t5: compCol - 1
        # $t6: 4
        # $t7: colSpaceTrack[]
        
        # Initializing Registers
        li $s6, 'O'                    # currPlayer = 'X'
        li $s7, '.'
        li $t6, 4                      # $t6 = 4
        li $t8, 1                   # $t8 = 1 ->check for bound
        li $t9, 7                # $t9 = 7
    	li $t1,3
        
   
        DO_U2_MOVE: 
        	li $v0, 4                 # print_string syscall code = 4
             la $a0, getCol2            # load the address of getCol
             syscall                   # system call
             
             # Ask User to Enter Column Number Between 1-7
             li $v0, 5                 # read_int syscall code = 5
             syscall                   # system call
             move $t2, $v0             # $t2 (userCol) = $v0 (User Input)
             
             #ask 4 reverse
             
             
             
             blt $t2, $t8, ERROR_U2     # if(userCol < 1), Branch to ERROR_U
             bgt $t2, $t9, ERROR_U2     # if(userCol > 7), Branch to ERROR_U
             
             # Operations for obtaining colSpaceTrack[userCol - 1]
             # Check if colSpaceTrack[userCol - 1] is less than 0
             addi $t5, $t2, -1         # $t5 = userCol - 1
             mul $t4, $t5, $t6         # $t4 = i(userCol - 1) * 4 (index times 4 bytes)
             add $t4, $s5, $t4         # $t4 = &colSpaceTrack[userCol - 1] (Base + Offset)
             lw $t7, 0($t4)            # $t7 = colSpaceTrack[userCol - 1]
             blt $t7, $zero, ERROR_U2   # if(colSpaceTrack[userCol - 1] < 0), Branch to ERROR_U
             j BREAK_U2               # jump to BREAK_U if Above Condtions are Not Met
             
             # If Any of the Above Conditions are Not Satisfied, Print Error Message and Loop
             ERROR_U2: li $v0, 4        # print_string syscall code = 4
                      la $a0, error    # load the address of error
                      syscall          # system call
                      addi $t1, $t1, -1
                      bgt $t1,0, DO_U2_MOVE       # jump to DO_UMOVE
		      beq  $t1, 0,PRINT_LOST
   # Set Next Available Row in userCol to 'X'
   # Store 'X' in gameBoard[colSpaceTrack[userCol - 1]][userCol]
   BREAK_U2: mul $t3, $t7, $s3          # $t3 = $t7(colSpaceTrack[userCol - 1]) * COL
            add $t3, $t3, $t2          # $t3 += $t2 (userCol)
            add $t3, $s4, $t3          # $t3 = &gameBoard[i][j] (Base + Offset)
            sb $s6, 0($t3)             # gameBoard[i][0] = 'X' (Store 'X' in gameBoard[i][userCol])
   
            # Decrement by 1 to Indicate the Next Row in userCol Which is Available
            addi $t7, $t7, -1          # colSpaceTrack[userCol - 1]--
            sw $t7, 0($t4)             # Store $t7 in Array 	[userCol - 1]
            jr $ra                     # Return to main
  break_2:
            mul $t3, $t7, $s3          # $t3 = $t7(colSpaceTrack[userCol - 1]) * COL
            add $t3, $t3, $t2          # $t3 += $t2 (userCol)
            add $t3, $s4, $t3          # $t3 = &gameBoard[i][j] (Base + Offset)
            sb $s7, 0($t3)             # gameBoard[i][0] = 'X' (Store 'X' in gameBoard[i][userCol])
   
            # Decrement by 1 to Indicate the Next Row in userCol Which is Available
            addi $t7, $t7, 1          # colSpaceTrack[userCol - 1]--
            sw $t7, 0($t4)             # Store $t7 in Array 	[userCol - 1]
            jr $ra                  # Return to main
            
        jr $ra                             # Return to main

# The label 'main' represents the starting point
# Generates two random numbers and computes the GCD of them


  
