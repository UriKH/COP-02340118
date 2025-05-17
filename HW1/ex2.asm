.global _start

.section .text
_start:

	movl $0, %eax 				#i=0, j=Length-1
	movl (Length), %ebx
	decl %ebx
	
loop:
	cmpl %ebx, %eax
	jge .L2 					#if i>=j return true
	movb Address(,%eax,1), %cl
	movb Address(,%ebx,1), %dl
	cmpb %cl, %dl
	jne .L1 					#if arr[i] != arr[j] return false
	incl %eax #i++
	decl %ebx #j--
	jmp loop					#while (i<j)
	
.L1:
	movb $0, (Result)
	
.L2:
	movb $1, (Result)
	
