.section .data
First:  .quad node1
node1:  .quad node2
        .int 1
node2:  .quad node3
        .int 3
node3:  .quad node4
        .int 7
node4:  .quad 0
        .int 13

Result:
    .byte 0

.section .text
    movzbl  Result(%rip), %eax
    cmp     $2,     %al
    je      success      

error:
    mov $60, %rax              # sys_exit
    mov $1, %rdi               # exit code 1 (error)
    syscall

success:
    mov $60, %rax              # sys_exit
    xor %rdi, %rdi             # exit code 0 (success)
    syscall
