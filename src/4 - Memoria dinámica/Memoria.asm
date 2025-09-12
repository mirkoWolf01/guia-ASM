extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
	push RBP
	XOR RAX, RAX ;vacio un registro, donde va a ir mi resultado

	.ciclo:
		mov DL, BYTE [RDI] ; me guardo el caracter en el que estoy ahora
		mov CL, BYTE [RSI] ; me guardo el caracter en el que estoy ahora

		cmp CL, DL ; comparo los valores
		jg .casoMayor
		jb .casoMenor

		cmp DL, 0
		je .fin

		inc RDI
		inc RSI
		jmp .ciclo

	.casoMenor:
	add RAX, -1
	jmp .fin
	
	.casoMayor:
	add RAX, 1

	.fin:
	pop RBP
	ret

; char* strClone(char* a)
strClone:
	push RBP
	mov RBP, RSP
	sub RSP, 16 ; esta alineada

	mov [RBP-8], RDI ; guardo el valor del puntero en la pila
	
	call strLen 
	
	inc RAX 
	mov [RBP-16], RAX ; guardo el valor del largo
	mov RDI, RAX ; guardo el valor del largo
	
	call malloc

	mov RDI, [RBP-8] ; traigo el puntero guardado
	mov RSI, [RBP-16] ; traigo el largo del str que guarde
	; RAX tiene la dir del malloc

	mov [RBP-8], RAX  ; !!! guardo el puntero al primer elemento
	.ciclo:
		cmp RSI, 0
		je .fin 
		
		
		mov BL, BYTE [RDI] ; me guardo el caracter a copiar
		mov [RAX], BL 	; guardo el 


		inc RAX
		inc RDI
		dec RSI

		jmp .ciclo


	.fin:
	mov RAX, [RBP-8]  ; traigo el puntero al primer elemento del resultado
	add RSP, 16
	pop RBP
	ret

; void strDelete(char* a)
strDelete:
	push RBP

	call free 

	pop RBP
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	push RBP	

	mov RAX, RDI
	mov RDI, RSI
	mov RSI, RAX

	call fprintf

	.fin:
	pop RBP
	ret

; uint32_t strLen(char* a)
strLen:
	push RBP 

	XOR RAX, RAX ; lo uso para almacenar el resultado

	.while: 
	mov DL, BYTE [RDI] ; me guardo el caracter en el que estoy ahora

	cmp DL, 0
	je .fin

	inc RDI ; paso a la siguiente dir de memoria
	inc RAX
	jmp .while

	.fin:
	pop RBP
	ret


