.global _start

.section .text
_start:
    lea Lower(%rip), %rsi      # rsi points to the start of the string

.loop:
    movzbl (%rsi), %eax        # load byte at [rsi] into eax, zero-extended
    test   %al, %al            # check for null terminator
    je     .done               # if null (end of string), jump out

    # --- do something with the character in %al ---
    # e.g., print, count, compare, etc.
    

    inc    %rsi                # move to next character
    jmp    .loop

.done:
    nop