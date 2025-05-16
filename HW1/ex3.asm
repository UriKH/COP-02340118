.global _start

.section .text
_start:
    /*
    * Go over the linked list and compute the difference (first type) in rax. 
    * In rbx - store the second difference.
    */
    # ------- SETUP -------
    movq    First(%rip), %rdi
    movq    $0x3,   %rsi     # flags
    
    # values            
    xor     %r8,    %r8           
    xor     %r9,    %r9             
    xor     %r10,   %r10
    xor     %r13,   %r13    # curr second diff
    movq    $-1,    %r14    # prev second diff      

    # ------- CHECK VALID LIST -------
    testq   %rdi,   %rdi
    je      .end_HW1
    
    # ------- LOAD 2 VALUES -------
    # first value
    movl    8(%rdi), %r8d
    lea     (%rdi), %rdi
    testq   %rdi,   %rdi
    je      .end_HW1
    
    # second value
    movl    8(%rdi), %r9d
    movq    (%rdi), %rdi
    testq   %rdi,   %rdi
    je      .end_HW1

    # ------- compute previous 1st diff -------
    movq    %r9,    %r15
    subq    %r15,   %r8
    movq    %r15,   %r11

.loop_HW1:
    # load 3rd value
    movl   8(%rdi), %r10d

    # ------- compute current diff -------
    # current 1st diff
    movq    %r10,   %r15
    subq    %r15,   %r9
    movq    %r15,   %r12
    # current 2nd diff
    movq    %r12,   %r13
    subq    %r13,   %r11

    # for first iteration:  prev 2nd diff := curr 2nd diff
    cmpq    $-1,    %r14
    cmove   %r13,   %r14 

    # ------- update flags -------
    # check if 1st and 2nd diff are preserved. set flags accordingly
    cmp     %r11,   %r12
    jne     .clear_first_flag_HW1
.clear_first_flag_ret_HW1:

    cmp     %r13,   %r14
    jne     .clear_second_flag_HW1
.clear_second_flag_ret_HW1:
    
    # ------- advance in the list -------
    movq    %r9,    %r8
    movq    %r10,   %r9
    movq    (%rdi), %rdi
    testq   %rdi,   %rdi
    je      .end_HW1
    movq    (%rdi), %r10

    # check if reached end of list. if so finish.
    testq   %rdi,   %rdi
    jne     .loop_HW1
    jmp .end_HW1
    # ------- EXIST -------

.clear_first_flag_HW1:
    andq    $2,   %rsi
    jmp .clear_first_flag_ret_HW1


.clear_second_flag_HW1:
    andq    $1,   %rsi
    jmp .clear_second_flag_ret_HW1

.end_HW1:
    movq    $1,   %rax
    cmpq    $3,   %rsi
    cmove   %rax,   %rsi
    movb    %sil,   Result(%rip)