### EE_234 **Microprocessor Systems**

- An introduction to microprocessor using ARM assembly language and C/C++ code. This repository uses to keep tracking of the EE_234 Microprocessor System Labs & Project. Do not use these codes dishonestly.

- We used ZYNQ (ARM+FPGA) board from Xilinx.A Xilinx ZYNQ XC7007S MPSoC with an ARM® Cortex-A9 processor and an Artix FPGA.

  <img src="https://github.com/wantingw/Storage/blob/master/blackboard.png?raw=true" style="zoom: 33%;" />

  ---

  ### Contents
  
  - ##### [LAB 1: LED Control](#LAB 1: LED Control)
  
  - ##### [LAB 2: Debounce & PWM Control](#LAB 2: Debounce & PWM Control)
  
  - ##### [LAB 3: Stop Watch](#LAB 3: Stop Watch )
  
  - ##### [LAB 4: Interrupts](#LAB 4: Interrupts)
  
  - #### [Project: Matrix Multiplication](#Project: Matrix Multiplication)
  
  ---
  
  

#### LAB 1: LED Control

- ##### Project1_1:

  - Control the LEDs (LD0 - LD3) use the four switches (SW0 - SW3)
  - Turn on the LEDs# if SW# is OFF
  - Turn off LEDs# if SW#is ON

- ##### Project1_2:

  - Control the RGB LED (LD4) use the four switches (SW0 - SW3)
  - Highest Priority: if SW3 is ON, LD4 is off.
  - If SW3 is OFF:
    - Turn the R On/Off if SW0 is On/Off
    - Turn the G On/Off if SW1 is On/Off
    - Turn the B On/Off if SW2 is On/Off
  - Design Specifications: Do not use branch instructions, use onlt arithmetic, logical, shift, and memory instructions.

- ##### Project1_3:

  - Control the seven-segment display (7_seg) use the push button BTN0

  - Initial Stage: 7-seg[0] = 0

  - If BTN0 is pushed, increase 7-seg[0] by 1.

  - If 7-seg[0] is 'A' and the BTN0 is pushed, clear the 7-seg[0] back to 0.

  - Input Button Edge Detection:

    <img src="https://github.com/wantingw/Storage/blob/master/edge_detecr.jpeg?raw=true" alt="edge_detecr.jpeg" style="zoom:50%;" />

  - Design Specifications: Do not use branch instructions, use onlt arithmetic, logical, shift, and memory instructions.

  ---

  

#### LAB 2: Debounce & PWM Control

- ##### Project 2_1: Debounce

  - Push BTN0 to increase the corresponding digits in the 7-segment display.
  - Detect the first rising or falling edge in the button input signal. Ignore all the following rising or falling edges for a fixed amount of time.
  - T: 0x00040000

- ##### Project 2_2: PWM

  - Control RGB LED 4 brightness
  - At t = 0, the LED is OFF. The Red of the LED gets brigher as t increases.
  - When t = T seconds (T is approximately 1~2s), the brightness researchs the maximum value.
  - Then, the Red of the LED gets darker as t increases.
  - When t = 2T seconds, the brightness researches the minimum value.
  - Repeat the process above for Green and Blue of the LED.

  ---

  

#### LAB 3: Stop Watch 

- ##### State Machine:

  <img src="https://github.com/wantingw/Storage/blob/master/state_machine.jpeg?raw=true" style="zoom: 50%;" />

  - ##### Each State:

    - Reset: reset to 0
    - Run: start the stop watch
    - Stop: stop the stop watch
    - Background: counting in the background, not visualizing. 

    ---

    

#### LAB 4: Interrupts

- In Lab 3, we used polling to detect the input signal of the push button, which is not as efficiency as we expected. In this lab, we would use C codes and the concepts of interrupt to detect the input signals for push buttons and the time signals. We would use the same state machine figure in Lab 3 but replace the BTN 0 as BTN4 and BTN3 as BTN 5.

- Hardware interrupts are generated by hardware devices to get the attention of the CPU. When the push button is pressed, it generates an interrupt ID causing the CPU to suspend its present activity and execute the push button interrupt service routine. 

- In this lab, we also generate a timer interrupt ID each 10 ms, this interrupt increases the time counting display for the stop watch.

  ---

  

#### Project: Matrix Multiplication

- Implement a matrix multiplication subroutine:
  $$
  Y = A * B
  $$

- Both A and B are n by n matrices of unsigned integers (n and all the elements of A and B will be given). Compute the matrix Y and store the result in the memory. The runtime should be as small as possible for this project. We would use 7-segments to display the run time for the matrix multiplication.

- Algorithm:

  <img src="https://raw.githubusercontent.com/wantingw/Storage/0a4d7078362edc7c463a77b4b603e592dae7ead8/Screen%20Shot%202021-11-23%20at%2010.31.55%20PM.png" style="zoom:50%;" />

  - Input memory & Output memory:

    <img src="https://github.com/wantingw/Storage/blob/master/Screen%20Shot%202021-11-23%20at%2010.34.55%20PM.png?raw=true" alt="Screen Shot 2021-11-23 at 10.34.55 PM.png" style="zoom:50%;" />

    

  - Final Outcomes:
    - It uses the four LEDs (LD 0 ~ LD 3) and 7-seg to indicate the final outcome.
    - It turns on LD0 right before it starts the matrix multiplication. (7-seg 
      is OFF)
    - If the final answer is wrong, LD3 and LD0 are turned on. (7-seg 
      shows the runtime in HEX).
    - If the final answer is correct, all the LEDs are turned on. (7-seg 
      shows the runtime in HEX).
