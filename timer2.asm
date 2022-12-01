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
 
 
SECTION .data                                           ; define constant variables
                                                        ; strings, magic numbers, terminating strings
msg1        db      '***Starting Stopwatch*** ', 10     ; message string printed at program start
msg1_l      equ     $ - msg1
msg2        db      ' Seconds ', 10                     ; message string of units to print
msg2_l      equ     $ - msg2
lapmsg      db      'Laptime: '                         ; message string for saying Laptime:
lapmsg_l    equ     $ - lapmsg                          ; & is the current address, subtract that from the lapmsg start.
totalmsg    db      10, 'Total time: '                  ; message string for stating "Total time"
totalmsg_l  equ     $ - totalmsg                        ; & is the current address, subtract that from the totalmsg start. 
eMsg        db      10, '***Closing Stopwatch***', 0h   ; What to print when exitting program
eMsg_l      equ     $ - eMsg                            ; Length of the exitting msg
fMsg        db      10, 'Fastest Lap was: '             ; Message for saying fastest lap
fMsg_l      equ     $ - fMsg                            ; length of the message
cMsg        db      "Total Laps were: "                 ; Message for total laps
cMsg_l      equ     $ - cMsg                            ; length of the message
 
SECTION .bss                                            ; reservering space in memory for future data
sinput:     resb    255                                 ; reserve a 255 byte space in memory for the users input string
sinput2:    resb    1                                   ; For holding 1 character;
var1:       resb 4                                      ; reserve 4 bytes for initial timestamp 
var2:       resb 4                                      ; reserve 4 bytes for timestamp after 'enter' press by user
fastestLap  resb 4                                      ; reserve 4 bytes to hold time of fastest lap
lastTimestamp resb 4                                    ; reserver 4 bytes to hold the last timestamp
totalLaps   resb 4                                      ; reserve 4 bytes to hold total laps;

SECTION .text                                           ; always has _start if ld or main if gcc depending on compiler
                                                        ; rax 64bit register / eax 32bit register
                                                        ; registers: hardware implemented variables
global  _start
 
_start:

    mov     eax, 13                 ; invoke SYS_TIME (kernel opcode 13) (get timestamp)
    int     80h                     ; call the kernel
    mov     [var1], eax             ; move initial timestamp in eax to var1
    mov     [lastTimestamp], eax    ; Set the initial first lap time to starting time

    ; Print of that you are starting the stopwatch;
    mov	edx, msg1_l         ;message length
    mov	ecx, msg1           ;message to write
    mov	ebx,1               ;file descriptor (stdout)
    mov eax,4               ;system call number (sys_write)
    int	0x80                ;call kernel

    
    mov     [fastestLap], byte 255  ; setting fastest lap to a high number
    mov     eax, 0                  ; put 0 in eax
    mov     [totalLaps], eax       ; total laps

  ;  mov     eax, msg1       ; move our 'starting stopwatch' message string into eax for printing
  ;  call    sprintLF        ; call string printing function with linefeed




    loopName:                   ; loop for lap function

    ; ---User input delay---
    mov     edx, 1          ; number of bytes to read
    mov     ecx, sinput2    ; reserved space to store our input (known as a buffer)
    mov     ebx, 0          ; write to the STDIN file
    mov     eax, 3          ; invoke SYS_READ (kernel opcode 3)
    int     80h


    push    eax             ; save eax on the stack
    mov     al, [sinput2]   ; al is 8bits for comparing 1 character
    cmp     al, 'l'         ; l means a lap has passed
    jnz     exitLocation    ; jnz checks if the cmp result was 0, if they didn't input 'l' program quits
    pop     eax             ; retrieve eax on the stack
    


;   Get this next timestamp
    mov     eax, 13         ; invoke SYS_TIME (kernel opcode 13) (get timestamp)
    int     80h             ; call the kernel
    

    ; Print out "Total time: "
    push eax                ; save eax current value on the stack
    mov	edx, totalmsg_l     ;message length
    mov	ecx, totalmsg       ;message to write
    mov	ebx,1               ;file descriptor (stdout)
    mov	eax,4               ;system call number (sys_write)
    int	0x80                ;call kernel
    pop eax                 ; return eax from the stack
    
    ; Print out the total time so far
    mov [var2], eax         ; move the timestamp after user presses enter to var2
    mov eax, [var2]         ; move var2 (timestamp after enter press) into eax register
    mov ebx, [var1]         ; move var1 (initialy timestamp at program start) into ebx register
    sub eax, ebx            ; subtraction function of ebx (initial timestamp) from eax (timestamp after 'enter' press)
    call iprint             ; call integer print function to print out seconds difference
    
    ; Print out "seconds "
    mov	edx, msg2_l         ;message length
    mov	ecx, msg2           ;message to write
    mov	ebx,1               ;file descriptor (stdout)
    mov	eax,4               ;system call number (sys_write)
    int	0x80                ;call kernel
    
    ; Print out "Laptime: "
    push eax                ; save eax current value on the stack
    mov	edx,lapmsg_l        ;message length
    mov	ecx, lapmsg         ;message to write
    mov	ebx,1               ;file descriptor (stdout)
    mov	eax,4               ;system call number (sys_write)
    int	0x80                ;call kernel
    pop eax                 ; return eax from the stack

    
    ; Print out the time for that lap
    mov eax, [var2]         ; Put the current timestamp into eax register
    mov ebx, [lastTimestamp]; Put the timestamp of end of last lap into ebx register
    sub eax, ebx            ; get the difference between the two timp stamps
    
    cmp eax, [fastestLap]
    jl  newFastest
returnSpot:

    call iprint             ; call integer print function to print out seconds difference

    ; Print out "seconds "
    mov	edx, msg2_l         ;message length
    mov	ecx, msg2           ;message to write
    mov	ebx,1               ;file descriptor (stdout)
    mov	eax,4               ;system call number (sys_write)
    int	0x80                ;call kernel


    ; Save the currentTimestamp into the lastTimestamp
    mov     eax, [var2]     ; currentTime into eax register
    mov     [lastTimestamp], eax    ; currentTime stored into lastTimestamp
    
    mov     eax, [totalLaps]
    inc     eax
    mov     [totalLaps], eax
    
    jmp     loopName            ; Jump to the loop section
    
exitLocation:


        ; Print out "Total time: "
    push eax                ; save eax current value on the stack
    mov	edx, totalmsg_l     ;message length
    mov	ecx, totalmsg       ;message to write
    mov	ebx,1               ;file descriptor (stdout)
    mov	eax,4               ;system call number (sys_write)
    int	0x80                ;call kernel
    pop eax                 ; return eax from the stack
    
    ; Print out the total time so far
    mov eax, [var2]         ; move var2 (timestamp after enter press) into eax register
    mov ebx, [var1]         ; move var1 (initialy timestamp at program start) into ebx register
    sub eax, ebx            ; subtraction function of ebx (initial timestamp) from eax (timestamp after 'enter' press)
    call iprint             ; call integer print function to print out seconds difference
    
    ; Print out "seconds "
    mov	edx, msg2_l         ;message length
    mov	ecx, msg2           ;message to write
    mov	ebx,1               ;file descriptor (stdout)
    mov	eax,4               ;system call number (sys_write)
    int	0x80                ;call kernel

    ; Print out "Total Laps "
    mov	    edx, cMsg_l         ;message length
    mov	    ecx, cMsg           ;message to write
    mov	    ebx,1               ;file descriptor (stdout)
    mov 	eax,4               ;system call number (sys_write)
    int 	0x80                ;call kernel
    
    mov     eax, [totalLaps]
    call    iprint

    ; Print out "Fastest laptime "
    mov	    edx, fMsg_l         ;message length
    mov	    ecx, fMsg           ;message to write
    mov	    ebx,1               ;file descriptor (stdout)
    mov 	eax,4               ;system call number (sys_write)
    int 	0x80                ;call kernel
    
    mov     eax, [fastestLap]
    call    iprint
    
    ; Print out "seconds "
    mov	edx, msg2_l         ;message length
    mov	ecx, msg2           ;message to write
    mov	ebx,1               ;file descriptor (stdout)
    mov	eax,4               ;system call number (sys_write)
    int	0x80                ;call kernel

    ; Print out "exit message "
    mov	    edx, eMsg_l         ;message length
    mov	    ecx, eMsg           ;message to write
    mov	    ebx,1               ;file descriptor (stdout)
    mov	    eax,4               ;system call number (sys_write)
    int	    0x80                ;call kernel

    
    mov     ebx, 0
    mov     eax, 1
    int     80h
   ; call    quit
   
newFastest:
    mov [fastestLap], eax;
    jmp returnSpot
