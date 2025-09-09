extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_using_c
global alternate_sum_4_using_c_alternative
global alternate_sum_8
global product_2_f
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4:
  sub EDI, ESI
  add EDI, EDX
  sub EDI, ECX

  mov EAX, EDI
  ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4_using_c:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  push R12
  push R13	; preservo no volatiles, al ser 2 la pila queda alineada

  mov R12D, EDX ; guardo los parámetros x3 y x4 ya que están en registros volátiles
  mov R13D, ECX ; y tienen que sobrevivir al llamado a función

  call restar_c 
  ;recibe los parámetros por EDI y ESI, de acuerdo a la convención, y resulta que ya tenemos los valores en esos registros
  
  mov EDI, EAX ;tomamos el resultado del llamado anterior y lo pasamos como primer parámetro
  mov ESI, R12D
  call sumar_c

  mov EDI, EAX
  mov ESI, R13D
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  pop R13 ;restauramos los registros no volátiles
  pop R12
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


alternate_sum_4_using_c_alternative:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 16 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada

  mov [RBP-8], RCX ; guardo x4 en la pila

  push RDX  ;preservo x3 en la pila, desalineandola
  sub RSP, 8 ;alineo
  call restar_c 
  add RSP, 8 ;restauro tope
  pop RDX ;recupero x3
  
  mov EDI, EAX
  mov ESI, EDX
  call sumar_c

  mov EDI, EAX
  mov ESI, [RBP - 8] ;leo x4 de la pila
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  add RSP, 16 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[EDI], x2[ESI], x3[EDX], x4[ECX], x5[R8], x6[R9], x7[RBP + 16], x8[RBP + 24]
alternate_sum_8:
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 32 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada
  ;fin del prologo


  ; Guardo los valores que estaban en registros no volatiles en
  mov [RBP-8], R9 ; x6
  mov [RBP-16], R8 ; x5
  mov [RBP-24], RCX ; x4
  mov [RBP-32], RDX ; x3

  call restar_c ; resta x2 a x1

  mov EDI, EAX
  mov ESI, [RBP - 32]
  
  call sumar_c ; sumo res + x3
	
  mov EDI, EAX
  mov ESI, [RBP - 24]

  call restar_c ; resta x4 a res

  mov EDI, EAX
  mov ESI, [RBP - 16]

  call sumar_c ; sumo res + x5

  mov EDI, EAX
  mov ESI, [RBP - 8]

  call restar_c ; resta x6 a res

  mov EDI, EAX
  mov ESI, [RBP + 16] ; por que 24 no

  call sumar_c ; sumo res + x7

  mov EDI, EAX
  mov ESI, [RBP + 24]

  call restar_c ; resta x8 a res


  add RSP, 32 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[RDI], x1[ESI], f1[XMM0]
product_2_f:
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado

  cvtsi2ss xmm1, ESI        ; convierte a → float en xmm1

  mulss xmm0, xmm1          ; xmm0 = xmm0 * xmm1  (b * a)

  cvttss2si eax, xmm0       ; convertir a entero con truncamiento

  mov [rdi], eax            ; *destination = resultado

  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
	ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[ESI], f1[XMM0], x2[EDX], f2[XMM1], x3[ECX], f3[XMM2], x4[R8], f4[XMM3]
;	, x5[R9], f5[XMM4], x6[BSP + 16], f6[XMM5], x7[BSP + 24], f7[XMM6], x8[BSP + 32], f8[XMM7],
;	, x9[BSP + 40], f9[BSP + 48]
product_9_f:
	;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  ;fin del prologo

	;convertimos los flotantes de cada registro xmm en doubles
  cvtss2sd xmm0, xmm0
  cvtss2sd xmm1, xmm1
  cvtss2sd xmm2, xmm2
  cvtss2sd xmm3, xmm3
  cvtss2sd xmm4, xmm4
  cvtss2sd xmm5, xmm5
  cvtss2sd xmm6, xmm6
  cvtss2sd xmm7, xmm7
  cvtss2sd xmm8, [RBP + 48]

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	mulsd xmm0, xmm1
  mulsd xmm0, xmm2
  mulsd xmm0, xmm3
  mulsd xmm0, xmm4
  mulsd xmm0, xmm5 
  mulsd xmm0, xmm6
  mulsd xmm0, xmm7 
  mulsd xmm0, xmm8

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	cvtsi2sd xmm1, esi
  cvtsi2sd xmm2, edx 
  cvtsi2sd xmm3, ecx 
  cvtsi2sd xmm4, r8 
  cvtsi2sd xmm5, r9
  cvtsi2sd xmm6, [RBP + 16]
  cvtsi2sd xmm7, [RBP + 24]
  cvtsi2sd xmm8, [RBP + 32]
  cvtsi2sd xmm9, [RBP + 40]

	
	mulsd xmm0, xmm1
  mulsd xmm0, xmm2
  mulsd xmm0, xmm3
  mulsd xmm0, xmm4
  mulsd xmm0, xmm5 
  mulsd xmm0, xmm6
  mulsd xmm0, xmm7 
  mulsd xmm0, xmm8
  mulsd xmm0, xmm9


  movsd [rdi], xmm0            ; *destination = resultado

	; epilogo
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
	ret

