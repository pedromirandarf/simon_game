#include <p16f887.inc>
#define	button PORTB RB0



list p=16f887
__CONFIG _CONFIG1, 0x2ff4
__CONFIG _CONFIG2, 0x3FFF
	cblock	0x20	;Registradores de Uso geral 
			led_cnt 
			cnt_1
			cnt_2
			_wreg
			_status
			timer_counter50ms
			timer_counter5ms
			level	;Level = 1 Hard; 0- easy
			sequency
			move
	endc
	
	TMR0_50MS	EQU	.61
	LED_RED		EQU	B'00000001'
	LED_YELLOW	EQU	B'00000010'
	LED_GREEN	EQU	B'00000100'
	LED_BLUE 	EQU	B'00001000'
	
	
	
	
	org		0x00
	goto	Start	; Salta para um endereço de memória
	
	org		0x04	; Vetor de interrupção or interrupt vector 

	movwf	_wreg
	swapf	STATUS,W	; Ele troca os 4 bits mais significativos e os 4 menos e troca de lugar, ai ele copia. 
	
	movwf	_status
	clrf	STATUS	;voltando para o banco 0
	
	btfsc	INTCON,T0IF	; Verifico se é igual á 1 T0IF==1?
	goto	Timer0Interrupt	;yes
	goto	ExitInterrupt	;no
	
Timer0Interrupt:
	bcf		INTCON,T0IF	; Limpando a Flag
	incf	timer_counter5ms, F
	incf	timer_counter50ms, F
	movlw	TMR0_50MS
	movwf	TMR0		; Resetando o contador TMR0 
	goto	ExitInterrupt;
	
ExitInterrupt:
	movf	_wreg, W		; movendo a variável para W. 
	movwf	STATUS
	swapf	_wreg,F
	swapf	_wreg,F


	retfie			; sai da interrupção 
	
Start:
	clrf	timer_counter5ms
	clrf	timer_counter50ms
	
	;----- I/O CONFIG -----
	;configurar as portas,bancos e registradores 
	;TRIS@ --> Define a minha direção I/O da porta
	;Toda vez que eu tenho um F no final, altero um registrador de memória
	;mvlw --> Move o espaço de trabalho
	;BCF  --> Seta 0 
	;BSF --> Seta 1 
	bsf		STATUS,RP0	; Mudar para o banco 1, pq o bank 1 é 01.
	movlw	B'11110000'	; Coloquei 4 1111 por conta que uso os 4 leds
						; nas primeiras portas como saida, 1 Saida e 
						;0 Entrada 
					
	movwf	TRISA	; Movo o B'11110000' para o registrador TRISA 
	
	bsf		STATUS, RP1	;Vou para o banco 3 
	clrf	ANSEL	; Configurando os pinos como digitais, uma vez
					;que não usarei portas analógicas
	;--------TMR0 CONFIGURATION------------
	;INTCON, TMR0, OPTION_REG
	;OPTION_REG: T0CS=(INTOSC/4)
	;PSA= 0 ;(prescaller TMR0)
	;PS= 111
	bcf		STATUS,RP1;		Volto para o banco 1
	movlw	B'00000111'		; set PSA<2:0>, onde tem 1 eu estou setando
	iorwf	OPTION_REG,F	; Se eu colocar F, savo no próprio registrador de entrada(OPTION_REG)
	movlw	B'11010111'		;clear	T0CS, PSA
	andwf	OPTION_REG,F
	
	bcf		STATUS,RP0
	movlw	.61
	movwf	TMR0
	bcf		INTCON,T0IF
	bsf		INTCON,T0IE	
	bsf		INTCON,GIE
	
	

Main:
	;call	Delay_200ms
  	;call	RotinadeIncializacao
  	btfsc	button,RB0
  	;btfsc	PORTB, RB0	;Button pressed?
	goto	Main; Yes
	movf	TMR0, W
	movwf	move
	clrf	sequency
	btfsc	PORTB,RB1	; level select == o?
	goto	LevelEasy
	goto	LevelHard

LevelEasy:
	bsf		level,0
	goto Main_loop

Levelhard:
	bsf		level,0
	goto	Main_loop

Main_loop:



----------------------------------	
;Recebe move, atualizar o move

SorteiaNumero:
	;mascara
	movlw	0x03	; 00000111
	andwf	move	; limpa a mascara limpa bits <7:2>
	
	movlw	.0
	subwf	move, W
	btfsc	STATUS, Z
	retlw	LED_RED
	
	
	movlw	.1
	subwf	move, W
	btfsc	STATUS, Z
	retlw	LED_YELLOW
	
	
	movlw	.2
	subwf	move, W
	btfsc	STATUS, Z
	retlw	LED_GREEN
	
	movlw	.3
	subwf	move, W
	btfsc	STATUS, Z
	retlw	LED_BLUE


RotinadeIncializacao:
	bcf		STATUS, RP0	;RP0 --> 0
	bcf		STATUS, RP1	;RP1 --> 1 
	movlw	0x0F	;setando 0 no pino 00001111
	movwf	PORTA	;setando pinos RA0-RA3 para alto 
	; Som vem aqui parceiro
	call	Delay_1s	;Chama uma função de delay de 1 segundo 
	
	
	clrf	led_cnt	;led_cnt = 0

LedCountLoop:
	clrf	PORTA	;Limpo a porta A setando tudo para 0
	movlw	.0
	subwf	led_cnt,W
	btfsc	STATUS, Z
	bsf		PORTA, RA0
	;clrf	PORTA		;limpa pinos RA0-RA3
	
	movlw	.1
	subwf	led_cnt,W	;(Subtrai) 0 é W e 1 é o registrador que está 
						;sendo utilizado no momento
	btfsc	STATUS,Z	;Se Z(resto da subtração) vale 1, pula a linha e executa a linha 
						;de baixo
	bsf		PORTA, RA1	; led_cnt == 0;
	
	movlw	.2
	subwf	led_cnt,W
	btfsc	STATUS, Z
	bsf		PORTA, RA2
	
	
	movlw	.3
	subwf	led_cnt,W
	btfsc	STATUS, Z
	bsf		PORTA, RA3
	
	call	Delay_1s
	incf	led_cnt, F	; Incrementa led_cont
	
	movlw	.4
	subwf	led_cnt, W	
	btfss	STATUS, Z	; led_cnt ==4? Se o resto for 0, Z é 1
	goto	LedCountLoop	;NÃO
	clrf	PORTA		;
	return				; Como usei Call devo retornar para ;
						;principal
	 
	 
	
	
Delay_1s:
	call	Delay_200ms
	call	Delay_200ms
	call	Delay_200ms
	call	Delay_200ms
	call	Delay_200ms
	return 
	
Delay_1ms:
	movlw	.249
	movwf	cnt_1

Delay1:
	nop
	decfsz	cnt_1,F
	goto	Delay1
	return
	
Delay_200ms:
	movlw	.200
	movwf	cnt_2
Delay2:
	call	Delay_1ms
	decfsz	cnt_2,F
	goto	Delay2
	return
	
	end

	
	
	
	
	

;Se eu fizer um call, preciso colocar um return

