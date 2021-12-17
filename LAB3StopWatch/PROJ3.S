.text
.global main

@define constants,use as symbols
.set PUSHBTN_BASE, 0x41200000
.set SSD_BASE, 0x43C10000
.set TTC_BASE, 0xF8001000

main:
	BL enable_7seg
	BL set_timer
	MOV R9, #0
	MOV R10, #0
	MOV R11, #0
	MOV R12, #0
	MOV R4, #0
	BL update_7seg
	MOV R6, #0

stage_reset:
	MOV R9, #0
	MOV R10, #0
	MOV R11, #0
	MOV R12, #0
	BL update_7seg
	BL determine_BTN0
	CMP R5, #1
	BNE stage_reset
	MOV R6, #1
	B stage_determine

stage_determine:
	CMP R6, #0
	BEQ stage_reset
	CMP R6, #1
	BEQ loop1
	CMP R6, #2
	BEQ stage_stop
	CMP R6, #3
	BEQ loop2_1

loop1: // time counter with display
	LDR R0, =TTC_BASE
	LDR R1, [R0, #0x54]  // if the counter reaches the max (0.01s), this will be 1.
	CMP R1, #1
	BNE loop1
	BL update_7seg		// unconditional jump to update_7seg to dispaly the 1 for the first digit

	BL determine_BTN0	// determine stage_run btn0
	CMP R5, #1
	BEQ change_to_stop

	BL determine_BTN3	// determine stage_run btn3
	CMP R5, #1
	BEQ change_to_bg

	ADD R9, R9, #1
	CMP R9, #10
	BLT loop1
	// the counter is set to 0.01s. Now, whenever R9 becomes 10 (0.1s), we update the 7seg.
	MOV R9, #0
	ADD R10, R10, #1
	CMP R10, #10
	BLT proc1		// display the second digit
	MOV R10, #0
	ADD R11, R11, #1
	CMP R11, #10
	BLT proc1		// display the third digit
	MOV R11, #0
	ADD R12, R12, #1
	CMP R12, #10
	BLT proc1		// display the 4th digit
	MOV R12, #0

proc1:
	CMP R6, #3
	BEQ loop1
	BL update_7seg
	B loop1

loop2_1:
	LDR R0, =SSD_BASE
	MOV R1, #0x0
	STR R1, [R0]


loop2: //time counter

	LDR R0, =TTC_BASE
	LDR R1, [R0, #0x54]  // if the counter reaches the max (0.01s), this will be 1.
	CMP R1, #1
	BNE loop2
	// BL update_7seg		// unconditional jump to update_7seg to dispaly the 1 for the first digit

	BL determine_BTN0
	CMP R5, #1
	BEQ change_to_stop

	BL determine_BTN3
	CMP R5, #1
	BEQ change_to_run

	ADD R9, R9, #1
	CMP R9, #10
	BLT loop2
	// the counter is set to 0.01s. Now, whenever R9 becomes 10 (0.1s), we update the 7seg.
	MOV R9, #0
	ADD R10, R10, #1
	CMP R10, #10
	BLT proc2		// display the second digit
	MOV R10, #0
	ADD R11, R11, #1
	CMP R11, #10
	BLT proc2		// display the third digit
	MOV R11, #0
	ADD R12, R12, #1
	CMP R12, #10
	BLT proc2		// display the 4th digit
	MOV R12, #0

proc2:
	B loop2


change_to_stop:
	MOV R6, #2
	BL enable_7seg
	B stage_determine

change_to_bg:
	MOV R6, #3
	B stage_determine

change_to_run:
	MOV R6, #1
	BL enable_7seg
	B stage_determine

change_to_reset:
	MOV R6, #0
	B stage_determine

stage_stop:

	BL update_7seg

	BL determine_BTN0
	CMP R5, #1
	BEQ change_to_run

	BL determine_BTN3
	CMP R5, #1
	BEQ change_to_reset

	B stage_stop


enable_7seg:
	LDR R0, =SSD_BASE
	MOV R1, #0x01
	STR R1, [R0]
	BX LR

update_7seg:	// var: R10, R11
//display
	LDR R0, =SSD_BASE
	LDR R1, =0x80008080
	ORR R1, R1, R9
	MOV R2, R10, LSL #8
	ORR R1, R1, R2
	MOV R2, R11, LSL #16
	ORR R1, R1, R2
	MOV R2, R12, LSL #24
	ORR R1, R1, R2
	STR R1, [R0, #0x04]
	BX LR



determine_BTN0:
	MOV R5, #0
	MVN R3, R4
	LDR R7, =PUSHBTN_BASE
	LDR R7, [R7]
	AND R7, R7, #0x01		// left with only btn0
	MOV R4, R7
	AND R7, R3, R4
	CMP R7, #1
	BEQ btn_detection
	BX LR

determine_BTN3:
	MOV R5, #0
	MVN R3, R8
	LDR R7, =PUSHBTN_BASE
	LDR R7, [R7]
	AND R7, R7, #0b1000
	LSR R7, R7, #3			// left with only btn3
	MOV R8, R7
	AND R7, R3, R8
	CMP R7, #1
	BEQ btn_detection
	BX LR

btn_detection:
	MOV R5, #1
	BX LR


set_timer:
	LDR R0, =TTC_BASE
	// 1. [Clock Control] External clock edge: no. Clock source: no (use the system clock).
	// Prescaler: yes (N = 4'b1001 = 9, i.e., divided by 1024. The timer will run one tick every 1024 system clock ticks.).
	// The system clock is 111MHz, the timer will run one tick every 9.23us.
	MOV R1, #0x13
	STR R1, [R0]
	// 2. [Counter Control] Waveform polarity: 0. Output waveform: disable.
	// Counter reset: no. Match mode: no. Up counter. Counter disable.
	MOV R1, #0x21
	STR R1, [R0, #0x0C]
	// 3. [Interval Value] # ticks before the timer resets itself. After the prescale, the frequency
	// of the timer counter is 111MHz / 1024 = 108.4kHz (111MHz is the system clock).
	// If we set the interval to 1083 ticks, an interval will be approximately 0.01 second.
	LDR R1, =#1083
	STR R1, [R0, #0x24]
	// 4. [Interrupt Enable] Enable the interrupt.
	MOV R1, #0x01
	STR R1, [R0, #0x60]
	// 5. Turn on the counter and enable it (interval mode).
	MOV R1, #0x22
	STR R1, [R0, #0x0C]
	BX LR




.end
