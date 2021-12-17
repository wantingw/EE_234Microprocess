
.text
.global main

.set LED_BASE, 0x41210000
.set SSD_BASE, 0x43C10000
.set TTC_BASE, 0xF8001000
.set C_ZERO, 0x00000000
.set C_TIMER, 0x07
.set NR_ITER, 100
.set MATRIX_N, 2
.set MATRIX_N2, 16

// R11 (n), R12 (iterator)

main:
	BL init_LED			// turn off all the LEDs.
	BL disable_7seg		// turn it off.
	BL init_var			// R11 has n. You can use it as a global variable to get n.
	BL LED_0001			// turn on the rightmost LED.
	BL set_timer
	B init_matrix
main_loop:
	CMP R12, #NR_ITER	// # iterations
	BGE main_done
	B matrix_mul		// you should implement this subroutine.
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

matrix_mul:	// R0 ~ R10, R14 are available. Don't touch R11, R12, R15. Place the result in the stack. See the slides.
	LDR R0, [SP, #28]
	LDR R1, [SP, #12]
	LDR R3, [SP, #24]
	LDR R4, [SP, #4]
	MUL R2, R0, R1
	MUL R4, R3, R4
	ADD R2, R2, R4
	PUSH {R2}

	LDR R0, [SP, #32]
	LDR R1, [SP, #12]
	LDR R3, [SP, #28]
	LDR R4, [SP, #4]
	MUL R2, R0, R1
	MUL R4, R3, R4
	ADD R2, R2, R4
	PUSH {R2}

	LDR R0, [SP, #28]
	LDR R1, [SP, #20]
	LDR R3, [SP, #24]
	LDR R4, [SP, #12]
	MUL R2, R0, R1
	MUL R4, R3, R4
	ADD R2, R2, R4
	PUSH {R2}

	LDR R0, [SP, #32]
	LDR R1, [SP, #20]
	LDR R3, [SP, #28]
	LDR R4, [SP, #12]
	MUL R2, R0, R1
	MUL R4, R3, R4
	ADD R2, R2, R4
	PUSH {R2}
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
	MOV R0, #3
	MOV R1, #4
	PUSH {R0}
	PUSH {R1}
	MOV R0, #5
	MOV R1, #6
	PUSH {R0}
	PUSH {R1}
	MOV R0, #7
	MOV R1, #8
	PUSH {R0}
	PUSH {R1}
	MOV R0, #9
	MOV R1, #10
	PUSH {R0}
	PUSH {R1}
	B main_loop
check_answer:
	LDR R0, [SP, #12]
	CMP R0, #57
	BNE wrong_answer
	LDR R0, [SP, #8]
	CMP R0, #64
	BNE wrong_answer
	LDR R0, [SP, #4]
	CMP R0, #89
	BNE wrong_answer
	LDR R0, [SP]
	CMP R0, #100
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
