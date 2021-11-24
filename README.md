#### 												EE_234 **Microprocessor Systems**

- An introduction to microprocessor using ARM assembly language and C/C++ code. This repository uses to keep tracking of the EE_234 Microprocessor System Labs & Project. Do not use these codes dishonestly.

- We used ZYNQ (ARM+FPGA) board from Xilinx.A Xilinx ZYNQ XC7007S MPSoC with an ARM® Cortex-A9 processor and an Artix FPGA.

  <img src="https://github.com/wantingw/Storage/blob/master/blackboard.png?raw=true" style="zoom:50%;" />

  ---

  

##### LAB 1: LED Control

- ###### Project1_1:

  - Control the LEDs (LD0 - LD3) use the four switches (SW0 - SW3)
  - Turn on the LEDs# if SW# is OFF
  - Turn off LEDs# if SW#is ON

- ###### Project1_2:

  - Control the RGB LED (LD4) use the four switches (SW0 - SW3)
  - Highest Priority: if SW3 is ON, LD4 is off.
  - If SW3 is OFF:
    - Turn the R On/Off if SW0 is On/Off
    - Turn the G On/Off if SW1 is On/Off
    - Turn the B On/Off if SW2 is On/Off
  - Design Specifications: Do not use branch instructions, use onlt arithmetic, logical, shift, and memory instructions.

- ###### Project1_3:

  - Control the seven-segment display (7_seg) use the push button BTN0
  - Initial Stage: 7-seg[0] = 0
  - If BTN0 is pushed, increase 7-seg[0] by 1.
  - If 7-seg[0] is 'A' and the BTN0 is pushed, clear the 7-seg[0] back to 0.
  - Design Specifications: Do not use branch instructions, use onlt arithmetic, logical, shift, and memory instructions.

  ---

  

##### LAB 2: Debounce & PWM ControlLAB 3: Stop Watch 

##### LAB 3: Stop Watch 

##### LAB 4: Interrupts



##### Project: Matrix Multiplication



