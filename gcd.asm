SECTION .data

prompt: db              "Enter a positive integer: "
len:   equ             $-prompt

err: db			"Bad Number.", 0x0a
lenEr:	equ		$-err

message: db		"Greatest common divisor = "
lenMes:	equ		$-message

nl: db			"", 0x0a
nll: equ		$-nl

NULL: equ		0

SECTION .bss

digits: equ             20
input1: resb    digits + 2
input2: resb    digits + 2

holder: resb	22


SECTION .text

global _start

_start:
	call		readNum			; call readNum
	mov		esi, input1		; load input1 into psi
	mov		ebp, esi		; load esi into ebp
	call		getInt      		; call getInt
	push		esi         		; load into stack
	mov		esi, input2		; load input2 into esi
	mov		ebp, esi 		; load esi into ebp
	call    	getInt      		; call getInt
	push		esi         		; load into stack
	pop 		edi 			; pop to edi
	pop  		esi 			; pop to esi
	call		gcd			; call GCD
	nop					; stall
	mov             eax, 4                  ; write
	mov             ebx, 1                  ; to terminal output
	mov             ecx, message            ; prompt string
	mov             edx, lenMes		; length
	int		80H			; syscall
	call		makeDec			; call makeDec
	nop					; stall
	mov             eax, 4                  ; write
	mov             ebx, 1                  ; to terminal output
	mov             ecx, nl	                ; nl
	mov             edx, nll		; length 1
	int		80H			; syscall
	mov 		eax, 1                  ; set up end
	mov 		ebx, 0                  ; and
	int		80H			; exit

readNum:
 	nop					; stall
	mov             eax, 4                  ; write
	mov             ebx, 1                  ; to terminal output
	mov             ecx, prompt             ; prompt string
	mov             edx, len		; of length len
	int		80H			; syscall
	mov             eax, 3                  ; read
	mov             ebx, 0                  ; from keyboard input
	mov             ecx, input1             ; into the input buffer
	mov             edx, digits+1           ; digits + 1 bytes
	int		80H			; syscall
	nop	                                ; stall
	mov             eax, 4                  ; write
	mov             ebx, 1                  ; to terminal output
	mov             ecx, prompt             ; prompt string
	mov             edx, len		; length len
	int		80H			; syscall
	mov             eax, 3                  ; read
	mov             ebx, 0                  ; from keyboard input
	mov             ecx, input2             ; into the input buffer
	mov             edx, digits+1           ; digits + 1 bytes
	int   80H     				; syscall
	ret					; ret

getInt:
	nop					; wait
	mov		edi, 1			; load 1 into edi (digitValue)
	mov		ebx, 0			; load 0 into esp (result)
	mov		ecx, digits		; hold max # of digits
format:
	cmp  	byte  	[esi], 10 		; check for nl
	je    		continue	        ; if so, continue
	add      	esi, 1		        ; increment address
	LOOP    	format 		        ; loop format
continue:
	sub     	esi, 1 		        ; decrement address by 1
	cmp     	esi, ebp		; check for address
	jl      	endInt 	  	        ; end if at beginning input1
	cmp   	byte 	[esi], 32  		; check for spaces
	je      	endInt		        ; if so, end
	cmp   	byte 	[esi], 48  		; check against 0
	jl      	error 		        ; if less, error
	cmp   	byte 	[esi], 57  		; check against 9
	ja      	error   	        ; if greater, error
	mov  		bl, BYTE[esi]     	; load current byte into bl
	sub		ebx, 48			; format to int
	mov     	eax, edi 	        ; load eax with digitValue
	mul   	dword  	ebx 		        ; multiply edx
	mov		ebx, 0			; reset ebx
	add     	ebx, eax	        ; add result into stack
	mov     	eax, 10       		; move 10 into eax
	mul     	edi      	        ; edi x 10
	mov     	edi, eax      		; load eax into edi
	add		[holder], ebx		; load ebx value into holder
	mov		ebx, 0			; reset ebx
	jmp    		continue		; amp to continue
endInt:
	mov		ebx, 0			; reset ebx
	mov		ebx, [holder]		; load holder value into ebx
	mov     	esi, ebx		; load ebx into esi
	sub		[holder], esi		; reset holder value
	ret                   			; return, result in esi

gcd:
	cmp   		esi, edi 	        ; compare num1 and num2
	ja    		greater       		; jump if >
	jb    		less            	; jump if <
	ret             		        ; needed result in esi
greater:
	sub   		esi, edi	        ; decrease esi
	jmp   		gcd   	                ; go to gcd
less:
	sub   		edi, esi        	; decrease edi
	jmp    		gcd                    ; go to gcd

makeDec:
	mov		ebp, esp		; hold stack pointer
makeDec2:
	mov		edx, 0	                ; empty edx
	mov		eax, 0			; empty eax
	mov   		eax, esi        	; store divisor in eax
	mov	  	edi, 0			; reset edi
	mov	  	edi, 10	 		; load 10 in edi
	div   	dword 	edi 	                ; div divisor by 10
	cmp   		eax, 0  	        ; see if result is 0
	je    		done 		        ; if so, done
	push		edx
	mov   		esi, eax   	        ; else, return divisor to esi
	jmp   		makeDec2    	        ; repeat
done:
	mov   		ecx, edx	        ; load ecx with value
	add   		ecx, 48 	        ; turn into char
	mov		[holder], ecx		; store in holder
	mov		ecx, holder		; return to ecx
	mov             eax, 4                  ; write
	mov             ebx, 1                  ; to terminal output
	mov   		edx, 22    		; length 1
	int   		80H       		; syscall
	cmp		esp, ebp		; check if back at stack pointer
	je		exit			; if so, exit
	pop		edx			; pop into edx
	jmp		done			; jump to done
exit:
	ret
error:
	nop					; stall
  mov             eax, 4                  ; write
  mov             ebx, 1                  ; to terminal output
  mov             ecx, err                ; prompt err
  mov             edx, lenEr		; lengthEr long
  int		80H			; syscall
	mov             eax, 1                  ; set up process exit
  mov             ebx, 0
  int		80H			; exit
