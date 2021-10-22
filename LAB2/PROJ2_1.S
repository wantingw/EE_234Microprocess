.text
.global main

// Debounce: When you push the button (BTN#0), detect the first rising or falling edge in the button input signal. Then igonore all the following rising or fallling edeges for a fixed amount of time.

@define constants,use as symbols
.set PUSHBTN_BASE, 0x41200000
.set SEVENSEG_BASE, 0x43C10000

main:
	LDR R1, = PUSHBTN_BASE			@ load pushbutton address to R1
	LDR R2, = SEVENSEG_BASE			@ load sevensegments address to R2
	MOV R0, #0X1					@ initialize R0 as 1(on)
	STR R0, [R2]					@ enable 7-segments  (default mode)
	LDR R0, = 0x0					@ load constant 0 to R0
	LDR R10, = 0x00040000			@ load time constant to R10
	MOV R7, #0x0

processor1:
	MOV R8, R9
	MVN R8, R9
	STR R0, [R2, #0x04]		@ enable the offset value of the 7-seg initial state: 7-seg[0] (the rightmost one) = 0
	LDR R3, [R1]			@ load push button address from constant
	AND R3, R3, #0x01 		@ left only btn0
	MOV R9, R3
	AND R3, R8, R9
	AND R0, R0, #0xff			@ represent the rightmost one
	ADD R0, R0, R3				@ increase the value of 7-seg when push the btn0
	MOV R7, #0x0

loop:
	ADD R7, R7, #0x1			@ increase the value of R7
	CMP R7, R10					@ compare R7 and the time constant T
	BLT loop					@ if R7 < R10, jump back to loop
	b processor1				@ if R7 >= R10, jump to address processor1

.end
