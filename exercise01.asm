; File: toupper.asm last updated 09/26/2001
;
; Convert user input to upper case.
;
; Assemble using NASM:  nasm -f elf toupper.asm
; Link with ld:  ld toupper.o 
;

%define STDIN 0
%define STDOUT 1
%define SYSCALL_EXIT  1
%define SYSCALL_READ  3
%define SYSCALL_WRITE 4
%define BUFLEN 256


        SECTION .data                   ; initialized data section

msg1:   db "Enter the ISBN: "           ; user prompt 
len1:   equ $-msg1                      ; length of first message

msg2:   db 10, "This is not a right ISBN", 10  	; original string label 
len2:   equ $-msg2                      ; length of second message

msg3:   db 10, "Correct ISBN", 10               ; converted string label
len3:   equ $-msg3

msg4:   db 10, "Read error", 10         ; error message
len4:   equ $-msg4

msg5:	db 10, "not enough ISBN", 10	;error if ISBN is less than 10
len5:	equ $-msg5

msg6:	db 10, "Too much numbers", 10	;error if ISBN is more than 10
len6:	equ $-msg6

msg7:	db 10, "just enough numbers. lets check" , 10
len7:	equ $-msg7
	
        SECTION .bss                    ; uninitialized data section
input: 	resb BUFLEN                     ; buffer for read
sum: 	resb 1 	                        ; sum
rlen:   resb 4                          ; length
t: 	resb 1				

        SECTION .text                   ; Code section.
        global  _start                  ; let loader see entry point

_start: nop                             ; Entry point.
start:                                  ; address for gdb

        ; prompt user for input
        ;
        mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        mov     ecx, msg1               ; Arg2: addr of message
        mov     edx, len1               ; Arg3: length of message
        int     080h                   ; ask kernel to write

        ; read user input
        ;
        mov     eax, SYSCALL_READ       ; read function
        mov     ebx, STDIN              ; Arg 1: file descriptor
        mov     ecx, input	       ; Arg 2: address of buffer
        mov     edx, BUFLEN             ; Arg 3: buffer length
        int     080h

	; error check
        ;
	mov     [rlen], eax             ; save length of input
	cmp     eax, 11              ; check if the amount of number is 10
	je      read_OK                 ; if char is 10 read = ok
	jg	read_lot		 ;jump if input is more than 10
	jl	read_less		 ;jump if input is less than 10
read_lot:
	mov	eax, SYSCALL_WRITE ;error message if input is more than 10
	mov	ebx, STDOUT
	mov	ecx, msg6
	mov	edx, len6
	int	080h
	jmp 	exit		;skip over rest
read_less:
	mov	eax, SYSCALL_WRITE ;error message if input is less than 10
	MOV	ebx, STDOUT
	MOV	ecx, msg5
	MOV	edx, len5
	INT	080h
	jmp	exit		;skip over rest
read_end:	
    mov     eax, SYSCALL_WRITE      ; ow print error mesg
    mov     ebx, STDOUT
    mov     ecx, msg4
    mov     edx, len4
    int     080h
    jmp     exit                    ; skip over rest
read_OK:
	mov	eax, SYSCALL_WRITE ;run if the input is exactly 10
	mov	ebx, STDOUT
	mov	ecx, msg7
	mov 	edx, len7
	int	080h
        ; assuming rlen = 10
        ;
Loop_init:
    mov     cl, [rlen]             ; initialize count
    mov     esi, input              ; point to start of buffer
    mov     ah, [sum]               ; point to start get sum
	mov	al, [t]			; point to start to time
	and	al, 0			;set time to zero
	mov	bl, 0
Loop_top:
	mov	bl, [esi]
	cmp	bl, 'X'		; compare if num is 'x'
	je	if_X
    add     al, [esi]               ; add # to t
	;; cmp	bl, 'X'			;compare if num is 'x'
	;; je	if_X			;jump if num is 'x'
	sub	al, 48			;subtract to make number from ascii
    inc     esi                     ; update source pointer
    cmp     al, 11                 ; less than '11'?
    jge     if_subT		       
Loop_cont1:
	add	ah, al			;add t to sum
	cmp	ah, 11			; less than 11?			
	jge	if_subSum

	
Loop_cont2:
    dec     cl			; update char count
	cmp	cl, 1			
	jnz 	Loop_top                  ; loop to top if more nums
	jz	Loop_end		  ;loop ende

if_X:
	add	al, 10		;if num is x then set 10
 	inc	esi
 	cmp	al, 11
 	jge	if_subT
	jmp	Loop_cont1	;return to loop
if_subT:
	sub	al, 11		;subtract 11 from t
	jmp	Loop_cont1	;return to loop
	
if_subSum:
	sub	ah, 11		;subtract 11 from sum
	jmp	Loop_cont2	;return to loop
	
Loop_end:


        ; print out user input for feedback
        ;
        ;
	cmp	ah, 0		;is sum = 0?
	jne	wrongISBN	;return if sum != 0
        mov     eax, SYSCALL_WRITE      ; write message
        mov     ebx, STDOUT
        mov     ecx, msg3	;correct isbn
        mov     edx, len3
        int     080h
	jmp	exit		;program done skip rest

wrongISBN:
	mov	eax, SYSCALL_WRITE
	mov	ebx, STDOUT	;print out the isbn is wrong
	mov	ecx, msg2
	mov	edx, len2
	int	080h
	
        ; final exit
        ;
exit:   mov     eax, SYSCALL_EXIT       ; exit function
        mov     ebx, 0                  ; exit code, 0=normal
        int     080h                    ; ask kernel to take over
