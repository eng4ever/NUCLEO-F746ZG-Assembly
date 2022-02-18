; Using NUCLEO-F746ZG Board
; GPIO example in Assembly
;LED1 PB0
;LED2 PB7
;LED3 PB14
;B1 PC13

RCC_BASE		EQU			0x40023800
RCC_AHB1ENR		EQU			0x30
	
GPIOB_BASE		EQU			0x40020400
GPIOC_BASE		EQU			0x40020800
	
GPIO_MODER		EQU			0x00
GPIO_IDR		EQU			0x10
GPIO_ODR		EQU			0x14
	
	
		AREA		myCode, CODE
		EXPORT		__main
		ALIGN
		ENTRY

__main	PROC
		
		;enable clock for GPIOB and GPIOC
		LDR	R0, =RCC_BASE
		LDR	R1, [R0, #RCC_AHB1ENR]
		ORR	R1, R1, #(3 << 1)
		STR	R1, [R0, #RCC_AHB1ENR]		
		
		;configure PB0 (LED1), PB7 (LED2) and PB14 (LED3)  as outputs
		LDR	R0, =GPIOB_BASE
		LDR	R1, [R0, #GPIO_MODER]
		BIC	R1, R1, #(3 << 0)
		BIC	R1, R1, #(3 << 14)
		BIC	R1, R1, #(3 << 28)
		ORR	R1, R1, #(1 << 0)
		ORR	R1, R1, #(1 << 14)
		ORR	R1, R1, #(1 << 28)
		STR	R1, [R0, #GPIO_MODER]	

		;configure PC13 (B1) as input
		LDR	R0, =GPIOC_BASE
		LDR	R1, [R0, #GPIO_MODER]
		BIC	R1, #(3 << 26)
		STR	R1, [R0, #GPIO_MODER]
		
		;turn LED1 and LED2 on
		LDR	R0, =GPIOB_BASE
		LDR	R1, [R0, #GPIO_ODR]
		ORR	R1, R1, #(1 << 0)
		ORR	R1, R1, #(1 << 7)
		STR	R1, [R0, #GPIO_ODR]	
		
		;read button 1 (PC13)
wait	LDR	R0, =GPIOC_BASE
		LDR	R1, [R0, #GPIO_IDR]
		AND	R1, R1, #(1 << 13)
		CMP	R1, #(1 << 13)
		BEQ	turn_on
		B	wait
		
turn_on
		BL	blink_LED

stop	;B	stop
		B	wait			;read push button again
		
		ENDP
		
blink_LED	PROC
		PUSH {LR}
		LDR	R0, =GPIOB_BASE
		LDR	R1, [R0, #GPIO_ODR]
		MOV	R2, #5
		
blink_loop
		ORR	R1, R1, #(1 << 14)
		STR	R1, [R0, #GPIO_ODR]	
		BL	delay_1sec
		BIC	R1, R1, #(1 << 14)
		STR	R1, [R0, #GPIO_ODR]	
		BL	delay_1sec
		SUBS R2, R2, #1
		BNE	blink_loop
		
		POP {LR}
		BX LR
		ENDP

delay_1sec	PROC
		PUSH {R4, LR}
		LDR	R4, =0xF42400
delay_loop	
		NOP
		SUBS R4, R4, #1
		CMP R4, #0
		BNE delay_loop
		POP	{R4, PC}
		ENDP
		
		END
