.global main

.data
helloworld: .ascii "Hello ATAM\n"
helloworldend:
goodluck: .asciz "Good Luck!\n"
goodluckend:

.text
main:
    # printf(helloworld)
    movq $1, %rax
    movq $1, %rdi
    movq $helloworld+6, %rsi
    movq $helloworldend-helloworld-1, %rdx
    syscall

    # printf(goodluck)
    movq $1, %rax
    movq $1, %rdi
    movq $goodluck, %rsi
    movq $goodluckend-goodluck-7, %rdx
    syscall

    xorq %rax, %rax
    ret
