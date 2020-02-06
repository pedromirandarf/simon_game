#include <pic16f887.inc>

list p=16f887

	cblock	0x20	;Registradores de Uso geral 
			led_cnt 
	endc
	
	org		0x00
	goto	Start	; Salta para um endere�o de mem�ria
	
	org		0x04	; Vetor de interrup��o or interrupt vector 
	retfie			; sai da interrup��o 
	
Start:
	;----- I/O CONFIG -----
	;configurar as portas,bancos e registradores 
	;TRIS@ --> Define a minha dire��o I/O da porta
	;Toda vez que eu tenho um F no final, altero um registrador de mem�ria
	;mvlw --> Move o espa�o de trabalho
	;BCF  --> Seta 0 
	;BSF --> Seta 1 
	bsf		STATUS,RP0	; Mudar para o banco 1, pq o bank 1 � 01.
	movlw	B'11110000'	; Coloquei 4 1111 por conta que uso os 4 leds
						; nas primeiras portas como saida, 1 Saida e 
						;0 Entrada 
	movwf	TRISA	; Movo o B'11110000' para o registrador TRISA 
	
	bcf		STATUS, RP1	;Vou para o banco 3 
	clrf	ANSEL	; Configurando os pinos como digitais, uma vez
					;que n�o usarei portas anal�gicas

Main:
	call	RotinadeIncializacao
	
RotinadeIncializacao:
	bcf		STATUS, RP0	;RP0 --> 0
	bcf		STATUS, RP1	;RP1 --> 1 
	movlw	0x0F	;setando 0 no pino 00001111
	movwf	PORTA	;setando pinos RA0-RA3 para alto 
	; Som vem aqui parceiro
	call	Delay_1s	;Chama uma fun��o de delay de 1 segundo 
	clrf	PORTA	;Limpo a porta A setando tudo para 0
	clrf led_cnt	;led_cnt = 0

LedCountLoop:
	movlw	.0
	subwf	led_cnt,W
	btfsc	STATUS, Z
	bsf		PORTA, RA0
	
	clrf	PORTA		;limpa pinos RA0-RA3
	movlw	.1
	subwf	led_cnt,W	;(Subtrai) 0 � W e 1 � o registrador que est� 
						;sendo utilizado no momento
	btfsc	STATUS,Z	;Se Z(resto da subtra��o) vale 1, pula a linha e executa a linha 
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
	
	call	Delay_200ms
	incf	led_cnt, F	; Incrementa led_cont
	
	movlw	.4
	subwf	led_cnt, W	
	btfss	STATUS, Z	; led_cnt ==4? Se o resto for 0, Z � 1
	goto	LedCountLoop	;N�O
	clrf	PORTA		;
	return				; Como usei Call devo retornar para ;
						;principal
	 
	
	
Delay_1s:
Delay_200ms

	
	
	
	
	

;Se eu fizer um call, preciso colocar um return

