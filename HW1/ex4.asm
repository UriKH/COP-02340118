.global _start

.section .text
_start:
    lea Lower(%rip), %rsi
    lea Upper(%rip), %rdi

.loop_HW1:
    movzbl (%rsi), %eax
    test   %al, %al             # check for null terminator
    je     .done_HW1

    cmpb    $122,   %al         # check if above 'z'
    jg      .insert_HW1
    cmpb    $97,    %al         # check if below 'a'
    jl      .insert_HW1

    # new char = orginal - 'a' + 'A'
    subb    $97,    %al
    addb    $65,    %al

.insert_HW1:
    # advnace to next char and insert to Upper
    movb    %al, (%rdi)
    inc     %rdi
    inc     %rsi
    jmp     .loop_HW1

.done_HW1:
    nop
