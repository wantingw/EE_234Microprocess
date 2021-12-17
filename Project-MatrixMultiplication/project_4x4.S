
.text
.global main

.set LED_BASE, 0x41210000
.set SSD_BASE, 0x43C10000
.set TTC_BASE, 0xF8001000
.set C_ZERO, 0x00000000
.set C_TIMER, 0x07
.set NR_ITER, 100
.set MATRIX_N, 4
.set MATRIX_N2, 64

// R11 (n), R12 (iterator)

main:
	BL init_LED		// turn off all the LEDs.
	BL disable_7seg	// turn it off.
	BL init_var		// R11 has n. You can use it as a global variable to get n.
	BL LED_0001		// turn on the rightmost LED.
	BL set_timer
	B init_matrix
main_loop:
	CMP R12, #NR_ITER	// # iterations
	BGE main_done
	B initialize		// you should implement this subroutine.
main_loop_inc:
	ADD R12, R12, #1
	ADD R13, R13, #MATRIX_N2	// adjust the SP to rerun the matrix multiplication.
	B main_loop
main_done:
	SUB R13, R13, #MATRIX_N2
	BL stop_counter
	B check_answer
check_answer_done:
	BL update_7seg
	B matrix_end

//this method use for loop to help matrix multiplication
initialize:
	MOV R4, #0		// int c = 0;
	MOV R5, #124	// int a = 17;
	MOV R6, #60		// int b = 8;
	MOV R7, #0		// int i = 0;
	MOV R8, #0		// comparator
	MOV R9, #0
	B matrix_mul_help

f1:
	//MOV R10, #4
	//MUL R0, R5, R10
	LDR R1, [SP, R5]
	SUB R5, R5, #4
	//MUL R0, R6, R10
	LDR R2, [SP, R6]
	SUB R6, R6, #16
	MUL R3, R1, R2
	ADD R4, R3, R4
	ADD R7, R7, #1
	B help_matrix_mul

help_matrix_mul:
	CMP R7, #4
	BLT f1
	PUSH {R4}
	MOV R4, #0
	ADD R5, R5, #20
	ADD R6, R6, #64
	MOV R7, #0
	ADD R8, R8, #1
	ADD R9, R9, #1
	B matrix_mul_help

matrix_mul_help:
	CMP R9, #4
	BEQ matrix_mul
	B help_matrix_mul

matrix_mul:	// R0 ~ R10, R14 are available. Don't touch R11, R12, R15. Place the result in the stack. See the slides.
	MOV R5, #124
	ADD R6, R6, #16
	MOV R9, #0
	CMP R8, #16
	BLT matrix_mul_help
	B main_loop_inc




init_LED:
	LDR R0, =LED_BASE
	MOV R1, #0
	STR R1, [R0]
	BX LR
LED_0001:
	LDR R0, =LED_BASE
	MOV R1, #1
	STR R1, [R0]
	BX LR
LED_1001:	// wrong
	LDR R0, =LED_BASE
	MOV R1, #9
	STR R1, [R0]
	BX LR
LED_1111:	// correct
	LDR R0, =LED_BASE
	MOV R1, #15
	STR R1, [R0]
	BX LR
set_timer:
	LDR R0, =TTC_BASE
	MOV R1, #C_TIMER
	STR R1, [R0]
	MOV R1, #0x23
	STR R1, [R0, #0x0C]
	LDR R1, =#0x7FFF
	STR R1, [R0, #0x24]
	MOV R1, #0x01
	STR R1, [R0, #0x60]
	MOV R1, #0x22
	STR R1, [R0, #0x0C]
	BX LR
stop_counter:
	LDR R0, =TTC_BASE
	MOV R1, #0x21
	STR R1, [R0, #0x0C]
init_var:
	LDR R0, =C_ZERO
	LDR R1, =C_ZERO
	LDR R2, =C_ZERO
	LDR R3, =C_ZERO
	LDR R4, =C_ZERO
	LDR R5, =C_ZERO
	LDR R6, =C_ZERO
	LDR R7, =C_ZERO
	LDR R8, =C_ZERO
	LDR R9, =C_ZERO
	LDR R10, =C_ZERO
	LDR R11, =MATRIX_N
	LDR R12, =C_ZERO
	BX LR
disable_7seg:
	LDR R0, =SSD_BASE
	MOV R1, #0x00
	STR R1, [R0]
	BX LR
update_7seg:
	LDR R4, =TTC_BASE
	LDR R4, [R4, #0x18]
	LDR R5, =0x80808080
	LDR R1, =0x0000000F

	AND R2, R1, R4
	ORR R5, R5, R2

	MOV R4, R4, LSR #4
	AND R2, R1, R4
	MOV R2, R2, LSL #8
	ORR R5, R5, R2

	MOV R4, R4, LSR #4
	AND R2, R1, R4
	MOV R2, R2, LSL #16
	ORR R5, R5, R2

	MOV R4, R4, LSR #4
	AND R2, R1, R4
	MOV R2, R2, LSL #24
	ORR R5, R5, R2

	LDR R0, =SSD_BASE
	MOV R1, #0x01
	STR R1, [R0]
	STR R5, [R0, #0x04]
	BX LR
init_matrix:
	LDR R0, =C_ZERO
	LDR R1, =C_ZERO
	LDR R2, =C_ZERO
	LDR R3, =C_ZERO
	MOV R0, #2
	MOV R1, #3
	MOV R2, #4
	MOV R3, #5
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	MOV R0, #1
	MOV R1, #3
	MOV R2, #2
	MOV R3, #4
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	MOV R0, #3
	MOV R1, #6
	MOV R2, #2
	MOV R3, #1
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	MOV R0, #2
	MOV R1, #7
	MOV R2, #3
	MOV R3, #2
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	MOV R0, #3
	MOV R1, #6
	MOV R2, #3
	MOV R3, #7
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	MOV R0, #5
	MOV R1, #6
	MOV R2, #7
	MOV R3, #3
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	MOV R0, #2
	MOV R1, #2
	MOV R2, #4
	MOV R3, #5
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	MOV R0, #7
	MOV R1, #3
	MOV R2, #1
	MOV R3, #2
	PUSH {R0}
	PUSH {R1}
	PUSH {R2}
	PUSH {R3}
	B main_loop
check_answer:
	LDR R0, [SP, #60]
	CMP R0, #64
	BNE wrong_answer
	LDR R0, [SP, #56]
	CMP R0, #53
	BNE wrong_answer
	LDR R0, [SP, #52]
	CMP R0, #48
	BNE wrong_answer
	LDR R0, [SP, #48]
	CMP R0, #53
	BNE wrong_answer
	LDR R0, [SP, #44]
	CMP R0, #50
	BNE wrong_answer
	LDR R0, [SP, #40]
	CMP R0, #40
	BNE wrong_answer
	LDR R0, [SP, #36]
	CMP R0, #36
	BNE wrong_answer
	LDR R0, [SP, #32]
	CMP R0, #34
	BNE wrong_answer
	LDR R0, [SP, #28]
	CMP R0, #50
	BNE wrong_answer
	LDR R0, [SP, #24]
	CMP R0, #61
	BNE wrong_answer
	LDR R0, [SP, #20]
	CMP R0, #60
	BNE wrong_answer
	LDR R0, [SP, #16]
	CMP R0, #51
	BNE wrong_answer
	LDR R0, [SP, #12]
	CMP R0, #61
	BNE wrong_answer
	LDR R0, [SP, #8]
	CMP R0, #66
	BNE wrong_answer
	LDR R0, [SP, #4]
	CMP R0, #69
	BNE wrong_answer
	LDR R0, [SP]
	CMP R0, #54
	BNE wrong_answer
	B correct_answer
correct_answer:
	BL LED_1111
	B check_answer_done
wrong_answer:
	BL LED_1001
	B check_answer_done

matrix_end:

.end
