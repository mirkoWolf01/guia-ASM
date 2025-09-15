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
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0
ITEM_FUERZA EQU 20
ITEM_DURABILIDAD EQU 24
ITEM_SIZE EQU 28

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.


	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = item_t**     inventario
	; r/m64 = uint16_t*    indice
	; r/m16 = uint16_t     tamanio
	; r/m64 = comparador_t comparador

global es_indice_ordenado
es_indice_ordenado:
	push rbp
	mov rbp, rsp
	push R12
	push R13
	push R14
	push R15 
	sub rsp, 16; alineado a 16b
	;prologo
	

	mov R12, RDI ; inventario
	mov R13, RSI ; indice
	movzx R14, DX ; tamaño
	mov R15, RCX ; comparador

	XOR RDI, RDI
	mov DI, WORD [R13] ; guardo en RDI -> indice[0]
	imul RDI, 8 ; multiplico el valor del indice por el tamaño de un puntero (8 bytes)
	mov RDI, [R12 + RDI] ; calculo el puntero al elemento indice[0]

	mov RCX, 1
	mov [rbp - 40], RCX ; indice dentro del ciclo
	add R13, 2
	.ciclo: 
		cmp [rbp - 40], R14W
		mov rax, TRUE
		jnl .epilogo
		
		xor RDX, RDX
		mov DX, WORD [R13]
		imul RDX, 8
		mov RSI, [R12 + RDX] ; accedo al elemento [0] del indice 

		mov [rbp - 48], RSI ; guardo el elemento anterior

		call R15 ; llamo al comparador
		cmp rax, 0
		je .caso_desordenado
		
		mov RDI, [rbp - 48] ; actualizo el item anterior

		mov RCX, [rbp - 40] ; i++
		inc RCX ; aumento el iterador local
		mov [rbp - 40], RCX

		add R13, 2 ; voy a la siguiente posicion del indice
		jmp .ciclo

	.caso_desordenado:
	mov rax, FALSE

	.epilogo:
	add rsp, 16
	pop R15
	pop R14 
	pop R13
	pop R12 
	pop rbp 
	ret

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**



	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = item_t**  inventario
	; r/m64 = uint16_t* indice
	; r/m16 = uint16_t  tamanio

global indice_a_inventario
indice_a_inventario:
	push rbp
	mov rbp, rsp
	push R12
	push R13
	push R14
	sub RSP, 8 ; queda alineado a 16
	; prologo

	mov R12, RDI  ; inventario
	mov R13, RSI  ; indice
	movzx R14, DX ; tamaño


	imul RDI, R14, 8

	call malloc


	mov RCX, 0
	.ciclo: 
		cmp RCX, R14
		jnl .epilogo

		XOR RDX, RDX
		mov DX, WORD [R13] ; guardo en RDI -> indice[i]
		imul RDX, 8 ; multiplico el valor del indice por el tamaño de un puntero (8 bytes)
		mov RDI, [R12 + RDX] ; calculo el puntero al elemento indice[i]


		imul RDX, RCX, 8 ; defino el indice donde escribo
		mov [RAX + RDX], RDI ; guardo en la direccion [puntero + offset] el puntero al struct

		add R13, 2 ; voy a la siguiente posicion del indice
		inc RCX
		jmp .ciclo


	.epilogo:
	add rsp, 8
	pop R14
	pop R13 
	pop R12
	pop rbp
	ret
