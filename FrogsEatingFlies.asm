##########
# cturgeon
# frogs eating flies game
# final project for COMP541
#########

.data 0x10010000 			# Start of data memory
fliesX: .word 0x00, 0x0c, 0x1c, 0x07, 0x1f, 0x1d, 0x06, 0x1c
fliesY:	.word 0x04, 0x00, 0x10, 0x06, 0x0d, 0x04, 0x09, 0x12
direction: .word 0x01, 0x04, 0x01, 0x02, 0x03, 0x01, 0x03, 0x04

randomX: .word 0x00
randomY: .word 0x00
randomdirection: .word 0x00
random_const:	.word 0x0000	# contains a counting variable

frog1: .word 0x05, 0x0f		#initialize frog1 to 5, 15 coords
frog1_sprite: .word 0x02
frog2: .word 0x23, 0x0f		#initialize frog2 to 35, 15 coords
frog2_sprite: .word 0x07

frog1_score: .word 0x00
frog2_score: .word 0x00

# A4, B4, C5
music_notes: .word 227273, 202478, 191113
music_player: .word 2, 2, 2, 2, 0, 1, 2, 0, 1
music_iteration: .word 0x00
playing_music: .word 0x00

.text 0x00400000			# Start of instruction memory

main:
	lui $sp, 0x1001		# Initialize stack pointer to the 64th location above start of data
	ori $sp, $sp, 0x1000	# top of the stack is the word at address [0x10010ffc - 0x10010fff]
	
game_loop:
	jal	get_score
	
	jal 	animate_flies		# does all the things for the flies
	jal	animate_flies		# double the speed?
	
	lw	$t0, music_iteration	# continually add 1 to music_iteration on every game_loop
	addi	$t0, $t0, 1
	sw	$t0, music_iteration
	jal	play_iteration
	
	li	$t4, 4
	
	
	lw	$a0, frog1_sprite	# draw player 1 here	
	lw 	$a1, frog1($0)		# get x coord
	lw 	$a2, frog1($t4)		# get y coord
	jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y
	
	lw	$a0, frog2_sprite	# draw player 2 here
	lw 	$a1, frog2($0)		# get x coord
	lw 	$a2, frog2($t4)		# get y coord
	jal	putChar_atXY 		# $a0 is char, $a1 is X, $a2 is Y
	
	
	addi	$a0, $0, 4
	jal	pause_and_getkey_2player     # responsive 2-player input during 0.1s pause

	move	$s5, $v0                # save keys in $s registers to protect them from called procedures
	move	$s6, $v1

PLAYER1:
	beq	$s5, $0, PLAYER2	# 0 means no valid key
	
	move 	$a0, $s5
	lw 	$a1, frog1($0)
	lw 	$a2, frog1($t4)
	jal	move_player             # call move_player with PLAYER 1’s position and key
	
	li 	$a0, 0			# erase char
	jal	putChar_atXY
	
	sw 	$v0, frog1($0)
	sw 	$v1, frog1($t4)
	
	lw	$t0, frog1_score
	beq	$t0, 15, end1
	

PLAYER2:
	beq	$s6, $0, game_loop	# 0 means no valid key
	
	move 	$a0, $s6
	lw 	$a1, frog2($0)
	lw 	$a2, frog2($t4)
	jal	move_player1             # call move_player with PLAYER 2’s position and key
	
	li 	$a0, 0			# erase char
	jal	putChar_atXY
	
	sw 	$v0, frog2($0)
	sw 	$v1, frog2($t4)
	
	lw	$t0, frog2_score
	beq	$t0, 15, end1

	j	game_loop            # go back to start of animation loop
	###############################
	# END using infinite loop     #
	###############################
end1:
	jal 	play_game_over_music
	jal	sound_off
end:	
	jal	sound_off
	j	end          	# infinite loop "trap" because we don't have syscalls to exit
	
#########################################
# game over music
#######################################	
play_game_over_music:
	addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
    	sw      $ra, 4($sp)         # Save $ra
    	sw      $fp, 0($sp)         # Save $fp
    	addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame
         
        li	$t0, 0		# set i to zero
        
	over_music_Lfor:
		sll 	$t4, $t0, 2	# $t4 is i*4
		lw	$t5, music_player($t4)	# note at music_notes[i]
		sll	$t5, $t5, 2	# shift it over to play the right notes
		lw	$a0, music_notes($t5)
		jal	put_sound
		
		li	$a0, 18
		jal	pause
		jal	sound_off
		li	$a0, 2
		jal	pause
		
		
	                   
		addi	$t0, $t0, 1	# i++
 		slti	$t6, $t0, 9	# $t6 = (i<9)
 		bne	$t6, $0, over_music_Lfor	# $t6 is true
 	
 	jal	sound_off
 	       	
 	addi    $sp, $fp, 4     # Restore $sp
    	lw      $ra, 0($fp)     # Restore $ra
   	lw      $fp, -4($fp)    # Restore $fp
  	jr      $ra             # Return from procedure	
	
######################################
# plays a simple jingle everytime a fly is caught
######################################
play_iteration:
	addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
    	sw      $ra, 4($sp)         # Save $ra
    	sw      $fp, 0($sp)         # Save $fp
    	addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame
                    
       	lw	$t1, playing_music
	beq	$t1, 0, end_iteration	# if not playing music end
                    
	lw	$t0, music_iteration
	slti	$t1, $t0, 8		
	bne	$t1, 1, music_200	# if not < 100
	# play note 0
 		lw	$a0, music_notes($t0)
 		jal	put_sound
 		j	end_iteration
music_200:
	slti 	$t1, $t0, 13
	bne	$t1, 1, music_300
	# play note 4
		li	$t1, 1
		sll	$t1, $t1, 8
		lw	$a0, music_notes($t1)
		jal	put_sound
		j	end_iteration
music_300:
	slti	$t1, $t0, 17
	bne	$t1, 1, music_400
	# play note 3
		li	$t1, 1
		sll	$t1, $t1, 6
		lw	$a0, music_notes($t1)
		jal	put_sound
		j	end_iteration
	
	
music_400: #turn sound off and reset music iterations
	sw	$0, playing_music
	sw	$0, music_iteration
	jal	sound_off
	
end_iteration:
    	addi    $sp, $fp, 4     # Restore $sp
    	lw      $ra, 0($fp)     # Restore $ra
   	lw      $fp, -4($fp)    # Restore $fp
  	jr      $ra             # Return from procedure	
  		

##############################################
# gets the score for the frogs and stores them in data
##############################################3	
get_score:
	addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
    	sw      $ra, 4($sp)         # Save $ra
    	sw      $fp, 0($sp)         # Save $fp
    	addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame
                    
	lw 	$a0, frog1_score                    # load frog1 into lower bits at $a0
 	sll 	$a0, $a0, 16                            # move to upper bits                    # how much do I shift for segment display??
 	lw 	$t0, frog2_score                   # load frog2 into temp
 	or 	$a0, $a0, $t0                        # put frog1 into upper bits and frog2 into lower bits
 	jal 	put_seg
 	
 	lw 	$a0, frog1_score                    # load frog1 into lower bits at $a0
 	sll 	$a0, $a0, 9                            # move to upper bits                    # how much do I shift for segment display??
 	lw 	$t0, frog2_score                   # load frog2 into temp
 	sll	$t0, $t0, 4				# to move it under the seg display
 	or 	$a0, $a0, $t0                        # put frog1 into upper bits and frog2 into lower bits
	jal	put_leds
	
    	addi    $sp, $fp, 4     # Restore $sp
    	lw      $ra, 0($fp)     # Restore $ra
   	lw      $fp, -4($fp)    # Restore $fp
  	jr      $ra             # Return from procedure	
	
####################################3
# plays music notes in array order
####################################3
play_music:
	addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
    	sw      $ra, 4($sp)         # Save $ra
    	sw      $fp, 0($sp)         # Save $fp
    	addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame
            
        sw	$0, music_iteration    
        li	$t0, 1
        sw	$t0, playing_music
        	
    	addi    $sp, $fp, 4     # Restore $sp
    	lw      $ra, 0($fp)     # Restore $ra
   	lw      $fp, -4($fp)    # Restore $fp
  	jr      $ra             # Return from procedure	
	
######################################
# moves the frogs
######################################
move_player:
    	addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
    	sw      $ra, 4($sp)         # Save $ra
    	sw      $fp, 0($sp)         # Save $fp
    	addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame
                    
		move $v0, $a1
		move $v1, $a2

key1:
	bne	$a0, 1, key2
	addi 	$v0, $v0, -1 		# move left
	li	$t0, 2
	sw	$t0, frog1_sprite
	slt	$1, $v0, $0		# make sure X >= 0
	beq	$1, $0, done_moving
	li	$v0, 0			# else, set X to 0
	j	done_moving

key2:
	bne	$a0, 2, key3
	addi 	$v0, $v0, 1 		# move right
	li	$t0, 3
	sw	$t0, frog1_sprite
	slti 	$1, $v0, 40		# make sure X < 40
	bne	$1, $0, done_moving
	li	$v0, 39			# else, set X to 39
	j	done_moving

key3:
	bne	$a0, 3, key4
	addi 	$v1, $v1, -1 		# move up
	li	$t0, 4
	sw	$t0, frog1_sprite
	slt	$1, $v1, $0		# make sure Y >= 0
	beq	$1, $0, done_moving
	li	$v1, 0			# else, set Y to 0
	j	done_moving

key4:
	bne	$a0, 4, done_moving	# read key again
	li	$t0, 5
	sw	$t0, frog1_sprite
	addi 	$v1, $v1, 1 		# move down
	slti 	$1, $v1, 30		# make sure Y < 30
	bne	$1, $0, done_moving
	li	$v1, 29			# else, set Y to 29
	
done_moving:
    	addi    $sp, $fp, 4     # Restore $sp
    	lw      $ra, 0($fp)     # Restore $ra
   	lw      $fp, -4($fp)    # Restore $fp
  	jr      $ra             # Return from procedure
  	
 ######################################
# moves the frogs
######################################
move_player1:
    	addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
    	sw      $ra, 4($sp)         # Save $ra
    	sw      $fp, 0($sp)         # Save $fp
    	addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame
                    
		move $v0, $a1
		move $v1, $a2

key11:
	bne	$a0, 1, key21
	li	$t0, 6
	sw	$t0, frog2_sprite
	addi 	$v0, $v0, -1 		# move left
	slt	$1, $v0, $0		# make sure X >= 0
	beq	$1, $0, done_moving1
	li	$v0, 0			# else, set X to 0
	j	done_moving1

key21:
	bne	$a0, 2, key31
	li	$t0, 7
	sw	$t0, frog2_sprite
	addi 	$v0, $v0, 1 		# move right
	slti 	$1, $v0, 40		# make sure X < 40
	bne	$1, $0, done_moving1
	li	$v0, 39			# else, set X to 39
	j	done_moving1

key31:
	bne	$a0, 3, key41
	li	$t0, 8
	sw	$t0, frog2_sprite
	addi 	$v1, $v1, -1 		# move up
	slt	$1, $v1, $0		# make sure Y >= 0
	beq	$1, $0, done_moving1
	li	$v1, 0			# else, set Y to 0
	j	done_moving1

key41:
	bne	$a0, 4, done_moving1	# read key again
	li	$t0, 9
	sw	$t0, frog2_sprite
	addi 	$v1, $v1, 1 		# move down
	slti 	$1, $v1, 30		# make sure Y < 30
	bne	$1, $0, done_moving1
	li	$v1, 29			# else, set Y to 29
	
done_moving1:
    	addi    $sp, $fp, 4     # Restore $sp
    	lw      $ra, 0($fp)     # Restore $ra
   	lw      $fp, -4($fp)    # Restore $fp
  	jr      $ra             # Return from procedure
	
####################################################
# helps with random number enerator
####################################################	
add_to_constant:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	lw	$t1, random_const	# load in a constant that keeps prime number additions
	addi	$t1, $t1, 7		# add prime number greater than 30
	
	slti	$t0, $t1, 30
	beq	$t0, 1, set_value
	addi	$t1, $t1, -30
	
	slti	$t0, $t1, 30
	beq	$t0, 1, set_value
	addi	$t1, $t1,  -30
	
set_value:
	sw	$t1, random_const	# stores the added prime number
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra            # Return from procedure	
random_direction:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	jal	add_to_constant
	
	lw	$t1, random_const
	
	sll	$t0, $t1, 28	# shift so only 2 bits are kept (0-3)
	srl	$t0, $t0, 28	# reset it back
	addi	$t0, $t0, 1	# add 1 to result
	sw	$t0, randomdirection	# set direction to result of $t0
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra            # Return from procedure
random_Y:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	jal	add_to_constant

	lw	$t1, random_const

	sw	$t1, randomY	# set fliesD to result of $t0
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra            # Return from procedure
random_X:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)

	jal	add_to_constant

	lw	$t1, random_const
	
	sll	$t0, $t1, 28	# shift so only 4 bits are kept	(0-15)
	srl	$t0, $t0, 28	# reset it back
	addi	$t0, $t0, 12	# add 7 to result	to contain in middle on x coords
	sw	$t0, randomX	# set fliesD to result of $t0
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra            # Return from procedure
	
	
####################################################	
# moves all the flies
####################################################
animate_flies:									
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
 	add 	$t3, $0, $0	# $t3 is i
 				
 	animate_Lfor: 
 		sll 	$t4, $t3, 2	# $t4 is i*4
 		
 		li	$a0, 0		# put background in old location
 		lw	$a1, fliesX($t4)	# $a1 is fliesX[i]
 		lw	$a2, fliesY($t4)	# $a2 is fliesY[i]
 		jal	putChar_atXY
 		
 		lw	$a0, direction($t4)
 		jal	move_flies	# in: $a0, $a1, $a2  out: $v0, $v1 is new XY
 		
		move	$a1, $v0	# new x location fly wants to move to
		move	$a2, $v1	# new y location fly wants to move to
 
 collision_detection:
	jal	getChar_atXY	# gets the char at $a1, $a2 and puts it at $v0
	beq	$v0, 0, no_collision
	beq	$v0, 1, no_collision
	
collision_frog2:	
	slti	$t0, $v0, 6
	bne	$t0, 0, collision_frog1		# if not frog2 go to frog1
	lw	$t0, frog2_score
	addi	$t0, $t0, 1	# add 1 point to frog2
	sw	$t0, frog2_score
	jal	play_music
	j	add_random_fly
	
collision_frog1:
	lw	$t0, frog1_score
	addi	$t0, $t0, 1	# add 1 point to frog1
	sw	$t0, frog1_score
	jal	play_music
	j	add_random_fly
	
add_random_fly:
	jal	random_X	# generate values for random X, Y, direction
	jal	random_Y
	jal	random_direction
	
	li	$a0, 1		# put fly into new location
	lw	$a1, randomX	# random x coord loaded into $a1
	lw	$a2, randomY	# random y coord loaded into $a2
	jal	putChar_atXY
	
	sw	$a1, fliesX($t4)
	sw	$a2, fliesY($t4)
	lw	$a3, randomdirection
	sw	$a3, direction($t4)
	
	j	next_loop
no_collision:

 		sw	$a0, direction($t4)
 		li	$a0, 1		#put flies in new location
 		jal	putChar_atXY
 		
 		sw	$a1, fliesX($t4)	# $a1 is fliesX[i]
 		sw	$a2, fliesY($t4)	# $a2 is fliesY[i]
 		
 	next_loop:		
 		addi	$t3, $t3, 1	# i++
 		slti	$t5, $t3, 8	# $t5 = (i<8)
 		bne	$t5, $0, animate_Lfor	# $t5 is true?
 			
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra            # Return from procedure
	
######################
# $a0: direction
# $a1: old x coord
# $a2: old y coord
# return values
# $v0: new x coord
# $v1: new y coord
######################
move_flies:
    	addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
    	sw      $ra, 4($sp)         # Save $ra
    	sw      $fp, 0($sp)         # Save $fp
    	addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame
                    
		move $v0, $a1
		move $v1, $a2

move_fly1:
	bne	$a0, 1, move_fly2
	addi 	$v0, $v0, -1 		# move left
	slt	$1, $v0, $0		# make sure X >= 0
	beq	$1, $0, done_moving_fly
	li	$v0, 0			# else, set X to 0
	li	$a0, 2
	j	move_fly2

move_fly2:
	bne	$a0, 2, move_fly3
	addi 	$v0, $v0, 1 		# move right
	slti 	$1, $v0, 40		# make sure X < 40
	bne	$1, $0, done_moving_fly
	li	$v0, 39			# else, set X to 39
	li	$a0, 1
	j	move_fly1

move_fly3:
	bne	$a0, 3, move_fly4
	addi 	$v1, $v1, -1 		# move up
	slt	$1, $v1, $0		# make sure Y >= 0
	beq	$1, $0, done_moving_fly
	li	$v1, 0			# else, set Y to 0
	li	$a0, 4
	j	move_fly4

move_fly4:
	addi 	$v1, $v1, 1 		# move down
	slti 	$1, $v1, 30		# make sure Y < 30
	bne	$1, $0, done_moving_fly
	li	$v1, 29			# else, set Y to 29
	li	$a0, 3
	j	move_fly3

done_moving_fly:
	
    	addi    $sp, $fp, 4     # Restore $sp
    	lw      $ra, 0($fp)     # Restore $ra
   	lw      $fp, -4($fp)    # Restore $fp
  	jr      $ra             # Return from procedure
  	
 # ================================================================================
 
  	 	
.include "procs_board.asm"  
#.include "procs_mars.asm"   	
	
	
