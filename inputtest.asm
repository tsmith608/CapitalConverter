; Assembler command:    yasm -felf64 -gdwarf2 inputtest.asm -l inputtest.lst
; Linker command:       ld -g -o inputtest inputtest.o
; Execute command:      ./inputtest

section .data ;-----------------------------------------------------------------

STDOUT          equ     1           ; The standard output code (1 for console)
STDIN           equ     0           ; The standard input code
input_length    equ     100         ; Maximum length for input buffer
SYS_write       equ     1           ; Call code for write system service
EXIT_SUCCESS    equ     0           ; Successful program execution code
SYS_exit        equ     60          ; Call code for termination
LF              equ     10          ; ASCII value for line feed
not_alpha_flag  equ     0           ; Flag to track non-alphabetic characters

msg             db      "Please Type ", LF
msgLength       dq      13          ; Length of the prompt message
error           db      "Non Alphabetic Detected...message has been altered", LF
errorLength     equ     $ - error   ; Length of the error message

;-------------------------------------------------------------------------------

section .bss ;------------------------------------------------------------------
user_input      resb    input_length ; Reserve buffer for user input
;-------------------------------------------------------------------------------

section .text
global _start

_start:
    ; Print prompt message
    mov     rsi, msg
    mov     rdi, msg
    mov     rax, SYS_write
    mov     rdi, STDOUT
    mov     rsi, msg
    mov     rdx, qword [msgLength]
    syscall

    ; Accept user input
    mov     rax, STDIN
    mov     rdi, STDIN
    mov     rsi, user_input
    mov     rdx, input_length
    syscall

    ; Prepare to process input
    mov     rsi, user_input
    mov     rdi, user_input
    mov     r8, not_alpha_flag

convert:
    lodsb                           ; Load next byte into AL
    test    al, al                  ; Check if it's the null terminator
    jz      done                    ; Exit loop if null terminator

    ; Handle newlines
    cmp     al, LF                  ; Check if it's a line feed
    je      handle_newline

    ; Check if the character is a space
    cmp     al, ' '                 ; If space, handle it
    je      handle_space

    ; Handle uppercase A-Z
    cmp     al, 'A'
    jl      not_alpha               ; Less than 'A' is not alphabetic
    cmp     al, 'Z'
    jle     make_lowercase          ; If between 'A' and 'Z', convert to lowercase

    ; Handle lowercase a-z
    cmp     al, 'a'
    jl      not_alpha               ; Less than 'a' is not alphabetic
    cmp     al, 'z'
    jle     make_capital            ; If between 'a' and 'z', convert to uppercase

    ; Non-alphabetic characters
    jmp     not_alpha

not_alpha:
    mov     al, " "                 ; Replace with a space
    stosb                           ; Store updated character
    inc     r8                      ; Increment non-alpha flag
    cmp     r8, 1                   ; Limit number of replacements
    jg      convert

    ; Print error message if non-alphabetic detected
    push    rsi
    push    rdi
    mov     rax, SYS_write
    mov     rdi, STDOUT
    mov     rsi, error
    mov     rdx, errorLength
    syscall
    pop     rsi
    pop     rdi
    jmp     convert

handle_newline:
    jmp     convert                 ; Ignore newline and continue

handle_space:
    inc     rdi                     ; Skip storing space
    jmp     convert

make_lowercase:
    add     al, 32                  ; Convert to lowercase
    stosb                           ; Store updated character
    jmp     convert

make_capital:
    sub     al, 32                  ; Convert to uppercase
    stosb                           ; Store updated character
    jmp     convert

done:
    ; Print converted string
    mov     rax, SYS_write
    mov     rdi, STDOUT
    mov     rsi, user_input
    syscall

exit:
    mov     rax, SYS_exit           ; Exit the program
    mov     rdi, EXIT_SUCCESS       ; Successful exit code
    syscall
