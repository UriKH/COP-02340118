.section .data
First:  .quad node1
node1:  .quad node2
        .int 1
node2:  .quad node3
        .int 2
node3:  .quad 0
        .int 3
node4:  .quad 0
        .int 8

Result:
    .byte 0

.section .text
    movzbl  Result(%rip), %eax
    cmp     $1,     %al
    je      success      

error:
    mov $60, %rax              # sys_exit
    mov $1, %rdi               # exit code 1 (error)
    syscall

success:
    mov $60, %rax              # sys_exit
    xor %rdi, %rdi             # exit code 0 (success)
    syscall
