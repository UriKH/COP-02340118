.global _start

.section .text
_start:

	movq Address(%rip), %rax
	movq Address(%rip), %rbx
	xorq %rcx, %rcx
	movl Length(%rip), %ecx
	decq %rcx
	addq %rcx, %rbx
	
loop:
	cmpq %rbx, %rax
	jge .L2 					#if i>=j return true
	movb (%rax), %cl
	movb (%rbx), %dl
	cmpb %cl, %dl
	jne .L1 					#if arr[i] != arr[j] return false
	incq %rax #i++
	decq %rbx #j--
	jmp loop					#while (i<j)
	
.L1:
	movb $0, (Result)
	jmp end_HW1
	
.L2:
	movb $1, (Result)
	
end_HW1:
	