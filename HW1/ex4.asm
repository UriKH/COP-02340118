.global _start

.section .text
_start:
    lea Lower(%rip), %rsi
    lea Upper(%rip), %rdi

# nums: 48 - 57
# capital: 65 - 90
# lower: 97 - 122

.loop_HW1:
    movzbl (%rsi), %eax
    test   %al, %al             # check for null terminator
    je     .done_HW1

    cmpb    $122,   %al         # check if above 'z'
    jg      .continue_loop_HW1
    cmpb    $97,    %al         # check if below 'a'
    jl      .if_not_upper_HW1
.return_HW1:
    cmpb    $90,    %al         # check if A-Z
    jle     .is_upper_HW1

    # new char = orginal - 'a' + 'A'
    subb    $97,    %al
    addb    $65,    %al
    movb    %al, (%rdi)
    inc     %rdi
.continue_loop_HW1:
    # advnace to next char and insert to Upper
    inc     %rsi
    jmp     .loop_HW1



.is_upper_HW1:
    movb    %al, (%rdi)
    inc     %rdi
    inc     %rsi
    jmp     .loop_HW1

.if_not_upper_HW1:
    cmpb    $90,   %al         # check if above 'Z'
    jg      .continue_loop_HW1
    cmpb    $65,    %al         # check if below 'A'
    jl      .if_not_numeric_HW1
    jmp     .return_HW1

.if_not_numeric_HW1:
    cmpb    $57,   %al         # check if above '9'
    jg      .continue_loop_HW1
    cmpb    $48,    %al         # check if below '0'
    jl      .continue_loop_HW1
    jmp     .return_HW1

.done_HW1:
    nop
    # movb    %al, (%rdi) # add the null terminator
