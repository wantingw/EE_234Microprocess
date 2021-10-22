.text
.global main

// PWM: Control the RGB LED brightness by adjusting the the width
// Specific requirements: 1) @t=0, the LED is OFF. 2) The R of the LED gets brighter as t increases. 3) When t = T seconds (T is approximately 1~2 seconds), the brightness reaches the maximum value. 4) Then, the R gets darker as t increase. 5) When t = 2T seconds (T is approximately 1~2 seconds), the brightness reaches the minimum value. 4) Then, the R gets darker as t increase.  6) Repeat for G and B.
@define constants,use as symbols
.set LD4_BASE, 0x43C00000

main:

	LDR R0, =LD4_BASE	 // load LD4 address to R0
	MOV R10, #0x00080000 // initial the time T
	MOV R9, #0			 // initial the color counter value
	MOV R8, #0			 // initial i
	MOV R7, #0x01		 // value use to enable RGB
	STR R7, [R0, #0x00]  // enable R of LD4
	STR R7, [R0, #0x10]  // enable G of LD4
	STR R7, [R0, #0x20]  // enable B of LD4
	MOV R7, #0xFF		 // value 255 use to change the period and width
	STR R7, [R0, #0x04]  // Period of R of LD4 = 255
	STR R7, [R0, #0x14]  // Period of G of LD4 = 255
	STR R7, [R0, #0x24]  // Period of B of LD4 = 255
	MOV R6, #0				// value use to compare with time constant
	MOV R5, #0				// initial j
	MOV R4, #0x28


loop_brightnesscontrol_increase:
	MOV R5, #0
	ADD R8, R8, #1
	STR R8, [R0, R4]  // Width of R of LD4 = 255 (always on)
	CMP R8, R7
	BLT loop_timecontrol_increase
	B loop_brightnesscontrol_decrease

loop_timecontrol_increase:
	ADD R5, R5, #1
	CMP R5, R10
	BLT loop_timecontrol_increase
	B loop_brightnesscontrol_increase

loop_brightnesscontrol_decrease:
	MOV R5, #0
	SUB R8, R8, #1
	STR R8, [R0, R4]
	CMP R8, R6
	BGE loop_timecontrol_decrease
	B loop_changecolor

loop_timecontrol_decrease:
	ADD R5, R5, #1
	CMP R5, R10
	BLT loop_timecontrol_decrease
	B loop_brightnesscontrol_decrease

loop_changecolor:
	STR R6, [R0, #0x08]
	STR R6, [R0, #0x18]
	STR R6, [R0, #0x28]
	ADD R9, R9, #1
	CMP R9, #1
	BEQ loop_green
	CMP R9, #2
	BEQ loop_blue
	CMP R9, #2
	BGT loop_back

loop_back:
	MOV R9, #0
	MOV R4, #0x28
	B loop_brightnesscontrol_increase

loop_blue:
	MOV R4, #0x08
	B loop_brightnesscontrol_increase

loop_green:
	MOV R4, #0x18
	B loop_brightnesscontrol_increase

.end


