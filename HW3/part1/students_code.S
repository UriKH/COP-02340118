.global	compute_char_repeats, parse_lines

.section .text
compute_char_repeats:
	# arguments (rdi - buffer, rsi - size, rdx - char)
	xor 	%rcx, 	%rcx 	# indexer
	xor 	%rax, 	%rax	# repeats
	xor		%r10,	%r10	# current char
	
	count_chars:
	# loop condition 
	cmp 	%rcx,  	%rsi
	je 		exit
	
	# load char and increment indexer
	movb	(%rdi, %rcx), %r10b
	inc 	%rcx

	# check char
	cmp 	%r10, 	%rdx
	jne 	count_chars
	inc 	%rax
	jmp count_chars

	exit:
	ret

parse_lines:
	# arguments (rdi - path, rsi - line_max_length, rdx - line_max_repeat)
	# allocate stack
	push	%rbp
	movq	%rsp,	%rbp
	subq	$128,	%rsp
	push 	%r12	# start index
	push	%r13	# end index

	xor 	%r8,	%r8		# local line_max_length
	xor 	%r11, 	%r11 	# local line_max_repeat
	xor 	%rax, 	%rax	# line counter
	xor		%r10,	%r10	# current char
	xor 	%r9,	%r9		# file descriptor

	# syscall open
	push 	%rax
	push	%rdi
	push	%rsi
	push	%rdx
	movq	$2, 	%rax
	movq	$0,		%rdx
	movq	$0,		%rsi
	syscall

	movq	%rax,	%r9

	# could not open -> exit
	cmp 	%r9,	$0
	je 		exit
	
	read_file_loop:
	# read to buf (syscall read)
	movq	$0, 	%rax
	movq 	%r9,	%rdi
	lea		$-128(%rbp), %rsi
	movq	$128,	%rdx
	syscall 

	# check for EOF and clear stack
	movq 	%rax,	%rcx
	pop 	%rdx
	pop 	%rsi
	pop		%rdi
	pop		%rax

	cmp		%rcx,	$0
	je 		exit

	xor 	%rcx,	%rcx
	xor 	%r12, 	%r12
	xor 	%r13, 	%r13

	# go over the buffer and check each line
	while_parse_line:
	# lea		$-128(%rbp), %rsi
	# movb	(%rdi, %rcx), %r10b
	
	# find the end of line
	find_newline:


	cmp 	%r12, 	%r13
	je		read_file_loop

	#TODO parsing
	
	exit: 
	# pop things
	
	# close file (syscall close)
	movq	$3, 	%rax
	movq 	%r9,	%rdi
	syscall

	ret
