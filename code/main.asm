#include <p16f887.inc>
#define  button PORTB, RB0
list p=16f887
__CONFIG _CONFIG1, 0x2FF4
__CONFIG _CONFIG2, 0x3FFF
	cblock 0x20
		led_cnt
		cnt_1
		cnt_2
		_wreg
		_status
		timer_counter_5s
		timer_counter_500ms
		level ; level:
			  ;	0 = hard
			  ; 1 = easy
		sequency
		move
		last_move
		last_input
		timeout	;0- Não Ocorreu
				;1- Ocorreu
		current_move
	endc
	
	HARD_TIMEOUT	EQU	.3
	EASY_TIMEOUT	EQU	.5	
	MOVE_BASE_ADDR	EQU 0x5F
	TMR0_50MS	EQU .61
	LED_RED		EQU B'00000001'
	LED_YELLOW	EQU	B'00000010'
	LED_GREEN	EQU	B'00000100'
	LED_BLUE	EQU	B'00001000'
	
	org		0x00	; reset vector
	goto 	Start
	
	org		0x04	;interrupt vector
	movwf	_wreg
	swapf	STATUS, W
	movwf	_status
	clrf	STATUS
	btfsc	INTCON, T0IF	; T0IF==1?
	goto 	Timer0Interrupt	;yes
	goto	ExitInterrupt	;no

Timer0Interrupt:
	bcf		INTCON, T0IF
	incf	timer_counter_5s, F	
	incf	timer_counter_500ms, F
	movlw	TMR0_50MS
	movwf	TMR0			;reset tmr0 counter	
	goto	ExitInterrupt

ExitInterrupt:
	swapf	_status, W
	movwf	STATUS
	swapf	_wreg, F
	swapf	_wreg, W
	retfie
	
Start:
	;------TESTE SUB---------
	;movlw	.1
	;sublw	.1
	
	;----- I/O config ------
	clrf	timer_counter_5s
	clrf	timer_counter_500ms
	bsf 	STATUS, RP0	; change to bank1
	movlw 	B'11110000'
	movwf 	TRISA		; config RA0-R3 as ouput
						; and RA4-RA7 as input
	bcf		TRISB, TRISB0	; config RB0 as input - start
	bcf		TRISB, TRISB1	; config RB1 as input - level
	bsf 	STATUS, RP1	; change to bank3
	clrf	ANSEL		; configure all PORTA,
						; pins as digital I/O
	clrf	ANSELH		; PORTB pins as digital I/O
	;------TMR0 configuration-----------
	;INTCON, TMR0, OPTION_REG
	;OPTION_REG: 
	;T0CS=0(INTOSC/4)
	;PSA= 0 (prescaler TMR0) 
	;PS= 111
	bcf		STATUS, RP1	 	; change to bank1
	movlw	b'00000111'
	iorwf	OPTION_REG, F	; set PSA<2:0>
	movlw   b'11010111' 	
	andwf	OPTION_REG, F	; clear T0CS, PSA
	bcf		STATUS, RP0		; change to bank0
	movlw	.61
	movwf 	TMR0
	bcf		INTCON, T0IF	; clear interrupt flag
	bsf		INTCON, T0IE	; enable TMR0 interrut
	bsf		INTCON, GIE		; enable interrupts
	call	RotinaInicializacao
	movlw	MOVE_BASE_ADDR
	movwf	FSR
	bcf		STATUS, IRP
	clrf	last_move
	
Main:
	btfsc	button		; button start pressed?
	goto 	Main
	movf	TMR0, W
	movwf	move		; copy TMR0 to move
	clrf	sequency	; sequency = 0
	btfsc	PORTB, RB1 	; level select
	goto	LevelEasy
	goto	LevelHard
LevelEasy:
	bcf		level, 0
	goto	Main_Loop
LevelHard:
	bsf		level, 0	
	goto 	Main_Loop
	
Main_Loop:
	call	SorteiaNumero
	call	StoreNumber
	goto 	Main

;-------------
;Recebe move	
SorteiaNumero:
	movlw 	0x03
	andwf	move	;clear bits <7:2>
	
	movlw 	.0
	subwf	move, W
	btfsc	STATUS, Z
	retlw	LED_RED
	
	movlw 	.1
	subwf	move, W
	btfsc	STATUS, Z
	retlw	LED_YELLOW
	
	movlw 	.2
	subwf	move, W
	btfsc	STATUS, Z
	retlw	LED_GREEN
	
	movlw 	.3
	subwf	move, W
	btfsc	STATUS, Z
	retlw	LED_BLUE

StoreNumber:
	movwf	INDF
	incf 	FSR,F
	incf	last_move,F
	return

EntradaMovimento:
	bcf		STATUS,RP1
	bcf		STATUS,RP0 ; voltando para o banco 0
	clrf	last_input
	movlw	MOVE_BASE_ADDR
	movwf	FSR		; Setando o a base de endereço, apontando
					; pro inicio.
InputLoop:
	movf	PORTD, W
	andlw	0x0F	; Limpando do RD<7:4>
	sublw	0x00	; Verificar se algum botão foi apertado 
	btfsc	STATUS,Z	;Se a subtração for 0, Z==1, então 
						;Então estou testando se algum botão
						;foi apertado 
	goto	ButtonNotPressed
	goto	ButtonPressed

ButtonNotPressed:
	btfss	timeout, 0	;ocorreu um timeout?
	goto	InputLoop ; Não
	return
	
ButtonPressed:
	movwf	current_move; Armazena o conteudo do botão
	call	CompareInput;
	sublw	.0
	btfss	STATUS, Z		;Botão Correto pressionado?
	return					; Naão
	incf	last_input,F	;sim
	incf	FSR, F
	
	movf	last_input,W
	subwf	last_move, W
	btfsc	STATUS, C	;last_input > last_move?
	return
	goto	InputLoop
	
	


CompareInput:
	movf	current_move
	;movlw	LED_RED
	subwf	INDF, W
	btfss	STATUS, Z
	retlw	.0		; apertou botão errado 
	retlw	current_move
	
	
	
	
	
	
	
	

	
RotinaInicializacao:
	bcf 	STATUS, RP1
	bcf 	STATUS, RP0 ; change to bank0
	movlw 	0x0F			
	movwf 	PORTA		; set pins RA0-RA3
	call	Delay_1s	; call delay function			
	clrf 	led_cnt		; led_cnt = 0
	
LedCountLoop:
	clrf	PORTA		; clear pins RA0-RA3
	movlw 	.0
	subwf 	led_cnt, W
	btfsc	STATUS, Z	; led_cnt=0?
	bsf 	PORTA, RA0	; yes
	
	movlw 	.1
	subwf 	led_cnt, W
	btfsc	STATUS, Z	; led_cnt=1?
	bsf 	PORTA, RA1	; yes
					
	movlw 	.2
	subwf 	led_cnt, W
	btfsc	STATUS, Z	; led_cnt=1?
	bsf 	PORTA, RA2	; yes
	
	movlw 	.3
	subwf 	led_cnt, W
	btfsc	STATUS, Z	; led_cnt=1?
	bsf 	PORTA, RA3	; yes
	
	call 	Delay_200ms								
	incf	led_cnt, F 	; incrementa led_cnt
	
	movlw	.4
	subwf	led_cnt, W	
	btfss 	STATUS, Z 	; led_cnt=4?
	goto	LedCountLoop		; no
	clrf	PORTA		; yes
	return
;---------------------CALCULO DE DELAY---------------------

	
Delay_1s:
	call	Delay_200ms
	call	Delay_200ms
	call	Delay_200ms
	call	Delay_200ms
	call	Delay_200ms
	return
	
Delay_1ms:
	movlw	.248
	movwf	cnt_1
Delay1:
	nop
	decfsz	cnt_1, F	;decrement cnt_1
	goto 	Delay1
	return				; cnt equals 0

Delay_200ms:
	movlw 	.200
	movwf	cnt_2
Delay2:
	call	Delay_1ms
	decfsz	cnt_2, F
	goto	Delay2	
	return
	
	end
	
