.text
.global main

@define constants,use as symbols
.set PUSHBTN_BASE, 0x41200000
.set SEVENSEG_BASE, 0x43C10000

main:

	LDR R1, = PUSHBTN_BASE  	@ load pushbutton address to R1
	LDR R2, = SEVENSEG_BASE 	@ load seven segments address to R2
	MOV R0, #0x01 				@ initialize R0 = 1
	STR R0, [R2]				@ enable 7-segments (default mode)
	LDR R0, =0x0				@ initialize R0 = 0


loop:
	MOV R8, R9					@ store the previous button input value
	MVN R8, R9					@ ~(prev_btn)
	STR R0, [R2, #0x04]			@ enable the offset value of the 7-seg initial state: 7-seg[0] (the rightmost one) = 0
	LDR R3, [R1]				@ load push button address from constant: *r1 --> r3
	AND R3, R3, #0x01 			@ left only btn0
	MOV R9, R3					@ store the current button input value
	AND R3, R8, R9				@ f = ~（prev_btn) & current_btn
	ADD R0, R0, R3				@ increase the value of 7-seg when press the btn0

、	// Since the design requirement ask to display 0 to A on 7 segments, then we need to clear to 0 when the value = B.
	// The codes below use the arithmetic, logical, and shift instructions to apporach the design requirement
	MOV R4, R0
	AND R4, R4, #0b00001000 	@ store x3
	LSR R4, #3 					@ shift R4 by 3 bits, keep x3

	MOV R5, R0
	EOR R5, R5, #0b00000100
	AND R5, R5, #0b00000100 	@ store inverse x2
	LSR R5, #2 					@ shift R5 by 2 bits, keep inverse x2

	MOV R6, R0
	AND R6, R6, #0b00000010 	@ store x1
	LSR R6, #1 					@ shift R6 by 1 bit, keep x1

	MOV R7, R0
	AND R7, R7, #0b00000001 	@ store x0


	AND R4, R4, R5
	AND R6, R6, R7
	AND R8, R4, R6				@ sw3 & ~(sw2) & sw1 & sw0 = 1

	SUB R8, R8, #0b1			@ return 0 if R8 = 1, return 1 if R8 = 0
	AND R0, R0, R8				@ clear to 0 if R8 = 0



	b loop

.end
