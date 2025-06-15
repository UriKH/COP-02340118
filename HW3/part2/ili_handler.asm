.globl my_ili_handler
.extern old_ili_handler

.text
.align 4, 0x90
my_ili_handler:

  push      %rax
  push      %rcx
  push      %rdx
  push      %rsi
  push      %r8
  push      %r9
  push      %r10
  push      %r11
  push      %rdi

  mov       72(%rsp), %rsi  #Get saved %rip
  movb      (%rsi), %cl     #Load the instruction
  cmpb      $0x0F, %cl      #Check if two byte instruction
  jne       one_byte
  movb      1(%rsi), %cl   #Load second byte
  movq      $2, %rdx        #Update instruction offset
  jmp       call_what_to_do

one_byte:

  movq      $1, %rdx        #Update instruction offset

call_what_to_do:

  movzb     %cl, %rdi       #Move the parameter to %rdi
  push      %rdx            #Save local parameter
  call      what_to_do
  pop       %rdx
  test      %rax, %rax      #Check the return value
  jz        goto_default_handler

  addq      %rdx, 72(%rsp)
  movq      %rax, %rdi

  add       $8, %rsp        #Throw away %rdi old value
  pop       %r11
  pop       %r10
  pop       %r9
  pop       %r8
  pop       %rsi
  pop       %rdx
  pop       %rcx
  pop       %rax

  iretq

goto_default_handler:

  pop       %rdi
  pop       %r11
  pop       %r10
  pop       %r9
  pop       %r8
  pop       %rsi
  pop       %rdx
  pop       %rcx
  pop       %rax

  jmp       *old_ili_handler
