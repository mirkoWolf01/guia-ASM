extern strcmp
global invocar_habilidad

; Completar las definiciones o borrarlas (en este ejercicio NO serán revisadas por el ABI enforcer)
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

POINTER_SIZE EQU 8

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text

; void invocar_habilidad(void* carta, char* habilidad);
invocar_habilidad:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	sub rsp, 16

	mov r12, rdi ; carta
	mov r13, rsi ; habilidad
	
	mov r14, [r12 + FANTASTRUCO_DIR_OFFSET]

	; vacio las posiciones de memoria
	xor rax, rax
	mov [rsp + 8], rax ; i
	mov [rsp + 16], rax ; cant_entries
	
	mov di, WORD [r12 + FANTASTRUCO_ENTRIES_OFFSET]
	mov WORD [rsp + 16], di ; cant_entries
	.ciclo:
		mov rcx, [rsp + 8]
		mov r8, [rsp + 16]
		cmp rcx, r8
		jge .ability_not_found
		
	
		mov r8, [rsp + 8]
		imul r8, POINTER_SIZE
		mov r8, [r14 + r8]
		; accedo a carta->__dir[i]

		mov r15, r8

		lea rdi, [r15 + DIRENTRY_NAME_OFFSET]
		mov rsi, r13

		call strcmp

		cmp rax, 0
		jne .ciclo_fin

		; func(carta)
		mov rdi, r12
		mov rsi, [r15 + DIRENTRY_PTR_OFFSET]
		call rsi
		jmp .fin_invocar_habilidad
	

		.ciclo_fin:
		inc QWORD [rsp + 8]
		jmp .ciclo

	.ability_not_found:
	; aca chequeo si es null
	mov rdi, [r12 + FANTASTRUCO_ARCHETYPE_OFFSET]
	cmp rdi, 0
	je .fin_invocar_habilidad

		; en rdi ya esta el puntero al arquetipo
		mov rsi, r13
		call invocar_habilidad


	.fin_invocar_habilidad:
		add rsp, 16
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
		ret ;No te olvides el ret!
