#name: Rayan Bouamrane
#studentID: 260788250

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "cropped.pgm"	#used as output
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
x1: .word 1
x2: .word 22
y1: .word 1
y2: .word 5
headerbuff: .space 2048  #stores header
#any extra .data you specify MUST be after this line 
header1:.asciiz "P2\n"
header2: .asciiz "\n15\n"
arr: 		.word 168	#24 * 7	
errorm: 	.asciiz 	"There was an error reading or writing the file"

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


    #load the appropriate values into the appropriate registers/stack positions
    #appropriate stack positions outlined in function*
    	addi $sp, $sp, -28
    	la $a0, buffer
    	sw $a0, 16($sp)
    	la $a0, newbuff
    	sw $a0, 20($sp)
    	la $a0, x1
    	la $a1, x2
    	la $a2, y1
    	la $a3, y2
	jal crop
	addi $sp, $sp, 28

	#add what ever else you may need to make this work.
	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	la $a2, headerbuff	#and a2 as headerbuffer
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

crop:
	sw $a0, 0($sp)		
	sw $a1, 4($sp)		
	sw $a2, 8($sp)		
	sw $a3, 12($sp)		
	sw $ra, 24($sp)		# store values on stacck
	lw $a0, 16($sp)		# buffer pointer in $a0 will be used to createArr
	jal createArr
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a3, 12($sp)
	jal createHeader	# x ranges from 0-23
	lw $ra, 24($sp)		# y ranges from 0-6
	
	lw $s0, 20($sp)		# $s0 stores pointer to newBuff
	la $s1, arr		# $s0 stores pointer to arr
	lw $t0, 0($a2)		# coordinate i
	
outLoop:
	lw $t1, 0($a0)		# coordinate j
	
inLoop: 
	mul $t3, $t0, 24	
	add $t3, $t3, $t1	
	mul $t3, $t3, 4		# $t3 equals 4 X ((24 X i) + j)
	add $t4, $s1, $t3	# $t4 points to int in arr
	lw $t2, 0($t4)		
	bgt $t2, 9, mod		# call mod method if int greater than 9
	addi $t2, $t2, 48	# ints in ASCII start at 48, convert to ASCII
	sb $t2, 0($s0)
	li $t2, ' '		
	sb $t2, 1($s0)
	addi $s0, $s0, 2	# increment newBuff pointer
	j halt
	
mod:	div $t4, $t2, 10	
	rem $t3, $t2, 10	# $t0 stores remainder of division		
	addi $t3, $t3, 48	
	addi $t4, $t4, 48	
	sb $t4, 0($s0)
	sb $t3, 1($s0)
	li $t2, ' '		
	sb $t2, 2($s0)
	addi $s0, $s0, 3	# increment newBuff pointer
	

halt:

	addi $t1,$t1,1		# increment j
	lw $s6, 0($a1)
	ble  $t1, $s6, inLoop	# inLoop must be called if j <= $s6
	addi $t0, $t0, 1	# increment i
	lw $s6, 0($a3)
	ble $t0, $s6, outLoop	# outLoop must be called if i <= $s6

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
	add $a1, $a2, $0	# $a1 stores address to header			
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
	
# Now, here we know the byte is not an integer
nextChar:
	beq $t1, $0, end	# if null character, then finish looping
	addi $t0, $t0, 1	# increment pointer by 1 byte
	j loop			# and loop
		
digit:	
	add $s0, $0, $0		# reset boolean indicating if digit stored in $s0 to 0
	addi $t1, $t1, -48	# ASCII to int
	mul $t5, $t5, 10	# sum = sum*10
	add $t5, $t5, $t1	# sum = sum + int
	addi $t0, $t0, 1	# increment pointer by 1 byte
	j loop
	
end: jr $ra

createHeader:
	la $s0, headerbuff	# $s0 stores pointer to headerbuff
	la $s1, header1		# $s1 stores pointer to header1
	
loop1:	lb $t2, 0($s1)		
	beq $t2, $0, next	# check for null charcter, continue if true
	sb $t2, 0($s0)		# else store byte into $t2
	addi $s0, $s0, 1	
	addi $s1, $s1, 1	# increment pointers
	j loop1
next:
	lw $t1, 0($a0)		# load x1 to $t1
	lw $t2, 0($a1)		# load x2 to $t2
	sub $t2, $t2, $t1	
	addi $t2, $t2, 1	
	bgt $t2, 9, modH	# call modH method if int greater than 9
	addi $t2, $t2, 48	# ints in ASCII start at 48, convert to ASCII
	sb $t2, 0($s0)
	li $t2, ' '		
	sb $t2, 1($s0)
	addi $s0, $s0, 2	# increment newBuff pointer
	j noModH
	
modH:	div $t4, $t2, 10	
	rem $t3, $t2, 10	# $t3 stores remainder of division		
	addi $t3, $t3, 48	
	addi $t4, $t4, 48	
	sb $t4, 0($s0)
	sb $t3, 1($s0)
	li $t2, ' '		
	sb $t2, 2($s0)
	addi $s0, $s0, 3	# increment pointer
	
noModH:
	lw $t1, 0($a2)		# load y1 to $t1
	lw $t2, 0($a3)		# load y2 to $t2
	sub $t2, $t2, $t1	
	addi $t2, $t2, 1	
	addi $t2, $t2, 48	
	sb $t2, 0($s0)
	addi $s0, $s0, 1	
	la $s1, header2		# $s1 becomes to pointer to header2
	
loop2:	lb $t2, 0($s1)		
	beq $t2, $0, endHead	
	sb $t2, 0($s0)		
	addi $s0, $s0, 1	
	addi $s1, $s1, 1
	j loop2	

endHead: jr $ra

error:
	li $v0, 4		
	la $a0, errorm
	syscall
	j Exit
	
Exit:	li $v0,10		# exit
	syscall