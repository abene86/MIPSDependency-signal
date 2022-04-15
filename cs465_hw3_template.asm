#############################################################
# NOTE: this is the provided TEMPLATE as your required 
#		starting point of HW3 MIPS programming part.
#		This is the only file you should change and submit.
#
# CS465-001 S2022
# HW3 
#############################################################

#############################################################
# PUT YOUR TEAM INFO HERE
# NAME Abenezer Gebeyehu
# G#01281469
# NAME 2
# G# 2
#############################################################

#############################################################
# DESCRIPTION  
#
# PUT YOUR ALGORITHM DESCRIPTION HERE
#############################################################

#############################################################
# Data segment
#############################################################

.data 
	PROMPT_N: .asciiz "How many instructions to process (valid range: [1,10])? "
	PROMPT_SEQUENCE: .asciiz "Please input instruction sequence (one per line):"
	PROMPT_NEXT: .asciiz "\nNext instruction:"
	ERROR_N: .asciiz "Incorrect number of instructions\n"

	PROMPT_HEAD: .asciiz "I"
	PROMPT_CONTROL: .asciiz ": Control signals: "
	PROMPT_DEP: .asciiz "\nDependences: "
	PROMPT_NONE: .asciiz "None"
	
	PROMPT_DIVIDER: .asciiz "\n-------------------------------------------\n"

	NEWLINE: .asciiz "\n"
	SPACE: .asciiz " "
	ZERO: .asciiz "0"
	TEN: .asciiz "A"


	.align 3
	INPUT: .space 9
	
	.align 3
	LINES: .word 0:10 # an array of 10 integers(words), each is initialized to be 0
	.align 3
	DOUBLEOFFSET: .word 0, 1, 2, 3
    	.align 3
	SINGLEOFFSET: .word 0, 1
	.align 3
	LABELNUMBER: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	
	.align 3 
	rdArr: .word 33:10 
	.align 3 
	rtArr: .word 33:10 
	.align 3 
	rsArr: .word 33:10 
		

#############################################################
# Code segment
#############################################################

.text

#############################################################
# provided macro: print_int
#############################################################
# %x: value to be printed	

.macro print_int (%x)
	li $v0, 1
	add $a0, $zero, %x
	syscall
	.end_macro

#############################################################
# main 
#############################################################


main:

	# print out message asking for N (number of instructions to process)
	####################################################################
	la $a0, PROMPT_N
	li $v0, 4
	syscall 
	
	# read in an integer N
	####################################################################
	li $v0, 5
	syscall 
	addi $s0, $v0, 0  #keep N in $s0
	
	# verify input N 
	####################################################################
	ble $s0, $0, error_report #if N<=0, error
	bgt $s0, 10, error_report #if N>10, error 
	
	# print out prompt to ask for a sequence
	####################################################################
	la $a0, PROMPT_SEQUENCE	
	li $v0, 4
	syscall 
	
	# initialization to prepare for the loop
	####################################################################
	li $s2, 0 # loop index i=0
	la $s1, LINES #stating addr of array of instructions

	# loop of reading in N strings
	####################################################################
	Loop: 
		# Print out prompt for next instruction
		####################################################################
		la $a0, PROMPT_NEXT 
		li $v0, 4
		syscall 												

		# read in one string and store in INPUT
		####################################################################
		la $a0, INPUT
		li $a1, 9
		li $v0, 8
		syscall 

		# call atoi() to extract the numeric value from INPUT
		####################################################################
		la $a0, INPUT
		jal atoi

		#save the return of atoi() in array LINES[i]
		####################################################################
		
		sw $v0, 0($s1)		

		# update and check loop condition
		####################################################################
		addi $s1, $s1, 4 # offset of next array item																																
		addi $s2, $s2, 1 # i++
		blt $s2, $s0, Loop # i<N==>loop back
		
	####################################################################
	# end of loop of reading in N strings
	####################################################################

	####################################################################
	# TODO: add your code here to process the instruction sequence,
	#       report control signals, and true data dependences
	####################################################################
	li $s2, 0    #initializes the index to 0
	la $s1, LINES
	la $s6, rdArr
	la $s7, rtArr
	la $t7, rsArr
	Compare:
		slt $t1, $s2, $s0   #checks the intial compare of 0 < N
		beq $t1, $0, endLoop
	While: 
		li $s4, 0
		sll $t4, $s2, 2          #index*4
		add $t1, $t4, $s1		 #index+address
		lw  $t2  0($t1)          #Lines[index]
		addi $a0, $t2, 0
		jal ret_Type
		addi $s3, $v0, 0
		bne $s3, $zero, I_Type
		li $s5, 8
		lw $s5, DOUBLEOFFSET($s5)
		sll $s5, $s5, 9
		or $s4, $s4, $s5
		li $s5, 4
		lw $s5, DOUBLEOFFSET($s5)
		sll $s5, $s5, 7
		or $s4, $s4, $s5
		li $s5, 4
		lw $s5, SINGLEOFFSET($s5)
		or $s4, $s4, $s5
		j printSignal
		I_Type:

		printSignal:
			la $a0, NEWLINE
			li $v0, 4
			syscall  
			la $a0, LABEL_I
			li $v0, 4
			syscall
			la $t3, LABELNUMBER
			add $t4, $t3, $t4
			sw $a0, 0($t4)
			li $v0, 1
			syscall
			la $a0, PROMPT_CONTROL	
			li $v0, 4
			syscall 
			move    $a0, $s4                 # put number into correct reg for syscall
			li      $v0, 34                  # syscall number for "print hex"
			syscall  
			la $a0, NEWLINE
			li $v0, 4
			syscall  
			
			sll $t4, $s2, 2          	# index*4
			add $t2 $t4, $s6		# index+address for rdArr
			add $t3, $t4, $s7		# index+address for rtArr
			add $t4, $t4, $t7		# index+address for rsArr
			
		R_decode:
			lw  $t5  0($t1)          	# Lines[index]
			srl $t5, $t5, 11
			and $t5, $t5, 0x1F		# get 5-bit rd
			sw $t5, 0($t2)			# save rd of the instruction into the rdArr
			
			lw  $t5  0($t1)          	# Lines[index]
			srl $t5, $t5, 16
			and $t5, $t5, 0x1F		# get 5-bit rt
			sw $t5, 0($t3)			# save rt of the instruction into the rtArr
			
			lw  $t5  0($t1)          	# Lines[index]
			srl $t5, $t5, 21
			and $t5, $t5, 0x1F		# get 5-bit rs
			sw $t5, 0($t4)			# save rs of the instruction into the rsArr
			
			beq $s2, $0, print_none
			bne $s2, $0, compare_arr
			j cont
		
		compare_arr:
			li $s3, 0 				# index = 0
			slt $t6, $s3, $s2   			# checks the inner index < current index
			beq $t6, $0, cont
		check_dependence:	
			sll $t4, $s3, 2
			add $t4, $t4, $s6			# index+address for rdArr
			lw $t4, 0($t4)				# rd for previous instruction
			
			while_arr:
				addi $t5, $t5, 0 		# current rs
				beq $t5, $t4,  print_dependence
				lw $t5, 0($t3)			# current rt
				beq $t5, $t4,  print_dependence
				
				addi $s3, $s3, 1
				j compare_arr
		
		print_none:
			la $a0, PROMPT_DEP
			li $v0, 4
			syscall 
			la $a0, PROMPT_NONE	
			li $v0, 4
			syscall 
			la $a0, PROMPT_DIVIDER	
			li $v0, 4
			syscall 
			
	cont:
		addi $s2, $s2, 1
		j Compare
	endLoop:
###########################################
#  exit 
###########################################
exit:
	li $v0, 10
	syscall

error_report:
	la $a0, ERROR_N
	li $v0, 4
	syscall # Print out error message for incorrect N 
	j exit

#############################################################
# TODO: fill in the details of atoi()
#############################################################
# atoi: 
#############################################################
atoi:
	addi $sp, $sp, -12
	sw $s1, 0($sp)
	sw $s2, 4($sp)
	sw $t4, 8($sp)
    li $t0, 0              # set the index to 0 for do while loop
	li $t1, 0              # set sum to 0 for integer calcualtion
	li $t2, 7		       # set value power of the highest order bit for 16^? calculation
	li $t3, '/'		       # set the immediate value of $s1 to represent '/' which comes before '0'
	li $t4, ':'		       # set the immediate value of $t3 to represent ':' which comes after '9'
	li $a1, 8
	add $t5, $zero,  $a0	 # load the base address our input of hex value into $t1
    do_while:  			      
    	add $s1, $t5, $t0	          # we add $t0 which is our index to our base address
    	lb  $s2, 0($s1)		       	  # we then lb to load byte character into $s0 
	slt $t6, $t3, $s2            # we check if the value of $s0 is greater than $s1('/')which is ascii value interm of integer as 47
	slt $t7, $s2, $t4	          # we check if the value of $s0 is less than $t3 (':') which is ascii value interm of integer as 58
	beq $t6, $0, checkoption2     # if  slt yield zero we do our secound check from A to F
	beq $t7, $0, checkoption2     # if  slt yield zero we do our secound check from A to F
	sub $s2, $s2, 48	          # after it passes the check, we subtract 48 to get the actual integer value
	mul $s5, $t2, 4		      # we know based on the multiplicative property we can have 2^(4*2) to represent 16^2 so here we mulitply 4* the value of $s4
	sllv $s2,$s2, $s5		      # we then do left shift by variable to do the actual integervalue*2^(value *4)
	add $t1, $t1, $s2		      # we then add to sum+=value
	j Incr			              # we jump to incr 
    checkoption2:	
    	sub $s2, $s2, 55
    	mul  $s5, $t2, 4		      # we know based on the multiplicative property  of powers we can have 2^(4*2) to represent 16^2
	sllv $s2,$s2, $s5	          # we are going to use the multipied power to use for shifting to the left
	add $t1, $t1, $s2
    Incr:
    	add $t0, $t0, 1 	  # index++
    	sub  $t2, $t2,1		  # subtract one from $s4 which hold the highest power 16^? value
	slt  $s6, $t0, $a1       # index < 9 jump while
	bne  $s6, $0, do_while
	move $v0,$t1
	
	lw $s1, 0($sp)
	lw $s2, 4($sp)
	lw $t4, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	


#############################################################
# Feel free to define additional helper functions
#############################################################
ret_Type:
	addi $sp, $sp, -8
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	li $t1, 0x3F
	sll $t1, $t1, 26
	addi $t2, $a0, 0
	and $t2, $t2, $t1
	bne $t2, $zero, set
	li $v0, 0
	j endret
	set:
		li $v0, 1
	endret:	
		lw $t1, 0($sp)
		lw  $ra, 4($sp)
		add $sp, $sp, 8
	jr $ra



	
#############################################################
# provided subroutine: print_string()
#############################################################
# $a0 set as the address of string to be printed
print_string:
	li $v0, 4
	syscall	
	jr $ra

	
	
#############################################################
# provided subroutine: print_dependence()
#############################################################
# $a0 set as the reg number; 
# $a1 set as index of producer instruction
# $a2 set as index of consumer instruction

# e.g. (24, I1, I2) will be printed out by the following sequence:
# addi $a0, $0, 24
# addi $a1, $0, 1
# addi $a2, $0, 2
# jal print_dependence



.data
	LP: .asciiz "("
	RP: .asciiz ")"
	COMMA: 	.asciiz ", "
	LABEL_I: .asciiz "I"

.text:
print_dependence:
	
	addi $sp, $sp, -16	#save arguments and $ra
	sw $ra, 12($sp)
	sw $a0, 8($sp)
	sw $a1, 4($sp)
	sw $a2, 0($sp)
		
	la $a0, LP	#print start
	jal print_string
	
	lw $a0, 8($sp)	#print reg num
	print_int($a0)
	
	la $a0, COMMA	#print comma
	jal print_string
	
	la $a0, LABEL_I	#print I
	jal print_string
	
	lw $a0, 4($sp)	#print producer
	print_int($a0)
	
	la $a0, COMMA	#print comma
	jal print_string
	
	la $a0, LABEL_I	#print I
	jal print_string
	
	lw $a0, 0($sp)	#print consumer
	print_int($a0)
	
	la $a0, RP	#print start
	jal print_string

	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra
