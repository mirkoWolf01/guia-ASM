; Definiciones comunes
TRUE  EQU 1
FALSE EQU 0

; Identificador del jugador rojo
JUGADOR_ROJO EQU 1
; Identificador del jugador azul
JUGADOR_AZUL EQU 2

; Ancho y alto del tablero de juego
tablero.ANCHO EQU 10
tablero.ALTO  EQU 5

; Marca un OFFSET o SIZE como no completado
; Esto no lo chequea el ABI enforcer, sirve para saber a simple vista qué cosas
; quedaron sin completar :)
NO_COMPLETADO EQU -1

extern strcmp

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
carta.en_juego EQU 0
carta.nombre   EQU 1
carta.vida     EQU 14
carta.jugador  EQU 16
carta.SIZE     EQU 18

tablero.mano_jugador_rojo EQU 0
tablero.mano_jugador_azul EQU 8
tablero.campo             EQU 16
tablero.SIZE              EQU 416
; tablero.ANCHO * tablero.ALTO * tamaño de puntero + lo que tenia antes
; osea tamaño del array
; sizeof(array) = (número de elementos) × (sizeof(tipo de cada elemento))

accion.invocar   EQU 0
accion.destino   EQU 8
accion.siguiente EQU 16
accion.SIZE      EQU 24

POINTER_SIZE EQU 8
; Variables globales de sólo lectura
section .rodata

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - hay_accion_que_toque
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - invocar_acciones
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE

; Marca el ejercicio 3 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contar_cartas
global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE

section .text

; Dada una secuencia de acciones determinar si hay alguna cuya carta tenga un
; nombre idéntico (mismos contenidos, no mismo puntero) al pasado por
; parámetro.
;
; El resultado es un valor booleano, la representación de los booleanos de C es
; la siguiente:
;   - El valor `0` es `false`
;   - Cualquier otro valor es `true`
;
; ```c
; bool hay_accion_que_toque(accion_t* accion, char* nombre);
; ```
global hay_accion_que_toque
hay_accion_que_toque:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	mov r12, rdi ; accion
	mov r13, rsi ; nombre
	
	.while_hay_accion_que_toque:
		cmp r12, 0
		je .no_hay_accion_que_toque

		mov rdi, [r12 + accion.destino]
		lea rdi, [rdi + carta.nombre]
		mov rsi, r13

		call strcmp

		cmp rax, 0
		je .si_hay_accion_que_toque


		mov r12, [r12 + accion.siguiente]
		jmp .while_hay_accion_que_toque

	
	
	.no_hay_accion_que_toque:
	xor rax, rax
	jmp .fin_hay_accion_que_toque

	.si_hay_accion_que_toque:
	mov rax, 1

	.fin_hay_accion_que_toque:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

; Invoca las acciones que fueron encoladas en la secuencia proporcionada en el
; primer parámetro.
;
; A la hora de procesar una acción esta sólo se invoca si la carta destino
; sigue en juego.
;
; Luego de invocar una acción, si la carta destino tiene cero puntos de vida,
; se debe marcar ésta como fuera de juego.
;
; Las funciones que implementan acciones de juego tienen la siguiente firma:
; ```c
; void mi_accion(tablero_t* tablero, carta_t* carta);
; ```
; - El tablero a utilizar es el pasado como parámetro
; - La carta a utilizar es la carta destino de la acción (`accion->destino`)
;
; Las acciones se deben invocar en el orden natural de la secuencia (primero la
; primera acción, segundo la segunda acción, etc). Las acciones asumen este
; orden de ejecución.
;
; ```c
; void invocar_acciones(accion_t* accion, tablero_t* tablero);
; ```
global invocar_acciones
invocar_acciones:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	mov r12, rdi ; accion
	mov r13, rsi ; tablero
	
	.while_invocar_acciones:
		cmp r12, 0
		je .fin_invocar_acciones

		mov rdi, [r12 + accion.destino]
		mov r14, rdi
		; en rdi tengo carta_destino
		mov dl, BYTE [r14 + carta.en_juego]

		cmp dl, 0
		je .fin_while_invocar_acciones

		mov rdx, QWORD [r12 + accion.invocar]

		mov rdi, r13
		mov rsi, r14

		call rdx

		mov dl, BYTE [r14 + carta.en_juego]
		cmp dl, 0
		je .fin_while_invocar_acciones

		mov dx, WORD [r14 + carta.vida]
		cmp dx, 0
		jg .fin_while_invocar_acciones

		xor rax, rax
		mov rax, 0
		mov BYTE [r14 + carta.en_juego], al

		.fin_while_invocar_acciones:
		mov r12, [r12 + accion.siguiente]
		jmp .while_invocar_acciones


	.fin_invocar_acciones:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret


; Cuenta la cantidad de cartas rojas y azules en el tablero.
;
; Dado un tablero revisa el campo de juego y cuenta la cantidad de cartas
; correspondientes al jugador rojo y al jugador azul. Este conteo incluye tanto
; a las cartas en juego cómo a las fuera de juego (siempre que estén visibles
; en el campo).
;
; Se debe considerar el caso de que el campo contenga cartas que no pertenecen
; a ninguno de los dos jugadores.
;
; Las posiciones libres del campo tienen punteros nulos en lugar de apuntar a
; una carta.
;
; El resultado debe ser escrito en las posiciones de memoria proporcionadas
; como parámetro.
;
; ```c
; void contar_cartas(tablero_t* tablero, uint32_t* cant_rojas, uint32_t* cant_azules);
; ```
global contar_cartas
contar_cartas:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	sub rsp, 32

	mov r12, rdi ; tablero
	mov r13, rsi ; cant_rojas
	mov r14, rdx ; cant_azules

	xor rax, rax
	mov [rsp + 8], rax ; i
	mov [rsp + 16], rax ; j
	
	; los inicializo en 0
	mov [r13], dword eax
	mov [r14], dword eax

	.for_contar_cartas_i:
		mov rax, [rsp + 8]
		cmp rax, tablero.ALTO
		jge .fin_contar_cartas

		mov QWORD [rsp + 16], 0
		
		.for_contar_cartas_j:
			mov rax, [rsp + 16]
			cmp rax, tablero.ANCHO
			jge .end_for_contar_cartas_i

			mov rdi, [rsp + 8]
			imul rdi, tablero.ANCHO
			add rdi, [rsp + 16]
			imul rdi, POINTER_SIZE
			; en rdi tengo mi offset
			
			lea rdx, [r12 + tablero.campo + rdi]
			mov rdx, [rdx]
			; ahora en rdx tengo el puntero a mi carta

			cmp rdx, 0
			je .end_for_contar_cartas_j

			
			mov cl, BYTE [rdx + carta.en_juego]
			cmp cl, 0
			je .end_for_contar_cartas_j

			mov cl, BYTE [rdx + carta.jugador]
			
			cmp cl, JUGADOR_AZUL
			je .caso_jugador_azul
			
			cmp cl, JUGADOR_ROJO
			je .caso_jugador_rojo
			
			jmp .end_for_contar_cartas_j

			.caso_jugador_azul:
				inc DWORD [r14]
				jmp .end_for_contar_cartas_j

			.caso_jugador_rojo:
				inc DWORD [r13]

		.end_for_contar_cartas_j:
		inc QWORD [rsp + 16]
		jmp .for_contar_cartas_j

	.end_for_contar_cartas_i:
	inc QWORD [rsp + 8]
	jmp .for_contar_cartas_i


	.fin_contar_cartas:
	add rsp, 32
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
