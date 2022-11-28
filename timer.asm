; Timer
; Compile with: nasm -f elf timer.asm
; Link with (64 bit systems require elf_i386 option): ld -m elf_i386 timer.o -o timer
; Run with: ./timer
 
%include        'functions.asm'
 
SECTION .data
msg1        db      '***Starting Stopwatch*** ', 0h     ; message string printed at program start
msg2        db      ' Seconds', 0h             ; message string of units to print
 
SECTION .bss
sinput:     resb    255                                 ; reserve a 255 byte space in memory for the users input string
var1: resb 4                                            ; reserve 4 bytes for initial timestamp 
var2: resb 4                                            ; reserve 4 bytes for timestamp after 'enter' press by user

SECTION .text
global  _start
 
_start:

    mov     eax, msg1       ; move our 'starting stopwatch' message string into eax for printing
    call    sprintLF        ; call string printing function with linefeed

    mov     eax, 13         ; invoke SYS_TIME (kernel opcode 13) (get timestamp)
    int     80h             ; call the kernel

    ;call iprintLF

    mov [var1], eax         ; move initial timestamp in eax to var1
    ;call iprintLF

    loop:                   ; loop for lap function

    ; ---User input delay---
    mov     edx, 255        ; number of bytes to read
    mov     ecx, sinput     ; reserved space to store our input (known as a buffer)
    mov     ebx, 0          ; write to the STDIN file
    mov     eax, 3          ; invoke SYS_READ (kernel opcode 3)
    int     80h

    mov     eax, 13         ; invoke SYS_TIME (kernel opcode 13) (get timestamp)
    int     80h             ; call the kernel
    ;call iprintLF

    mov [var2], eax         ; move the timestamp after user presses enter to var2

    mov eax, [var2]         ; move var2 (timestamp after enter press) into eax register
    mov ebx, [var1]         ; move var1 (initialy timestamp at program start) into ebx register
    sub eax, ebx            ; subtraction function of ebx (initial timestamp) from eax (timestamp after 'enter' press)

    call iprint             ; call integer print function to prind out seconds difference

    mov eax, msg2           ; move 'seconds' message to eax
    call sprint             ; print seconds after each number


    jmp     loop            ; Jump to the loop section
    call    quit