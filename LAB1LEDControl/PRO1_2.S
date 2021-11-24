.text
.global main

.set LD4_BASE, 0x43C00000
.set SW_BASE, 0x41220000

main:
	LDR R1, =LD4_BASE  //  load LD4 address to R1
	LDR R2, =SW_BASE   //  load the switches address to R2


loop:
	LDR R0,[R2]		// load switch address from constant
	AND R0, R0, #0x0f  // turn the other four switches (sw4-sw7) off

	AND R3, R0, #0b0001 // let sw0 on/ff -> led4R on/off
	AND R4, R0, #0b0010 // let sw1 on/ff -> led4G on/off
	AND R5, R0, #0b0100 // let sw2 on/off -> led4B on/off

	LSR R4, #1 // shift R4 to the right by 1 bit
	LSR R5, #2 // shift R5 to the right by 2 bits
	LSR R0, #3 // shift R0 to the right by 3 bits

	EOR R0, R0, #0x1 // xor the sw1

	AND R3, R0, R3 // sw3 & sw0 on/off -> led4R on/off
	AND R4, R0, R4 // sw3 & sw1 on/off -> led4R on/off
	AND R5, R0, R5 // sw3 & sw2 on/off -> led4R on/off

	STR R3, [R1, #0x00]// enable R of LD4
	STR R4, [R1, #0x10]// enable G of LD4
	STR R5, [R1, #0x20]// enable B of LD4

	STR R3, [R1, #0x04]  // Period of R of LD4 = 255
	STR R4, [R1, #0x14]  // Period of G of LD4 = 255
	STR R5, [R1, #0x24]  // Period of B of LD4 = 255

	STR R3, [R1, #0x08]  // Width of B of LD4 = 0 (always off)
	STR R4, [R1, #0x18]  // Width of G of LD4 = 0 (always off)
	STR R5, [R1, #0x28]  // Width of R of LD4 = 255 (always on)

	b loop

.end
