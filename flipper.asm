#name: Rayan Bouamrane
#studentID: 260788250

.data
#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "flipped.pgm"	#used as output
axis: .word 1 # 0=flip around x-axis....1=flip around y-axis
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048

#any extra data you specify MUST be after this line 
header: 	.asciiz 	"P2\n24 7\n15\n" 
arr: 		.word 168	#24 * 7	
errorm: 	.asciiz 	"There was an error reading or writing the file"

	.text
	.globl main

main:
    	la $a0,input		#readfile takes $a0 as input
    	jal readfile


	la $a0,buffer		#$a0 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a1 will specify the buffer that will hold the flipped array.
	la $a2,axis        	#either 0 or 1, specifying x or y axis flip accordingly
	jal flip

	la $a0, output		#writefile will take $a0 as file location we wish to write to.
	la $a1,newbuff		#$a1 takes location of what data we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:

	li $v0, 13		# system call to open file
	li $a1, 0            	# flag for reading
	syscall			# $v0 stores file descriptor 
	blt $v0, $0, errorm	
	
	add $s0, $v0, $0	# file descriptor moved to $s0
	li $v0, 14		# system call to read file
	add $a0, $s0, $0	# $a0 must store file descriptor
	la $a1, buffer		# $a1 must store input buffer address
	li $a2, 2048		# $a2 stores hardcoded maximum number of character to be read
	syscall			
	blt $v0, $0, errorm		

	li $v0, 16		# system call to close file
	add $a0, $s0, $0	# file descriptor stored in $a0
	syscall
	jr $ra

flip:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal createArr		# creates array called arr
	lw $ra, 0($sp)		# arr holds integers from buffer
	addi $sp, $sp, 4	

	add $s0, $a1, $0	# $s0 stores point of newBuff
	lw $t1, 0($a2)		# $t1 which axis will be flipped
	la $s1, arr		# $s1 stores the pointer to arr
	beq $t1, 1, yFlip	# jump to yFlip if $t1 equals 1, else proceed downwards

xFlip:	addi $s2, $0, 6		# coordinate i

xLoopi:
	add $s3, $0, $0		# coordinate j

xLoopj: 
	mul $t3, $s2, 24	
	add $t3, $t3, $s3	
	mul $t3, $t3, 4		# $t3 equals 4 X ((24 X i) + j)
	add $t4, $s1, $t3	# $t4 points to int in arr
	lw $t2, 0($t4)		
	bgt $t2, 9, xMod	# call xMod method if int greater than 9
	addi $t2, $t2, 48	# ints in ASCII start at 48, convert to ASCII
	sb $t2, 0($s0)
	li $t2, ' '		
	sb $t2, 1($s0)
	addi $s0, $s0, 2	# increment newBuff pointer
	j xHalt
	
xMod:	div $t4, $t2, 10	
	rem $t3, $t2, 10	# $t0 stores remainder of division		
	addi $t3, $t3, 48	
	addi $t4, $t4, 48	
	sb $t4, 0($s0)
	sb $t3, 1($s0)
	li $t2, ' '		
	sb $t2, 2($s0)
	addi $s0, $s0, 3	# increment newBuff pointer
	
xHalt:
	addi $s3, $s3, 1	# increment j
	blt $s3, 24, xLoopj	# if j<24, j needs to looped then incremented
	addi $s2, $s2, -1	# decrement i
	bgez $s2, xLoopi	# if i>=0, i should loop
	jr $ra
				
				# Instructions below work identically to
				# their x counterpart
yFlip:
	add $s2, $0,$0		
yLoopi:
	addi $s3, $0, 23	
yLoopj: 
	mul $t3, $s2, 24	
	add $t3, $t3, $s3	
	mul $t3, $t3, 4		
	add $t4, $s1, $t3	
	lw $t2, 0($t4)		
	bgt $t2, 9, yMod	
	addi $t2, $t2, 48	
	sb $t2, 0($s0)
	li $t2, ' '		
	sb $t2, 1($s0)
	addi $s0, $s0,2
	j yHalt
	
yMod:	div $t4, $t2, 10	
	rem $t3, $t2, 10		
	addi $t3, $t3, 48	
	addi $t4, $t4, 48	
	sb $t4, 0($s0)
	sb $t3, 1($s0)
	li $t2, ' '		
	sb $t2, 2($s0)
	addi $s0, $s0, 3	
	
yHalt:
	addi $s3,$s3,-1		
	bgez $s3, yLoopj	
	li $t2, ' '		
	sb $t2, 0($s0)
	addi $s0, $s0, 1	
	addi $s2, $s2, 1	
	blt $s2, 7, yLoopi	
	
	jr $ra
	
writefile:

	li $v0, 13		
	add $s1, $a1, $0	# buffer pointer moved to $s1
	li $a1, 1		# flag for write permissions
	syscall			
	blt $v0, $0, errorm	
	
	add $s0, $v0, $0		
	li $v0, 15		
	add $a0, $s0, $0		
	la $a1, header		# $a1 stores address to header
	li $a2, 11		# 11 chars will need to written 
	syscall			
	blt $v0,$0,errorm	

	li $v0, 15		
	add $a0, $s0, $0		
	add $a1, $s1, $0		
	li $a2, 2048		
	syscall			
	blt $v0,$0,errorm	

	li $v0, 16		# system call to close file
	add $a0, $s0, $0	# $a0 stores file descriptor
	syscall
	jr $ra

createArr:
	add $t0, $a0, $0	# $t0 stores address to buffer
	add $t5, $0, $0		
	la $t6, arr		# $t6 also stores point to array
	add $s0, $0, $0		
	
loop: 	lb $t1, 0($t0)		# load ASCII byte 
	slti $t2, $t1, 58	# integers range from 48 to 57 in ASCII table
	addi $t4, $0, 47
	slt $t3, $t4, $t1	
	and $t4, $t2, $t3	
	bne $t4, $0, digit
	beq $s0, $0, storeInt	# jump to storeInt if boolean is 0, not yet stored
	j nextChar
	
storeInt:
	sw $t5, 0($t6)		
	add $t5, $0, $0		# reset sum to equal zero
	addi $t6, $t6, 4	# increment array pointer by 4 bytes
	addi $s0, $s0, 1	# boolean equals 1 now as int has been stored
	
nextChar:
	beq $t1, $0, end	# if null character, then finish looping
	addi $t0, $t0, 1	# increment pointer by 1 byte
	j loop			# return to loop
		
digit:	
	add $s0, $0, $0		# reset boolean
	addi $t1, $t1, -48	
	mul $t5, $t5, 10	
	add $t5, $t5, $t1	
	addi $t0, $t0, 1	# increment pointer by 1 byte
	j loop

end: jr $ra	

error:
	li $v0, 4		
	la $a0, errorm
	syscall
	j Exit
	
Exit:	li $v0,10		# exit
	syscall
