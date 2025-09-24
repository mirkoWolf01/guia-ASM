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
ESTADISTICAS_SIZE EQU 7

CATEGORIA_SIZE EQU 4
CATERGORIA_CASO_CLT EQU  0x544C43
CATERGORIA_CASO_RBO EQU  0x4F4252
; ESTO ES LO QUE SE VE EN UN WORD CUANDO ESTAN GUARDADOS



global resolver_automaticamente

;void resolver_automaticamente(funcionCierraCasos* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo)
resolver_automaticamente:
    push rbp 
    mov rbp, rsp 
    push r12
    push r13
    push r14
    push r15 ; alineado
    sub rsp, 32
    ; prologo


    mov r12, rdi ; funcion
    mov r13, rsi ; arreglo_casos
    mov r14, rdx ; casos_a_revisar
    mov r15, rcx ; largo


    xor rdi, rdi
    mov [rsp + 8], rdi  ; i 
    mov [rsp + 16], rdi ; k

    .ciclo:
        cmp [rsp + 8], r15
        jge .fin

        ; me guardo el caso actual en memoria para proximo uso
        mov rdi, CASO_SIZE
        imul rdi, [rsp + 8]
        lea rdi, [r13 + rdi] ; *(caso_t*) arreglo_casos[i]
        mov [rsp + 24], rdi


        mov rsi, [rdi + CASO_USUARIO_OFFSET]
        mov esi, DWORD  [rsi + USUARIO_NIVEL_OFFSET]

        cmp esi, 0
        je .caso_revision

        cmp esi, 1
        je .caso_mayor_a_cero



        .caso_mayor_a_cero:
            ; en rdi ya tengo la posicion de memoria que aloja el caso_actual
            ; llamo a funcion
            call r12

            cmp ax, 1
            jne .caso_nivel_1_caso_funcion_da_0

            .caso_nivel_1_caso_funcion_da_1:
                mov rdi, [rsp + 24]
                mov si, WORD 1
                mov WORD [rdi + CASO_ESTADO_OFFSET], si

                jmp .fin_ciclo


            .caso_nivel_1_caso_funcion_da_0:
                ; comparo el string con CLT
                mov rdi, [rsp + 24]
                mov esi, DWORD [rdi + CASO_CATEGORIA_OFFSET]
                
                mov eax, DWORD CATERGORIA_CASO_CLT
                cmp esi, eax
                je .caso_es_categoria_valida

                ; comparo el string con RBO
                mov eax, DWORD CATERGORIA_CASO_RBO
                cmp esi, eax
                jne .caso_revision

                ; si no salta, es porque es
                .caso_es_categoria_valida:
                    mov rdi, [rsp + 24]
                    mov si, WORD 2
                    mov WORD [rdi + CASO_ESTADO_OFFSET], si

                    jmp .fin_ciclo

        .caso_revision:
            mov rdi, CASO_SIZE
            imul rdi, [rsp + 16]
            lea rdi, [r14 + rdi] ; *(caso_t*) arreglo_casos[k]

            ; copio el arreglo a arreglo_casos[k]
            mov rsi, [rsp + 24]
            mov [rdi], rsi

            inc QWORD [rsp + 16]


        .fin_ciclo:
        inc QWORD [rsp + 8]
        jmp .ciclo


    .fin:
    ; epilogo
    add rsp, 32
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
