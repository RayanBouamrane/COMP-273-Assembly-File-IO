#name: Rayan Bouamrane
#studentID: 260788250

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "borded.pgm"	#used as output

borderwidth: .word 2    #specifies border width
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
headerbuff: .space 2048  #stores header

#any extra data you specify MUST be after this line 
header: 	.asciiz 	"P2\n24 7\n15\n" 
arr: 		.word 168	#24 * 7	
errorm: 	.asciiz 	"There was an error reading or writing the file"

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


	la $a0,buffer		#$a1 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a2 will specify the buffer that will hold the flipped array.
	la $a2,borderwidth
	jal bord


	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
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

bord:
#a0=buffer
#a1=newbuff
#a2=borderwidth
#Can assume 24 by 7 as input
#Try to understand the math before coding!
#EXAMPLE: if borderwidth=2, 24 by 7 becomes 28 by 11.

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

error:
	li $v0, 4		
	la $a0, errorm
	syscall
	j Exit
	
Exit:	li $v0,10		# exit
	syscall