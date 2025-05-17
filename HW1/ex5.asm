.global _start

.section .text

_start:

	xorb %r10b, %r10b 			#set flags = 0, not found
	xorb %r11b, %r11b
	leaq String(%rip), %r12 	#load String address
	
	movb (%r12), %bl 			#check if String is empty, if it is go to end
	testb %bl, %bl
	jz end_HW1
	
	cmpb $0x20, %bl				#check if String starts with spaces, if it is skip spaces
	je skip_spaces_HW1
	
	jmp check_add_HW1 			#start checking words
	
goto_next_word_HW1: 			#moves r12 to next space and calls skip spaces

	movb (%r12), %bl
	testb %bl, %bl
	jz end_HW1
	cmpb $0x20, %bl
	je skip_spaces_HW1
	incq %r12
	jmp goto_next_word_HW1
	
skip_spaces_HW1: 				#moves r12 to next non space char
	
	incq %r12
	movb (%r12), %bl
	testb %bl, %bl
	jz end_HW1
	cmpb $0x20, %bl
	je skip_spaces_HW1
    jmp check_add_HW1
	
check_add_HW1: 					#checks if current word matches add

	testb %r10b, %r10b
	jnz check_num_HW1
	
	cmpb $'a', (%r12)
	jne check_sub_HW1
	cmpb $'d', 1(%r12)
	jne check_sub_HW1
	cmpb $'d', 2(%r12)
	jne check_sub_HW1
	
	movb 3(%r12), %cl
	testb %cl, %cl
	jz words_match_HW1
	
	cmpb $' ', 3(%r12)
	je words_match_HW1
	
	jmp check_sub_HW1
	
check_sub_HW1: 					#checks if current word matches sub
	
	cmpb $'s', (%r12)
	jne check_mul_HW1
	cmpb $'u', 1(%r12)
	jne check_mul_HW1
	cmpb $'b', 2(%r12)
	jne check_mul_HW1
	
	movb 3(%r12), %cl
	testb %cl, %cl
	jz words_match_HW1
	
	cmpb $' ', 3(%r12)
	je words_match_HW1
	
	jmp check_mul_HW1
	
check_mul_HW1: 					#checks if current word matches mul
	
	cmpb $'m', (%r12)
	jne check_div_HW1
	cmpb $'u', 1(%r12)
	jne check_div_HW1
	cmpb $'l', 2(%r12)
	jne check_div_HW1
	
	movb 3(%r12), %cl
	testb %cl, %cl
	jz words_match_HW1
	
	cmpb $' ', 3(%r12)
	je words_match_HW1
	
	jmp check_div_HW1
	
check_div_HW1: 					#checks if current word matches div
	
	cmpb $'d', (%r12)
	jne check_imul_HW1
	cmpb $'i', 1(%r12)
	jne check_imul_HW1
	cmpb $'v', 2(%r12)
	jne check_imul_HW1
	
	movb 3(%r12), %cl
	testb %cl, %cl
	jz words_match_HW1
	
	cmpb $' ', 3(%r12)
	je words_match_HW1
	
	jmp check_imul_HW1
	
check_imul_HW1: 				#checks if current word matches imul
	
	cmpb $'i', (%r12)
	jne check_idiv_HW1
	cmpb $'m', 1(%r12)
	jne check_idiv_HW1
	cmpb $'u', 2(%r12)
	jne check_idiv_HW1
	cmpb $'l', 3(%r12)
	jne check_idiv_HW1
	
	movb 4(%r12), %cl
	testb %cl, %cl
	jz words_match_HW1
	
	cmpb $' ', 4(%r12)
	je words_match_HW1
	
	jmp check_idiv_HW1
	
check_idiv_HW1: 				#checks if current word matches idiv
	
	cmpb $'i', (%r12)
	jne check_num_HW1
	cmpb $'d', 1(%r12)
	jne check_num_HW1
	cmpb $'i', 2(%r12)
	jne check_num_HW1
	cmpb $'v', 3(%r12)
	jne check_num_HW1
	
	movb 4(%r12), %cl
	testb %cl, %cl
	jz words_match_HW1
	
	cmpb $' ', 4(%r12)
	je words_match_HW1
	
	jmp check_num_HW1
	
check_num_HW1: 					#checks if current word is a number in one of the formats

	testb %r11b, %r11b 			#if we already found a number, skip
	jnz goto_next_word_HW1

	movb $'x', %al 				#set register al to x to check for 0x format
	jmp check_num_aux_HW1

check_num_aux_HW1:
	
	movq %r12, %r14 			#loads r12 to r14
	movb (%r14), %bl 			#loads first char
	cmpb $0x30, %bl 			#compare with 0
	jne after_check_b_HW1 		#if number word does not start with 0 we check pure number format
	
	incq %r14
	movb (%r14), %bl
	cmpb %al, %bl
	jne not_digit_HW1 			#check if char matches x or b
	
	incq %r14 					#make sure after x or b there is at least one more number
    movb (%r14), %bl
    cmpb $0x30, %bl
    jb goto_next_word_HW1
    cmpb $0x39, %bl
    ja goto_next_word_HW1 		#makes sure char is between 0x30 and 0x39, digit
	
	incq %r14
	
check_num_loop_HW1: 			#loop to check if all chars of word are digits

    movb (%r14), %bl
	
	testb %bl, %bl 				#reaches end of string, number found
    jz num_match_HW1
	
	cmpb $0x20, %bl 			#reaches space, number found
	je num_match_HW1
	
	cmpb $0x30, %bl
	jb goto_next_word_HW1 		#char is not a number, go to next word

	cmpb $0x39, %bl
	ja goto_next_word_HW1 		#char is not a number, go to next word
	
	incq %r14
	jmp check_num_loop_HW1 		#loop
	
not_digit_HW1: 					#sets up next format

    cmpb $0x78, %al
    je after_check_x_HW1
    cmpb $0x62, %al
    je after_check_b_HW1
	jmp after_check_digits_HW1
	
after_check_x_HW1: 				#if 0x format failed, move on to 0b format

    movb $0x62, %al
    jmp check_num_aux_HW1
	
after_check_b_HW1: 				#if 0b format failed, move on to pure number format

	movq %r12, %r14
    jmp check_num_loop_HW1
	
after_check_digits_HW1: 		#all formats failed, move on to next word

    jmp goto_next_word_HW1
	
words_match_HW1: 				#word found, set up flag and move on

	testb %r10b, %r10b
	jnz check_num_HW1
	addb $1, %r10b
	jmp both_match_HW1
	
num_match_HW1: 					#number found, set up flag and move on

	testb %r11b, %r11b
	jnz goto_next_word_HW1
	addb $1, %r11b
	jmp both_match_HW1
	
both_match_HW1: 				#if both word and number were found, we can finish

	movb %r10b, %dl
	andb %r11b, %dl
	cmpb $1, %dl
	je end_HW1
	jmp goto_next_word_HW1
	
end_HW1: 						#store result and finish
	
	shlb $1, %r11b
	addb %r11b, %r10b
	movb %r10b, (Result)
	