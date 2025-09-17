extern malloc

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8

CASO_CATEGORIA_OFFSET EQU 0
CASO_ESTADO_OFFSET EQU 4
CASO_USUARIO_OFFSET EQU 8
CASO_SIZE EQU 16

SEGMENTACION_CASOS0_OFFSET EQU 0
SEGMENTACION_CASOS1_OFFSET EQU 8
SEGMENTACION_CASOS2_OFFSET EQU 16
SEGMENTACION_SIZE EQU 24

ESTADISTICAS_CLT_OFFSET EQU 0
ESTADISTICAS_RBO_OFFSET EQU 0
ESTADISTICAS_KSC_OFFSET EQU 0
ESTADISTICAS_KDT_OFFSET EQU 0
ESTADISTICAS_ESTADO0_OFFSET EQU 0
ESTADISTICAS_ESTADO1_OFFSET EQU 0
ESTADISTICAS_ESTADO2_OFFSET EQU 0
ESTADISTICAS_SIZE EQU 0

    
; rdi, arreglo_casos
; rsi, largo
; edx, nivel

; int contar_casos_por_nivel(caso_t *arreglo_casos, int largo, int nivel)
global contar_casos_por_nivel
contar_casos_por_nivel:
    push rbp
    mov rbp, rsp
    ; prologo

    xor rax, rax    ; res
    xor r8, r8      ; i

    .ciclo: 
        cmp r8, rsi
        jge .fin

        ; r9 = arreglo_casos[i].usuario
        xor r10, r10
        imul r10, r8 , CASO_SIZE
        lea r9, [rdi + r10]
        mov r9, [r9 + CASO_USUARIO_OFFSET]
        
        ; r9 = arreglo_casos[i].usuario-> nivel
        mov r9d, DWORD [r9 + USUARIO_NIVEL_OFFSET]

        cmp r9d, edx
        jne .epilogo_del_ciclo

        ; res++
        inc rax

        .epilogo_del_ciclo:
        inc r8
        jmp .ciclo

    .fin:
    ;epilogo
    pop rbp
    ret


;segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo)
global segmentar_casos
segmentar_casos:
    push rbp
    mov rbp, rsp
    push r12
    push r13 ; alineado
    push r15 
    sub rsp, 40 ; alineado
    ;prologo


    mov r12, rdi ; *arreglo_casos
    mov r13, rsi ; largo

    
    mov rdi, SEGMENTACION_SIZE
    call malloc

    ; muevo el puntero a r15, donde voy a guardar mi res
    mov r15, rax

    ; Inicializo los punteros como NULL
    xor rax, rax
    mov [r15 + SEGMENTACION_CASOS0_OFFSET],  rax
    mov [r15 + SEGMENTACION_CASOS1_OFFSET],  rax
    mov [r15 + SEGMENTACION_CASOS2_OFFSET],  rax


    ; contar_casos_por_nivel(arreglo_casos, largo, 0)
        mov rdi, r12
        mov rsi, r13
        mov rdx, 0
        call contar_casos_por_nivel
        mov [rsp + 8], rax


    ; contar_casos_por_nivel(arreglo_casos, largo, 1)
        mov rdi, r12
        mov rsi, r13
        mov rdx, 1
        call contar_casos_por_nivel
        mov [rsp + 16], rax

    ; contar_casos_por_nivel(arreglo_casos, largo, 2)
        mov rdi, r12
        mov rsi, r13
        mov rdx, 2
        call contar_casos_por_nivel
        mov [rsp + 24], rax

    
    ; if (cant_nivel0 != 0)
    cmp WORD [rsp + 8], 0
    je .cero_elementos_en_nivel_0

    mov rdi, [rsp + 8]
    imul rdi, CASO_SIZE
    call malloc
    mov [r15 + SEGMENTACION_CASOS0_OFFSET],  rax

    .cero_elementos_en_nivel_0:

    ; if (cant_nivel1 != 0)
    cmp WORD [rsp + 16], 0
    je .cero_elementos_en_nivel_1

    ; res->casos_nivel_1 = malloc(cant_nivel1 * sizeof(caso_t))
    mov rdi, [rsp + 16]
    imul rdi, CASO_SIZE
    call malloc
    mov [r15 + SEGMENTACION_CASOS1_OFFSET],  rax

    .cero_elementos_en_nivel_1:

    ; if (cant_nivel2 != 0)
    cmp WORD [rsp + 24], 0
    je .cero_elementos_en_nivel_2

    ; res->casos_nivel_2 = malloc(cant_nivel2 * sizeof(caso_t))
    mov rdi, [rsp + 24]
    imul rdi, CASO_SIZE
    call malloc
    mov [r15 + SEGMENTACION_CASOS2_OFFSET],  rax

    .cero_elementos_en_nivel_2:


    xor rdi, rdi ; n
    xor rsi, rsi ; m
    xor rdx, rdx ; k
    xor rcx, rcx ; i

    .ciclo_segmentar_casos:
        cmp rcx, r13
        jge .fin_segmentar_casos

        xor r8, r8
        imul r8, rcx, CASO_SIZE
        lea r9, [r12 + r8]
        ; ahora en r9 tengo el puntero al caso[i]
        
        mov r11, [r9 + CASO_USUARIO_OFFSET]
        ; ahora en r9 tengo un puntero al usuario
        
        mov r11d, DWORD[r11 + USUARIO_NIVEL_OFFSET]


        cmp DWORD r11d, 1
        je .caso_nivel_1
        cmp DWORD r11d, 2
        je .caso_nivel_2

        ; sino caso_0
            mov r10, [r15 + SEGMENTACION_CASOS0_OFFSET]
            ; r10 = puntero que me dio el malloc
            xor r8, r8
            imul r8, rdx , CASO_SIZE
            lea r10, [r10 + r8]
            ; r10 = segmentacion-> caso nivel_0[k]

            inc rdx
            jmp .fin_ciclo_segmentar_casos
        .caso_nivel_1:
           mov r10, [r15 + SEGMENTACION_CASOS1_OFFSET]
            ; r10 = puntero que me dio el malloc
            xor r8, r8
            imul r8, rsi , CASO_SIZE
            lea r10, [r10 + r8]
            ; r10 = segmentacion-> caso nivel_0[k]

            inc rsi
            jmp .fin_ciclo_segmentar_casos
        .caso_nivel_2:
           mov r10, [r15 + SEGMENTACION_CASOS2_OFFSET]
            ; r10 = puntero que me dio el malloc
            xor r8, r8
            imul r8, rdi , CASO_SIZE
            lea r10, [r10 + r8]
            ; r10 = segmentacion-> caso nivel_0[k]

            inc rdi
        .fin_ciclo_segmentar_casos:
        ; seteo los nuevos valores con respecto a lo que se guardo en r10
        ; r10 es el la posicion donde debe guardarse el caso actual
            ; comienzo copiando el char[3]
            mov r8b, BYTE [r9]
            mov [r10 + CASO_CATEGORIA_OFFSET], r8b
            mov r8b, BYTE [r9 +1]
            mov [r10 + CASO_CATEGORIA_OFFSET + 1], r8b
            mov r8b, BYTE [r9 +2]
            mov [r10 + CASO_CATEGORIA_OFFSET + 2], r8b

            ; ahora copio el uint16
            mov r8w, WORD [r9 + CASO_ESTADO_OFFSET]
            mov WORD [r10 + CASO_ESTADO_OFFSET], r8w

            ; ahora copio el uint
            mov r8, [r9 + CASO_USUARIO_OFFSET]
            mov [r10 + CASO_USUARIO_OFFSET], r8
        inc rcx
        jmp .ciclo_segmentar_casos

   .fin_segmentar_casos:
    ;epilogo
    mov rax, r15
    add rsp, 40
    pop r15
    pop r13
    pop r12
    pop rbp
    ret

; valgrind --leak-check=full ./test_asm