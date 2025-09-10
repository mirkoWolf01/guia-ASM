

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
NODO_OFFSET_NEXT EQU 0
NODO_OFFSET_CATEGORIA EQU 8
NODO_OFFSET_ARREGLO EQU 16
NODO_OFFSET_LONGITUD EQU 24
NODO_SIZE EQU 32

PACKED_NODO_OFFSET_NEXT EQU 0
PACKED_NODO_OFFSET_CATEGORIA EQU 8
PACKED_NODO_OFFSET_ARREGLO EQU 9
PACKED_NODO_OFFSET_LONGITUD EQU 17
PACKED_NODO_SIZE EQU 21

LISTA_OFFSET_HEAD EQU 0
LISTA_SIZE EQU 8

PACKED_LISTA_OFFSET_HEAD EQU 0
PACKED_LISTA_SIZE EQU 8

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[RDI]
cantidad_total_de_elementos:
	;prólogo
	push RBP
	mov RBP, RSP
	
	mov RDI, [RDI + LISTA_OFFSET_HEAD]

	XOR RAX, RAX ;usamos RAX como lugar donde voy sumando, lo dejo en 0.

	; RDI direccion al nodo actual
	; RSI tamaño de la lista
	; RDX tamaño del array del nodo actual
	; RAX resultado parcial
	.ciclo:
		mov RDX, [RDI + NODO_OFFSET_LONGITUD]; muevo el valor de longitud actual a RDX
		add RAX, RDX ; Sumo el la longitud actual con el res parcial

		mov RDI, [RDI + NODO_OFFSET_NEXT]

		cmp rdi, 0
		jne .ciclo

	;epílogo
	pop RBP
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[EDI]
cantidad_total_de_elementos_packed:
	;prólogo
	push RBP
	mov RBP, RSP
	
	mov RDI, [RDI + PACKED_LISTA_OFFSET_HEAD]

	XOR RAX, RAX ;usamos RAX como lugar donde voy sumando, lo dejo en 0.

	; RDI direccion al nodo actual
	; RSI tamaño de la lista
	; RDX tamaño del array del nodo actual
	; RAX resultado parcial
	.ciclo:
		mov RDX, [RDI + PACKED_NODO_OFFSET_LONGITUD]; muevo el valor de longitud actual a RDX
		add RAX, RDX ; Sumo el la longitud actual con el res parcial

		mov RDI, [RDI + PACKED_NODO_OFFSET_NEXT]

		cmp rdi, 0
		jne .ciclo

	;epílogo
	pop RBP
	ret

