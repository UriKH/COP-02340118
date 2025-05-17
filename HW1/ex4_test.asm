.section .data
Lower:
    .asciz "chickpeas 1 muA 0x7\n"
Upper:
    .asciz "                   \n"

.section .text
    mov     $1, %rax           # syscall: sys_write
    mov     $1, %rdi           # file descriptor: stdout
    lea     Lower(%rip), %rsi    # pointer to string
    mov     $21, %rdx          # number of bytes to write (length of the string)
    syscall                    # invoke system call

    mov     $1, %rax           # syscall: sys_write
    mov     $1, %rdi           # file descriptor: stdout
    lea     Upper(%rip), %rsi    # pointer to string
    mov     $21, %rdx          # number of bytes to write (length of the string)
    syscall                    # invoke system call
    jmp success

error:
    mov $60, %rax              # sys_exit
    mov $1, %rdi               # exit code 1 (error)
    syscall

success:
    mov $60, %rax              # sys_exit
    xor %rdi, %rdi             # exit code 0 (success)
    syscall
