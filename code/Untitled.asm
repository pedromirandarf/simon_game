#include <pic16f887.inc>

list p=16f887

	cblock	0x20	;Registradores de Uso geral 
			led_cnt 
	endc
	
	org		0x00
	goto	Start	; Salta para um endereço de memória
	
	org		0x04	; Vetor de interrupção or interrupt vector 
	retfie			; sai da interrupção 
	
Start:
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
	
	bcf		STATUS, RP1	;Vou para o banco 3 
	clrf	ANSEL	; Configurando os pinos como digitais, uma vez
					;que não usarei portas analógicas

Main:
	goto	RotinadeIncializacao
	
RotinadeIncializacao:
	bcf		STATUS, RP0	;RP0 --> 0
	bcf		STATUS, RP1	;RP1 --> 1 
	movlw	0x0F	;setando 0 no pino 00001111
	movwf	PORTA	;setando pinos RA0-RA3 para alto 
	; Som vem aqui parceiro
	call	Delay_1s	;Chama uma função de delay de 1 segundo 
	clrf	PORTA	;Limpo a porta A setando tudo para 0
	
	
	
	
Delay_1s:


	
	
	
	
	



