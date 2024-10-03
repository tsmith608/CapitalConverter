

; assembler command:    yasm -felf64 -gdwarf2 inputtest.asm -l inputtest.lst
; linker command:       ld -g -o inputtest inputtest.o
; execute command:      ./inputtest

section .data ;-----------------------------------------------------------------

STDOUT			equ 	1 		; The standard output code (1 is for the console)
STDIN			equ		0       ; take user input
input_length	equ		100		; buffer
SYS_write		equ		1		; Call code for the write system service
EXIT_SUCCESS   	equ   	0		; successful program execution
SYS_exit       	equ  	60		; call code for termination
LF				equ		10
not_alpha_flag  equ		0

msg				db		"Please Type ", LF
msgLength		dq		13
error			db		"Non Alphabetic Detected...message has been altered", LF
errorLength		equ		$ - error
;-------------------------------------------------------------------------------


section .bss ;------------------------------------------------------------------
user_input resb input_length
;-------------------------------------------------------------------------------

section .text
global _start
_start:
	;print prompt
	mov		rsi, msg
	mov		rdi, msg

	mov		rax, SYS_write
	mov		rdi, STDOUT
	mov		rsi, msg
	mov		rdx, qword [msgLength]
	syscall

	;accept input
	mov		rax, STDIN
	mov		rdi, STDIN
	mov		rsi, user_input
	mov		rdx, input_length
	syscall

	;output it 
	;mov		rax, SYS_write
	;mov		rdi, STDOUT
	;mov		rsi, user_input
	;syscall

	mov		rsi, user_input
	mov 	rdi, user_input
	mov 	r8, not_alpha_flag

convert: 
	lodsb	
	test 	al,  al
	jz 		done

	; cmp		al,  '['
	; je		not_alpha
	; cmp		al,  '\'
	; je		not_alpha
	; cmp		al,  ']'
	; je		not_alpha
	; cmp		al,  '^'
	; je		not_alpha
	; cmp		al,  '_'
	; je		not_alpha
	; cmp		al,  '`'
	; je		not_alpha

	cmp     al, 10  ; ASCII code for newline
	je      handle_newline

	; check space if space, jump
	cmp		al, ' '
	je		handle_space
	;not space continue
	
	; Handle uppercase A-Z
    cmp     al, 'A'                 
    jl      not_alpha               ; if less than 'A', it's not alphabetic
    cmp     al, 'Z'                 
    jle     make_lowercase          ; if between 'A' and 'Z', convert to lowercase

    ; Handle lowercase a-z
    cmp     al, 'a'                 
    jl      not_alpha               ; if less than 'a', it's not alphabetic
    cmp     al, 'z'                 
    jle     make_capital            ; if between 'a' and 'z', convert to uppercase

    ; If it reaches here, it’s non-alphabetic
    jmp     not_alpha

not_alpha:	
	mov		al,  " "
	stosb

	inc		r8
	cmp		r8, 1
	jg 		convert


	push	rsi
	push	rdi

	mov		rax, SYS_write
	mov		rdi, STDOUT
	mov		rsi, error
	mov		rdx, errorLength
	syscall
	pop		rsi
	pop		rdi
	jmp 	convert
	

handle_newline:
	jmp convert

handle_space:
	inc		rdi
	jmp 	convert

make_lowercase:
	add		al, 32
	stosb
	jmp 	convert

make_capital:
	sub		al,  32
	stosb
	jmp 	convert


done:
	;print converted string
	mov		rax, SYS_write
	mov		rdi, STDOUT
	mov		rsi, user_input
	syscall

exit:
	mov   rax, SYS_exit
	mov   rdi, EXIT_SUCCESS
	syscall
