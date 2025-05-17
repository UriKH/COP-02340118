.global _start

.section .text
_start:
	movl (num1), %eax       # Load num1 into eax
    popcnt %eax, %ecx       # Count 1's in num1, store in ecx
    andl $1, %ecx           # Get the parity (0 or 1) of num1
    
    movl (num2), %ebx       # Load num2 into ebx
    popcnt %ebx, %edx       # Count 1's in num2, store in edx
    andl $1, %edx           # Get the parity (0 or 1) of num2
    
    cmpb %cl, %dl           # Compare the parity bits
    sete %al                # Set al to 1 if equal, 0 if not equal
    movb %al, (BitCheck)    # Store the result in BitCheck
	
