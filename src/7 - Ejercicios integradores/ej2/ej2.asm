extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16

TAMAÑO_MAPA_ANCHO EQU 255
TAMAÑO_MAPA_ALTO EQU 255

	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; RDI = mapa_t           mapa
	; RSI = attackunit_t*    compartida
	; RDX = uint32_t*        fun_hash(attackunit_t*)

global optimizar
optimizar:
	push rbp
	mov rbp, rsp
	push R12
	push R13 ; alineado
	push R14
	push R15 ; alineado
	push RBX
	sub rsp, 24 ;alineado
	;prologo

	mov r12, rdi ; mapa
	mov r13, rsi ; compartida
	mov r14, rdx ; fun_hash

	xor r15, r15 ; i
	xor rbx, rbx ; j


	.ciclo_alto:
		cmp r15, TAMAÑO_MAPA_ALTO
		jge .fin

		.ciclo_ancho:
			cmp rbx, TAMAÑO_MAPA_ANCHO
			jge .fin_fila

			; Accedo al elemento en la posicion mapa [i][j]
			; RECORDAR: r12 ya es el puntero a la base de la matriz
			; calculo el puntero a la posicion indicada y lo guardo en el stack para uso futuro
			xor rsi, rsi 
			imul rsi, r15, TAMAÑO_MAPA_ANCHO
			add rsi, rbx
			imul rsi, 8
			add rsi, r12

			mov [rsp + 24], rsi
			mov rdi, [rsi] 
			; ahora en rdi tengo *attackunit_t
			mov [rsp + 8], rdi ; me guardo el puntero al attack_unit
						

			; compruebo si el puntero es NULL
			mov rdx, rdi
			cmp rdx, 0
			je .fin_ancho

			; llamo a fun_hash(unidad_actual)
			call r14
			mov [rsp + 16], rax ; me guardo fun_hash(unidad_actual)

			; llamo a fun_hash(compartida)
			mov rdi, r13 
			call r14 

			; comparo fun_hash(compartida) == fun_hash(unidad_actual)
			cmp rax, [rsp + 16] 
			jne .fin_ancho

			
			; me traigo el puntero al attack unit actual
			mov rdi, [rsp + 8] 

			; unidad_actual->references--
			mov dl, BYTE [rdi + ATTACKUNIT_REFERENCES]
			dec dl
			mov [rdi + ATTACKUNIT_REFERENCES], dl

			; busco y reemplazo
			; retraigo el valor del puntero que me guarde, para intercambiarlo por el nuevo.
			; Nota: la posicion de memoria donde guarda es donde se aloja el puntero a mapa[i][j]
			mov rdx, [rsp + 24] 
			mov [rdx] , r13 

			; compartida->references++
			mov dl, BYTE [r13 + ATTACKUNIT_REFERENCES] 
			inc dl
			mov [r13 + ATTACKUNIT_REFERENCES], dl


			.fin_ancho:
			inc rbx
			jmp .ciclo_ancho


	.fin_fila:
	xor rbx, rbx ; reinicio j
	inc r15
	jmp .ciclo_alto
	
	.fin:
	add rsp, 24
	pop RBX
	pop R15
	pop R14 
	pop R13
	pop R12 
	pop rbp 
	ret

global contarCombustibleAsignado
contarCombustibleAsignado:
	push rbp
	mov rbp, rsp
	push R12
	push R13 ; alineado
	push R14
	push R15 ; alineado
	push RBX
	sub rsp, 24 ;alineado
	;prologo


	mov r12, rdi ; mapa
	mov r13, rsi ; fun_combustible

	xor r14, r14 ; res

	xor r15, r15 ; i
	xor rbx, rbx ; j

	.ciclo_alto:
		cmp r15, TAMAÑO_MAPA_ALTO
		jge .fin

		.ciclo_ancho:
			cmp rbx, TAMAÑO_MAPA_ANCHO
			jge .fin_fila

			; Accedo al elemento en la posicion mapa [i][j]
			; RECORDAR: r12 ya es el puntero a la base de la matriz
			; calculo el puntero a la posicion indicada y lo guardo en el stack para uso futuro
			xor rsi, rsi 
			imul rsi, r15, TAMAÑO_MAPA_ANCHO
			add rsi, rbx
			imul rsi, 8
			add rsi, r12

			mov [rsp + 8], rsi
			mov rdi, [rsi] 
			; ahora en rdi tengo *attackunit_t

			; compruebo si el puntero es NULL
			mov rdx, rdi
			cmp rdx, 0
			je .fin_ancho
			; accedo al combustible de la unidad actual y lo guardo en el stack

			; RECORDAR: La parte alta se borra si se guarda uno de 32 en 64. Pero no 16 o 8.
			add r14w, WORD [rdi + ATTACKUNIT_COMBUSTIBLE]

			; llamo a fun_combustible(unidad_actual->clase)
			mov rdi, [rsi + ATTACKUNIT_CLASE]
			call r13

			; le resto lo que devuelve la funcion 
			sub r14, rax

			.fin_ancho:
			inc rbx
			jmp .ciclo_ancho

	.fin_fila:
	xor rbx, rbx ; reinicio j
	inc r15
	jmp .ciclo_alto

	.fin:
	xor rax, rax
	mov eax, DWORD r14d
	add rsp, 24
	pop RBX
	pop R15
	pop R14 
	pop R13
	pop R12 
	pop rbp 
	ret



	; rdi = mapa_t           mapa
	; rsi = uint8_t          x
	; rdx = uint8_t          y
	; rcx = void*            fun_modificar(attackunit_t*)

global modificarUnidad
modificarUnidad:
	push rbp
	mov rbp, rsp
	push R12
	push R13 ; alineado
	push R14
	push R15 ; alineado
	sub rsp, 16
	; prologo
	

	mov r12, rdi ; mapa
	mov r13, rsi ; x
	mov r14, rdx ; y
	mov r15, rcx ; fun modificar

	
	; Accedo al elemento en la posicion mapa [x][y], y guardo el puntero que se almacena en dicha posicion
	; el calculo es: fila * CANT_COLUMNAS (OSEA EL ANCHO) + columna
	; lo que queda: x * TAMAÑO_MAPA_ANCHO + y
	xor rsi, rsi
	imul rsi, r13, TAMAÑO_MAPA_ANCHO  
	add rsi, r14                     
	imul rsi, 8                        
	add rsi, r12

	mov [rsp + 8], rsi
	mov rdi, [rsi] 


	; compruebo si el puntero es NULL
	mov rdx, rdi
	cmp rdx, 0
	je .fin

	mov dl, BYTE [rdi + ATTACKUNIT_REFERENCES] ; unidad_actual->references->references
	cmp dl, 1
	je .caso_unico

	; En caso de que tenga varias referencias
	mov rdi, ATTACKUNIT_SIZE
	call malloc 

	mov [rsp + 16], rax

	; va a ser mi i	
	xor rdx, rdx
	mov rdi, ATTACKUNIT_COMBUSTIBLE ; CAMBIAR SI SE CAMBIA EL ORDEN DE LOS CAMPOS
	.for:
		cmp rdx, rdi
		jge .end_for

		; copio el string
		mov rcx, [rsp + 8]
		mov rcx, [rcx]
		mov cl, BYTE [rcx + rdx]
		mov [rax + rdx], cl

		inc rdx
		jmp .for

	.end_for:
	xor rdx, rdx
	mov rdi, [rsp + 8]
	mov rdi, [rdi]

	mov dx, WORD [rdi + ATTACKUNIT_COMBUSTIBLE]
	mov [rax + ATTACKUNIT_COMBUSTIBLE], dx
	
	mov rcx, 1
	mov [rax + ATTACKUNIT_REFERENCES], rcx

	; unidad_actual->references --
	dec  BYTE [rdi + ATTACKUNIT_REFERENCES] 


	; fun_modificar(copia_instancia);
	mov rdi, rax
	call r15


	mov rax, [rsp + 16]
	mov rdx, [rsp + 8] 
	mov [rdx] , rax 
	jmp .fin

	.caso_unico:
		mov rdi, [rsp + 8]
		mov rdi, [rdi]

		call r15
		mov rdi, [rsp + 8]

	; epilogo
	.fin:
	add rsp, 16
	pop R15
	pop R14 
	pop R13
	pop R12 
	pop rbp 
	ret
