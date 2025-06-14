.global	compute_char_repeats, parse_lines

.section .text

# utility macros for pushing and poping registers (callee and caller) 
# using System V convensions
.macro push_all_caller_registers
    push %rax
    push %rdi
    push %rsi
    push %rdx
    push %rcx
    push %r8
    push %r9
    push %r10
    push %r11
.endm

.macro pop_all_caller_registers
    pop %r11
    pop %r10
    pop %r9
    pop %r8
    pop %rcx
    pop %rdx
    pop %rsi
    pop %rdi
    pop %rax
.endm

.macro push_all_callee_registers
    push %rbx
	push %r12
	push %r13
	push %r14
.endm

.macro pop_all_callee_registers
    pop %r14
	pop %r13
	pop %r12
	pop %rbx
.endm

compute_char_repeats:
	push_all_callee_registers
	# arguments (rdi - buffer, rsi - size, rdx - char)
	xor 	%rcx, 	%rcx 	# indexer
	xor 	%rax, 	%rax	# repeats
	xor		%r10,	%r10	# current char
	
count_chars_f1:
	# loop condition 
	cmp 	%rcx,  	%rsi
	je 		exit_f1
	
	# load char and increment indexer
	movb	(%rdi, %rcx), %r10b
	inc 	%rcx

	# check char
	cmp 	%r10, 	%rdx
	jne 	count_chars_f1
	inc 	%rax
	jmp count_chars_f1

exit_f1:
	pop_all_callee_registers
	ret

parse_lines:
	# arguments (rdi - path, rsi - line_max_length, rdx - line_max_repeat)
	# allocate stack
	push	%rbp
	movq	%rsp,	%rbp
	subq	$128,	%rsp
	push_all_callee_registers

	xor 	%r8,	%r8		# local line_length
	xor 	%r11, 	%r11 	# local line_repeat
	xor 	%rax, 	%rax	# line counter
	xor		%r10,	%r10	# utility
	xor 	%r9,	%r9		# file descriptor

	movl 	$0,		(%rdx)
	movl 	$0,		(%rsi)	

	# syscall open
	push_all_caller_registers
	movq	$2, 	%rax
	movq	$0,		%rdx
	movq	$0,		%rsi
	syscall

	movq	%rax,	%rbx
	pop_all_caller_registers

	movq	%rbx,	%r9

	# could not open -> exit
	cmp 	$0,		%r9
	je 		exit_no_close_f2

	# call get_the_special_char
	push_all_caller_registers

	call get_the_special_char
	movq	%rax,	%rbx

	pop_all_caller_registers
	
	# ----------------- Read the file by 128 size chunks and parse -----------------
read_file_loop_f2:
	# read to buf (syscall read)
	push_all_caller_registers
	movq	$0, 	%rax
	movq 	%r9,	%rdi
	lea		-128(%rbp), %rsi
	movq	$128,	%rdx
	syscall 

	# check for EOF and clear stack
	movq 	%rax,	%r12
	pop_all_caller_registers
	movq 	%r12,	%rcx

	cmp		$0,		%rcx
	je 		EOF_f2

	# ----------------- go over the chunk buffer and parse -----------------	
	# set r12 (i.e. start) and r13 (i.e. end) to start of buffer 
	lea 	-128(%rbp), %r12
	movq	%r12,	%r13

	# find the end of line in current buffer
find_newline_f2:
	# >>> CASE 1 -> found \n
	# check if reached new line, if yes parse, else continue the search
	cmpb 	$10,	(%r13)
	je 		update_line_cnt_after_newline_f2
	# END CASE 1 <<<

	# >>> CASE 3 -> finished buffer, go to next one.
	# check if reached end of line
	movq 	$-1,	%r14
	addq 	%rbp, 	%r14
	subq	%r13,	%r14
	cmp 	$0,		%r14
	je		update_line_cnt_no_newline_f2
	# END CASE 3 <<<

	# >>> CASE 2 -> finished in mid buffer
	# in case this was the last chunk and we finished going over it.
	movq 	%r13,	%r14
	lea		-128(%rbp), %r10
	subq	%r10,	%r14
	inc 	%r14
	cmp 	%r14,	%rcx
	je		update_line_cnt_no_newline_EOF_f2
	# after we got to the last case, we need to exit gracfully
	movq 	%r13,	%r14
	lea		-128(%rbp), %r10
	subq	%r10,	%r14
	inc 	%r14
	cmp 	%r14,	%rcx
	jl		exit_f2
	# END CASE 2 <<<

	# continue the for loop
	inc		%r13
	jmp 	find_newline_f2

	update_line_cnt_after_newline_f2:
	inc		%rax						# new line found
	movq 	%r13,	%r14
	subq	%r12,	%r14
	addq	%r14,	%r8

	xor 	%r10,	%r10
	jmp 	parse_line_f2

	update_line_cnt_no_newline_f2:
	movq 	%r13,	%r14
	subq	%r12,	%r14
	inc 	%r14
	addq	%r14,	%r8

	xor 	%r10,	%r10
	jmp 	parse_line_f2

	update_line_cnt_no_newline_EOF_f2:
	movq 	%r13,	%r14
	subq	%r12,	%r14
	inc 	%r14
	addq	%r14,	%r8
	# dec 	%rax
	
	movq 	$1,		%r10
	jmp 	parse_line_f2


parse_line_f2:
	# compute char repeats
	push_all_caller_registers

	movq 	%r12, 	%rdi
	movq	%r13,	%rsi
	subq	%r12,	%rsi
	inc 	%rsi
	movq	%rbx,	%rdx
	call 	compute_char_repeats
	
	pop 	%r11
	addq	%rax,	%r11
	movq 	%r11,	%r14
	push	%r11

	pop_all_caller_registers

	movq 	%r14,	%r11

	# check if finished a line
	cmpb 	$10,	(%r13)
	je		update_statistics_f2

	cmp		$1,		%r10
	je		update_statistics_f2

	return_from_update_stats_f2:

	# read a new line or finish to parse the current one
	inc 	%r13
	movq	%r13,	%r12

	cmp 	%r13, 	%rbp
	jle		read_file_loop_f2
	jmp 	find_newline_f2

update_statistics_f2:
	# inc 	%r13
	# movq	%r13,	%r12
	
	# update max line length
	cmpl 	(%rsi),		%r8d
	jle		update_max_repeats_f2
	movl	%r8d,		(%rsi)

update_max_repeats_f2:
	# update max line repeats
	cmpl 	(%rdx),		%r11d
	jle		reset_for_next_stats_f2
	movl	%r11d,		(%rdx)

reset_for_next_stats_f2:
	xor 	%r8,	%r8
	xor 	%r11,	%r11
	cmp 	$1,		%r10
	je		exit_f2
	jmp 	return_from_update_stats_f2


EOF_f2:
	movq 	$1,		%r10
	jmp update_statistics_f2
	
exit_f2: 
	# close file (syscall close)
	push_all_caller_registers
	
	movq	$3, 	%rax
	movq 	%r9,	%rdi
	syscall
	pop_all_caller_registers

exit_no_close_f2:
	inc 	%rax 	# newlines + 1
	pop_all_callee_registers
	addq	$128, 	%rsp
	leave
	ret
