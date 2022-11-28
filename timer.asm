; Timer 
; Compile with: nasm -f elf timer.asm
; Link with (64 bit systems require elf_i386 option): ld -m elf_i386 timer.o -o timer
; Run with: ./timer
 
;------------------------------------------
; void iprint(Integer number)
; Integer printing function (itoa)
iprint:
    push    eax             ; preserve eax on the stack to be restored after function runs
    push    ecx             ; preserve ecx on the stack to be restored after function runs
    push    edx             ; preserve edx on the stack to be restored after function runs
    push    esi             ; preserve esi on the stack to be restored after function runs
    mov     ecx, 0          ; counter of how many bytes we need to print in the end
 
divideLoop:
    inc     ecx             ; count each byte to print - number of characters
    mov     edx, 0          ; empty edx
    mov     esi, 10         ; mov 10 into esi
    idiv    esi             ; divide eax by esi
    add     edx, 48         ; convert edx to it's ascii representation - edx holds the remainder after a divide instruction
    push    edx             ; push edx (string representation of an intger) onto the stack
    cmp     eax, 0          ; can the integer be divided anymore?
    jnz     divideLoop      ; jump if not zero to the label divideLoop
 
printLoop:
    dec     ecx             ; count down each byte that we put on the stack
    mov     eax, esp        ; mov the stack pointer into eax for printing
    call    sprint          ; call our string print function
    pop     eax             ; remove last character from the stack to move esp forward
    cmp     ecx, 0          ; have we printed all bytes we pushed onto the stack?
    jnz     printLoop       ; jump is not zero to the label printLoop
 
    pop     esi             ; restore esi from the value we pushed onto the stack at the start
    pop     edx             ; restore edx from the value we pushed onto the stack at the start
    pop     ecx             ; restore ecx from the value we pushed onto the stack at the start
    pop     eax             ; restore eax from the value we pushed onto the stack at the start
    ret
 
 
;------------------------------------------
; void iprintLF(Integer number)
; Integer printing function with linefeed (itoa)
iprintLF:
    call    iprint          ; call our integer printing function
 
    push    eax             ; push eax onto the stack to preserve it while we use the eax register in this function
    mov     eax, 0Ah        ; move 0Ah into eax - 0Ah is the ascii character for a linefeed
    push    eax             ; push the linefeed onto the stack so we can get the address
    mov     eax, esp        ; move the address of the current stack pointer into eax for sprint
    call    sprint          ; call our sprint function
    pop     eax             ; remove our linefeed character from the stack
    pop     eax             ; restore the original value of eax before our function was called
    ret
 
 
;------------------------------------------
; int slen(String message)
; String length calculation function
slen:
    push    ebx
    mov     ebx, eax
 
nextchar:
    cmp     byte [eax], 0
    jz      finished
    inc     eax
    jmp     nextchar
 
finished:
    sub     eax, ebx
    pop     ebx
    ret
 
 
;------------------------------------------
; void sprint(String message)
; String printing function
sprint:
    push    edx
    push    ecx
    push    ebx
    push    eax
    call    slen
 
    mov     edx, eax
    pop     eax
 
    mov     ecx, eax
    mov     ebx, 1
    mov     eax, 4
    int     80h
 
    pop     ebx
    pop     ecx
    pop     edx
    ret
 
 
;------------------------------------------
; void sprintLF(String message)
; String printing with line feed function
sprintLF:
    call    sprint
 
    push    eax
    mov     eax, 0AH
    push    eax
    mov     eax, esp
    call    sprint
    pop     eax
    pop     eax
    ret
 
 
;------------------------------------------
; void exit()
; Exit program and restore resources
quit:
    mov     ebx, 0
    mov     eax, 1
    int     80h
    ret
 
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