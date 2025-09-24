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
ESTADISTICAS_RBO_OFFSET EQU 1
ESTADISTICAS_KSC_OFFSET EQU 2
ESTADISTICAS_KDT_OFFSET EQU 3
ESTADISTICAS_ESTADO0_OFFSET EQU 4
ESTADISTICAS_ESTADO1_OFFSET EQU 5
ESTADISTICAS_ESTADO2_OFFSET EQU 6
ESTADISTICAS_SIZE EQU 8

CATERGORIA_CASO_CLT EQU  0x544C43
CATERGORIA_CASO_RBO EQU  0x4F4252
CATERGORIA_CASO_KSC EQU  0x43534b
CATERGORIA_CASO_KDT EQU  0x54444b

global calcular_estadisticas
;void calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id)
calcular_estadisticas:
    push rbp 
    mov rbp, rsp 
    push r12
    push r13
    push r14
    push r15 ; alineado
    sub rsp, 16
    ; prologo


    mov r12, rdi ; arreglo_casos
    mov r13, rsi ; largo
    mov r14, rdx ; usuario_id


    ; llamo malloc y me guardo el puntero
    mov rdi, ESTADISTICAS_SIZE
    call malloc 
    mov r15, rax

    ; vacio
    xor rax, rax
    mov [r15], rax

    xor rdi, rdi
    mov [rsp + 8], rdi  ; i 

    .ciclo:
        ; si i =< largo, sigo
        cmp [rsp + 8], r13
        jge .fin

        ; me guardo el caso actual en memoria para proximo uso
        mov rdi, CASO_SIZE
        imul rdi, [rsp + 8]
        lea rdi, [r12 + rdi] 
        mov [rsp + 16], rdi
        ; rdi = *(caso_t*) arreglo_casos[i]

        mov rsi, [rdi + CASO_USUARIO_OFFSET]
        mov rsi, [rsi + USUARIO_ID_OFFSET]

        cmp r14, 0
        je .caso_valido

        cmp rsi, r14
        jne .fin_ciclo

        .caso_valido:
            
            mov esi, DWORD [rdi + CASO_CATEGORIA_OFFSET]
            xor rcx, rcx

            mov eax, DWORD CATERGORIA_CASO_CLT
            cmp esi, eax
            je .caso_categoria_CLT

            mov eax, DWORD CATERGORIA_CASO_RBO
            cmp esi, eax
            je .caso_categoria_RBO

            mov eax, DWORD CATERGORIA_CASO_KSC
            cmp esi, eax
            je .caso_categoria_KSC

            mov eax, DWORD CATERGORIA_CASO_KDT
            cmp esi, eax
            je .caso_categoria_KDT

            jmp .fin_ciclo
            
            .caso_categoria_CLT:
                mov cl, ESTADISTICAS_CLT_OFFSET
                jmp .seccion_aumento_estado

            .caso_categoria_RBO:
                mov cl, ESTADISTICAS_RBO_OFFSET
                jmp .seccion_aumento_estado

            .caso_categoria_KSC:
                mov cl, ESTADISTICAS_KSC_OFFSET
                jmp .seccion_aumento_estado

            .caso_categoria_KDT:
                mov cl, ESTADISTICAS_KDT_OFFSET
                jmp .seccion_aumento_estado

            .seccion_aumento_estado:
                inc BYTE [r15 + rcx]


            xor rcx, rcx
            mov si, WORD [rdi + CASO_ESTADO_OFFSET]

            cmp si, 0
            je .caso_estado_0

            cmp si, 1
            je .caso_estado_1

            cmp si, 2
            je .caso_estado_2

            jmp .fin_ciclo

            .caso_estado_0:
                mov cl, ESTADISTICAS_ESTADO0_OFFSET
                jmp .aumentar_estado_especifico

            .caso_estado_1:
                mov cl, ESTADISTICAS_ESTADO1_OFFSET
                jmp .aumentar_estado_especifico

            .caso_estado_2:
                mov cl, ESTADISTICAS_ESTADO2_OFFSET
                jmp .aumentar_estado_especifico

            .aumentar_estado_especifico:
                inc BYTE [r15 + rcx]

        .fin_ciclo:
        inc QWORD [rsp + 8]
        jmp .ciclo


    .fin:
    ; epilogo
    mov rax, r15
    add rsp, 16
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; make valgrind_abi