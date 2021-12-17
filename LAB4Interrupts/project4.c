
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_exception.h"

// data type
typedef uint32_t TDATA;
typedef uint32_t* TADDR;

const TADDR LED_BASE = (TADDR) 0x41210000;
const TADDR SW_BASE = (TADDR) 0x41220000;
const TADDR BTN_BASE = (TADDR) 0x41200000;
const TADDR SSD_BASE = (TADDR) 0x43C10000;

const TADDR SLCR_BASE = (TADDR) 0xF8000000;  // System Level Control Registers (SLCR)

const TADDR MIO_PIN_16 = (TADDR) 0xF8000740;
const TADDR MIO_PIN_17 = (TADDR) 0xF8000744;
const TADDR MIO_PIN_18 = (TADDR) 0xF8000748;
const TADDR MIO_PIN_50 = (TADDR) 0xF80007C8;	// btn4
const TADDR MIO_PIN_51 = (TADDR) 0xF80007CC;	// btn5
const TADDR GPIO_DIRM_0 = (TADDR) 0xE000A204;  // Direction mode bank 0
const TADDR GPIO_OUTE_0 = (TADDR) 0xE000A208;  // Output enable bank 0
const TADDR GPIO_DIRM_1 = (TADDR) 0xE000A244;  // Direction mode bank 1

const TADDR ICCPMR_BASE_ADDR = (TADDR) 0xF8F00104;  // Interrupt priority mask
const TADDR ICCICR_BASE_ADDR = (TADDR) 0xF8F00100;  // CPU interface control
const TADDR ICDDCR_BASE_ADDR = (TADDR) 0xF8F01000;  // Distributor control
const TADDR ICDISER_BASE_ADDR = (TADDR) 0xF8F01100;  // Interrupt set enable
const TADDR ICDICER_BASE_ADDR = (TADDR) 0xF8F01180;  // Interrupt clear/enable
const TADDR ICDIPR_BASE_ADDR = (TADDR) 0xF8F01400;  // Interrupt priority register
const TADDR ICDIPTR_BASE_ADDR = (TADDR) 0xF8F01800;  // Interrupt processor targets
const TADDR ICDICFR_BASE_ADDR = (TADDR) 0xF8F01C00;  // Interrupt configuration
const TADDR ICCIAR_BASE_ADDR = (TADDR) 0xF8F0010C;  // Interrupt acknowledge
const TADDR ICCEOIR_BASE_ADDR = (TADDR) 0xF8F00110;  // End of interrupt

const TADDR GPIO_MTDATA_OUT_0 = (TADDR) 0xE000A004;  // Maskable data out in bank 0
const TADDR GPIO_INT_DIS_0 = (TADDR) 0xE000A214;  // Interrupt disable bank 0
const TADDR GPIO_INT_EN_1 = (TADDR) 0xE000A250;  // Interrupt enable bank 1
const TADDR GPIO_INT_DIS_1 = (TADDR) 0xE000A254;  // Interrupt disable bank 1
const TADDR GPIO_INT_STAT_1 = (TADDR) 0xE000A258;  // Interrupt status bank 1
const TADDR GPIO_INT_TYPE_1 = (TADDR) 0xE000A25C;  // Interrupt type bank 1
const TADDR GPIO_INT_POL_1 = (TADDR) 0xE000A260;  // Interrupt polarity bank 1
const TADDR GPIO_INT_ANY_1 = (TADDR) 0xE000A264;  // Interrupt any edge sensitive bank 1

// Timer/Counter
const TADDR GTC_REG0 = (TADDR) 0xF8F00200;
const TADDR GTC_REG1 = (TADDR) 0xF8F00204;
const TADDR GTC_CON_REG = (TADDR) 0xF8F00208;
const TADDR GTC_ISR = (TADDR) 0xF8F0020C;
const TADDR GTC_COMP0 = (TADDR) 0xF8F00210;
const TADDR GTC_COMP1 = (TADDR) 0xF8F00214;
const TADDR GTC_AI_REG = (TADDR) 0xF8F00218;

static inline void vset(TADDR addr, TDATA val) {
	*(addr) = val;
}

static inline TDATA vget(TADDR addr) {
	return *(addr);
}

void update_LEDs (TDATA v) {
	vset (LED_BASE, v);
}

void enable_7seg () {
	TDATA data;
	data = 0x00000001;
	vset (SSD_BASE, data);  // enable 7seg
}

void update_7seg (TDATA v) {
	vset (SSD_BASE+1, v);
}

// To-do: Define your own data structure for the stopwatch.
typedef struct VSW{
	int stage_counter;	// value
	TDATA time_counter;
	int control; // if control=1, the stage= run & background
				 // if control=0, the stage= reset& stop --> use this int control processing timer
	TDATA d1;
	TDATA d2;
	TDATA d3;
	TDATA d4;

}VSW;

// To-do: Define some useful functions for the stopwatch.
// For example, "inc_time" increases the stopwatch by 0.01s.

void inc_time(){
	struct VSW vsw;
	TDATA zero_clear = 0x00000001;			// use to clear the seven segment back to 0
	int a = 0;								// use to help zero_clear switch left
	TDATA value = 0x00000001; 				// value use to round up
	int b = 2;
	for (int i = 7; i > 0; i=i-2){
		TDATA x = (vsw.time_counter) << (i*4);
		TDATA y = x >> (7*4);
		if (y > 0x09){
			zero_clear = zero_clear << (a*4);
			zero_clear = ~(zero_clear);
			vsw.time_counter = (vsw.time_counter) & zero_clear;
			value = value << (b*4);
			vsw.time_counter = (vsw.time_counter) + value;
			a +=2;
			b +=2;
			if (a > 4){
				a = 0;
			}
			if (b > 6){
				b = 2;
			}

		}

	}

}


void configure_IO() {
	vset(SLCR_BASE+2, 0x0000DF0D);  // unlock (enable writing to the SLCR registers)
	vset(MIO_PIN_50, 0x00000600);  // BTN4
	vset(MIO_PIN_51, 0x00000600);  // BTN5
	vset(MIO_PIN_16, 0x00001600);  // RGB LED B
	vset(MIO_PIN_17, 0x00001600);  // RGB LED R
	vset(MIO_PIN_18, 0x00001600);  // RGB LED G
	vset(GPIO_DIRM_0, 0x00070000);
	vset(GPIO_OUTE_0, 0x00070000);
	vset(GPIO_DIRM_1, 0x00000000);
}

void disable_interrupts() {
	TDATA mode = 0xDF;  // system mode [4:0] and IRQ disabled [7]
	TDATA read_cpsr = 0;  // used to read the previous CPSR value
	TDATA bit_mask = 0xFF;  // used to clear the bottom eight bits
	__asm__ __volatile__ ("mrs %0, cpsr\n" : "=r" (read_cpsr));  // execute the assembly instruction MSR
	__asm__ __volatile__ ("msr cpsr,%0\n" : : "r" ((read_cpsr & (~bit_mask)) | mode));  // change the lower eight bits
}

void configure_GIC() {
	vset(ICDIPTR_BASE_ADDR + 13, 0x00000000);  // disable handling interrupt #52
	vset(ICDICER_BASE_ADDR + 1, 0x00000000);  // clear GPIO interrupts
	vset(ICDDCR_BASE_ADDR, 0x00000000);  // disable the distributer of the GIC
	vset(ICDIPR_BASE_ADDR + 13, 0x000000A0);  // Set the priority level of interrupt #54
	vset(ICDIPTR_BASE_ADDR + 13, 0x00000001);  // assign interrupt #52 to CPU0
	vset(ICDICFR_BASE_ADDR + 3, 0x55555555);  // sensitivity for interrupt #52.
	vset(ICDISER_BASE_ADDR + 1, 0x00100000);
	vset(ICCPMR_BASE_ADDR, 0x000000FF);  // processor's priority level
	vset(ICCICR_BASE_ADDR, 0x00000003);
	vset(ICDDCR_BASE_ADDR, 0x00000001);  // enable the distributer of the GIC
}

void initialize_GPIO_interrupts() {
	vset(GPIO_INT_DIS_1, 0xFFFFFFFF);
	vset(GPIO_INT_DIS_0, 0xFFFFFFFF);
	vset(GPIO_INT_STAT_1, 0xFFFFFFFF);  // clear status register
	vset(GPIO_INT_TYPE_1, 0x000C0000);  // type of interrupt rising edge
	vset(GPIO_INT_POL_1, 0x000C0000);  // polarity of interrupt
	vset(GPIO_INT_ANY_1, 0x00000000);  // interrupt any edge sensitivity
	vset(GPIO_INT_EN_1, 0x000C0000);  // enable interrupts in bank 0
}

void enable_interrupts() {
	TDATA read_cpsr = 0;  // used to read the previous CPSR value
	TDATA mode = 0x5F;  // System mode [4:0] and IRQ enabled [7]
	TDATA bit_mask = 0xFF;  // used to clear bottom 8 bits
	__asm__ __volatile__ ("mrs %0, cpsr\n" : "=r" (read_cpsr));
	__asm__ __volatile__ ("msr cpsr, %0\n" : : "r" ((read_cpsr & (~bit_mask)) | mode));  // change the lower eight bits
}

void initialize_global_timer() {
	vset(GTC_CON_REG, 0x00000000);  // disable the interrupt and the timer
	vset(GTC_REG1, 0x00000000);  // counter(high) = 0
	vset(GTC_REG0, 0x00000000);  // counter(low) = 0
	vset(GTC_ISR, 0x00000001);  // clear the event flag
	vset(GTC_COMP0, 3333333);  // set the comparator to 0.01 second under prescale of 1
	vset(GTC_COMP1, 0x00000000);  // the CPU_3x2x freq. is 333.3333MHz, so 1/CPU_3x2x is 10,000us = 10ms = 0.01s
	vset(GTC_CON_REG, 0x00000100);
}

void configure_GIC_GTC() {  // ID #27
	vset(ICDIPTR_BASE_ADDR + 6, 0x00000000);  // disable handling interrupt #27
	vset(ICDICER_BASE_ADDR, 0x08000000);  // clear interrupt #27
	vset(ICDDCR_BASE_ADDR, 0x00000000);  // disable the distributer of the GIC
	vset(ICDIPR_BASE_ADDR + 6, 0x90000000);  // Set the priority level of interrupt #27
	vset(ICDIPTR_BASE_ADDR + 6, 0x01000000);  // assign interrupt #27 to CPU0
	vset(ICDICFR_BASE_ADDR + 1, 0x7DC00000);  // sensitivity for interrupt #27.
	vset(ICDISER_BASE_ADDR, 0x08000000);  // enable interrupt #27
	vset(ICCPMR_BASE_ADDR, 0x000000FF);  // processor's priority level
	vset(ICCICR_BASE_ADDR, 0x00000003);
	vset(ICDDCR_BASE_ADDR, 0x00000001);  // enable the distributer of the GIC
}

void configure_GIC_GPIO() {  // interrupt #52
	vset(ICDIPTR_BASE_ADDR + 13, 0x00000000);  // disable handling interrupt #52
	vset(ICDICER_BASE_ADDR + 1, 0x00000000);  // clear GPIO interrupts
	vset(ICDDCR_BASE_ADDR, 0x00000000);  // disable the distributer of the GIC
	vset(ICDIPR_BASE_ADDR + 13, 0x000000A0);  // Set the priority level of interrupt #54
	vset(ICDIPTR_BASE_ADDR + 13, 0x00000001);  // assign interrupt #52 to CPU0
	vset(ICDICFR_BASE_ADDR + 3, 0x55555555);  // sensitivity for interrupt #52.
	vset(ICDISER_BASE_ADDR + 1, 0x00100000);
	vset(ICCPMR_BASE_ADDR, 0x000000FF);  // processor's priority level
	vset(ICCICR_BASE_ADDR, 0x00000003);
	vset(ICDDCR_BASE_ADDR, 0x00000001);  // enable the distributer of the GIC
}

void initialize_GTC_interrupts() {
	vset(GTC_CON_REG, 0x0000010F);  // restart the timer
	vset(GTC_ISR, 0x00000001);
}

void IRQ_Handler(void* data) {

	// 1. Type casting of the data.
	VSW *sw = (VSW*) data;

	// 2. Get the interrupt ID using ICCIAR.
	TDATA interrupt_ID = vget(ICCIAR_BASE_ADDR);

	if ( interrupt_ID == 52 ) {  // from GPIO

		// 3. Get the interrupt using GPIO_INT_STAT_1.
		TDATA GPIO_INT = vget(GPIO_INT_STAT_1);
		TDATA button_press = 0x000C0000 & GPIO_INT;  // corresponds to pins 50 or 51

		// 4. Process the buttons (BTN4 and BTN5).
		// state machines & change the int counter value between 0 and 1
		if ( button_press == 0x80000 ){ // btn5
			if (sw->stage_counter == 0){
				sw->stage_counter = 0;
				sw->control = 0;
				// stage_reset
			}
			else if (sw->stage_counter==1){
				sw->stage_counter=3;
				sw->control = 1;
				// stage_background
			}
			else if (sw->stage_counter==2){
				sw->stage_counter = 0;
				sw->control = 0;
				// stage_reset
			}
			else if (sw->stage_counter==3){
				sw->stage_counter=1;
				sw->control = 1;
				// stage_run
			}
		}

		else if( button_press == 0x40000 ){ //btn4
			if (sw->stage_counter == 0){
				sw->stage_counter = 1;
				sw->control = 1;
				// stage_run
			}
			else if (sw->stage_counter == 1){
				sw->stage_counter = 2;
				sw->control = 0;
				// stage_stop
			}
			else if (sw->stage_counter == 2){
				sw->stage_counter = 1;
				sw->control = 1;
				// stage_run
			}
			else if (sw->stage_counter == 3){
				sw->stage_counter = 2;
				sw->control = 0;
				// stage_stop
			}

		}
		vset(GPIO_INT_STAT_1, 0xFFFFFF);  // clear the GPIO interrupt status
	}

	else if ( interrupt_ID == 27 ) {  // from GTC
		// 5. Process the timer.
		if (sw->control == 0){
			// do nothing
		}

		// if the int counter ==1, the states are run and background
		else if (sw->control == 1){
			// increase the time by 1 each 10ms
			sw->time_counter += 1;
			// clear to 00.00 if it reaches to 99.99
			if (sw->time_counter > 0x89098989){
				sw->time_counter = 0x80008080;
			}
			// use to clear the seven segment back to 0
			int a = 0;
			int b = 2;
			for (int i = 7; i >= 0; i=i-2){
				TDATA zero_clear = 0x0000000F;
				TDATA value = 0x00000001;
				TDATA x = (sw->time_counter) << (i*4);
				TDATA y = x >> (7*4);
				if (y >= 0xA){
					zero_clear = zero_clear << (a*4);
					zero_clear = ~(zero_clear);
					sw->time_counter = (sw->time_counter) & zero_clear;  // clear current digit back to zero when it reaches to 10

					value = value << (b*4);
					sw->time_counter = (sw->time_counter) + value; // increase the value of next digit by 1
					a +=2;
					b +=2;
					if (a > 4){
						a = 0;
					}
					if (b > 6){
						b = 2;
					}

				}

			}

		}

		// 6. Reset the timer counter (GTC_REG0, GTC_REG1).
		vset(GTC_REG0, 0x0);
		vset(GTC_REG1, 0x0);

		// 7. Clear the ISR event flag (GTC_ISR).
		vset(GTC_ISR, 0x00000001);
	}
	vset(ICCEOIR_BASE_ADDR, interrupt_ID);  // clear the GIC GPIO interrupt
}



int main()
{
    init_platform();


	// 1. Declare a variable for the stopwatch.
    struct VSW sw;
	//VSW sw;
	sw.time_counter= 0x80008080;
	sw.stage_counter= 0; //? initial stage count=0, stage_reset
	TDATA reset_value = 0x80008080;

    // 2. Enable the seven-segment display.
    enable_7seg();

    configure_IO();
    initialize_global_timer();
    disable_interrupts();
    configure_GIC_GPIO();  // configure the GPIO interrupt (ID #52)
   	configure_GIC_GTC();  // configure the global timer interrupt (ID #27)
    initialize_GPIO_interrupts();
    initialize_GTC_interrupts();
    Xil_ExceptionRegisterHandler(5, IRQ_Handler, (void*) &sw);
    enable_interrupts();

    while (1) {
    	if (sw.stage_counter == 0){
    		sw.time_counter = reset_value;
    		update_7seg(sw.time_counter);
    	}
    	else if(sw.stage_counter == 1){
    		update_7seg (sw.time_counter);
    	}
    	else if(sw.stage_counter == 2){
    		update_7seg(sw.time_counter);
    	}
    	else if(sw.stage_counter == 3){
    		//
    	}



    }

    cleanup_platform();

    return 0;
}

