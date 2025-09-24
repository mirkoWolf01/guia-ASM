extern malloc
extern sleep
extern wakeup
extern create_dir_entry

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
sleep_name: DB "sleep", 0
wakeup_name: DB "wakeup", 0

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - init_fantastruco_dir
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - summon_fantastruco
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

POINTER_SIZE EQU 8

; void init_fantastruco_dir(fantastruco_t* card);
global init_fantastruco_dir
init_fantastruco_dir:
	push rbp 
	mov rbp, rsp
	push r12
	push r13

	mov r12, rdi

	xor rsi, rsi
	mov si, 2
	mov WORD [r12 + FANTASTRUCO_ENTRIES_OFFSET], si

	mov rdi, DIRENTRY_SIZE
	imul rdi, 2
	call malloc 

	mov QWORD [r12 + FANTASTRUCO_DIR_OFFSET], rax

	mov rdi, sleep_name
	mov rsi, sleep
	
	call create_dir_entry

	mov rdi, [r12 + FANTASTRUCO_DIR_OFFSET]
	mov [rdi + POINTER_SIZE * 0], rax

	mov rdi, wakeup_name
	mov rsi, wakeup
	
	call create_dir_entry

	mov rdi, [r12 + FANTASTRUCO_DIR_OFFSET]
	mov [rdi + POINTER_SIZE * 1], rax

	pop r13
	pop r12
	pop rbp
	ret ;No te olvides el ret!

; fantastruco_t* summon_fantastruco();
global summon_fantastruco
summon_fantastruco:
	push rbp 
	mov rbp, rsp
	push r12
	push r13

	mov rdi, FANTASTRUCO_SIZE
	call malloc 
	
	mov r12, rax

	; pongo el arquetipo en NULL 
	xor rcx, rcx
	mov QWORD [r12 + FANTASTRUCO_ARCHETYPE_OFFSET], rcx
	; luego pongo face_up como true
	mov cl, 1
	mov BYTE [r12 + FANTASTRUCO_FACEUP_OFFSET], cl

	mov rdi, rax
	call init_fantastruco_dir

	mov rax, r12

	pop r13
	pop r12
	pop rbp
	ret ;No te olvides el ret!
