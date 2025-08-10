# Ejercicios integradores

Estos ejercicios presentan una estructura y dificultad similar a lo que será evaluado en el primer parcial. Recomendamos hacerlos una vez que hayan visto todos los temas anteriores de la guía.

Para todos los ejercicios recomendamos primero implementarlos en C, y una vez que pasen los tests escribir esos algoritmos en ASM.

Hay un esqueleto para cada ejercicio con los tests correspondientes y una plantilla para completar implementaciones en C/ASM de cada inciso.

## Compilación y Testeo

Para compilar y ejecutar los tests cada ejercicio dispone de un archivo
`Makefile` con los siguientes *targets*:

| Comando             | Descripción                                                         |
| ------------------- | ------------------------------------------------------------------- |
| `make test_c`       | Genera el ejecutable usando la implementación en C del ejercicio.   |
| `make test_asm`     | Genera el ejecutable usando la implementación en ASM del ejercicio. |
| `make test_abi`     | Genera usando la implementación en ASM del ejercicio + archivos necesarios para ABI enforcer |
| `make run_c`        | Corre los tests usando la implementación en C.                      |
| `make run_asm`      | Corre los tests usando la implementación en ASM.                    |
| `make run_abi`      | Corre los tests usando la implementación en ASM + ABI enforcer.     |
| `make valgrind_c`   | Corre los tests en valgrind usando la implementación en C.          |
| `make valgrind_asm` | Corre los tests en valgrind usando la implementación en ASM.        |
| `make valgrind_abi` | Corre los tests en valgrind usando la implementación en ASM + ABI enforcer        |
| `make clean`        | Borra todo archivo generado por el `Makefile`.                      |

El sistema de tests **sólo correrá los tests que hayan marcado
como hechos**. Para esto deben modificar la variable `EJERCICIO_xx_HECHO`
correspondiente asignándole `true` (en C) ó `TRUE` (en ASM). `xx` es el inciso
en cuestión: `nA` o `nB`.

**Para que la resolución de un ejercicio se considere como correcta, tiene que funcionar el ABI enforcer**. Sin embargo, el ABI enforcer no garantiza la ausencia de errores. Pueden haber fallas como, por ejemplo, la posibilidad de tener overflows/underflows en entradas grandes que no son detectadas por el ABI enforcer.

# Ejercicio 1

Como parte del espectacular juego AAA llamado "AyOC 2 - La venganza de los
punteros" estamos diseñando su sistema de inventario. Los jugadores pueden tener
grandes cantidades de ítems en sus inventarios y quieren poder reordenarlos con
total fluidez. Debido a estos requisitos de performance se solicita implementar
en ensamblador algunas funciones del sistema de manipulación de inventarios.

La estructura utilizada para representar ítems es la siguiente:
```c
typedef struct {
    char nombre[18];
    uint32_t fuerza;
    uint16_t durabilidad;
} item_t;
```

El inventario se implementa como un array de punteros a ítems. Nuevos ítems
siempre se agregan al final. La siguiente imagen ejemplifica el inventario:

![Ejemplo de inventario](img/inventario.png)

Uno de los requisitos más importantes es el de poder ver los ítems _más
fuertes_/_con menos daño_/_más baratos_/etc en simultáneo. Para lograr esto el
juego mantiene una serie de índices que indican la permutación necesaria para
mostrar el inventario según cada criterio.

Supongamos entonces que queremos mostrar la vista de ítems según daño:
```c
items_danio[i] = inventario[indices_danio[i]];
```

Si en su lugar quisiéramos verlos ordenados por durabilidad:
```c
items_durabilidad[i] = inventario[indices_durabilidad[i]];
```

Estos índices nos permiten mantener múltiples nociones de orden en simultáneo sin tener que mantener múltiples copias de los inventarios (alcanza con mantener los índices).

Hay muchísimos criterios de orden posibles por lo que además definimos un tipo
de dato para poder hablar de ellos:
```c
typedef bool (*comparador_t)(item_t*, item_t*);
``` 

## 1A - Detectar índices ordenados

Las vistas del inventario son editables y nos gustaría poder detectar cuando una
vista es equivalente a ordenar el inventario según una función de comparación.
Esto permitiría ahorrar memoria representando esas vistas como "el resultado de
ordenar la lista usando X" en lugar de tener que escribir todo el índice.

Para realizar esto se solicita implementar en ensamblador una función que
verifique si una vista del inventario está correctamente ordenada de acuerdo a
un criterio. La firma de la función a implementar es la siguiente:
```c
bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);
```

Dónde:
- `inventario`: Un array de punteros a ítems que representa el inventario a
  procesar.
- `indice`: El arreglo de índices en el inventario que representa la vista.
- `tamanio`: El tamaño del inventario (y de la vista).
- `comparador`: La función de comparación que a utilizar para verificar el
  orden.

Tenga en consideración:
- `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
  como parámetro podría tener basura.
- `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
  `call`) para comenzar la ejecución de la subrutina en cuestión.
- Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
- `false` es el valor `0` y `true` es todo valor distinto de `0`.
- Importa que los ítems estén ordenados según el comparador. No hay necesidad
  de verificar que el orden sea estable.

## 1B - Materializar índices

Cuando una vista es muy importante para un jugador se puede escoger reordenar el
inventario en base a esta. Nuestros índices son básicamente una forma de
representar permutaciones del inventario. Se solicita implementar una función
que dado un inventario y una vista cree un nuevo inventario que mantenga el
orden descrito por la misma.

Es decir:
```math
\forall i \in [0; \text{tamanio})\quad  \text{resultado}[i] = \text{inventario}[\text{vista}[i]]
```

La memoria a solicitar para el nuevo inventario debe poder ser liberada
utilizando `free(ptr)`.

La función debe tener la siguiente firma:
```c
item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);
``` 

Donde:
- `inventario` un array de punteros a ítems que representa el inventario a
  procesar.
- `indice` es el arreglo de índices en el inventario que representa la vista
  que vamos a usar para reorganizar el inventario.
- `tamanio` es el tamaño del inventario.

Tenga en consideración:
- Tanto los elementos de `inventario` como los del resultado son punteros a
  `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
  ítems**


# Ejercicio 2

Luego del éxito de nuestro último juego "AyOC - la venganza de los punteros" hemos decidido incursionar al mundo de los juegos de estrategia por turnos para nuestro próximo juego, "Organized Wars".

En su turno, el jugador podrá colocar en un mapa de juego cuadriculado varias unidades de ataque de distintas clases. Cada clase tiene un valor inicial de combustible cargado, el cuál utilizarán en una etapa posterior para realizar acciones como moverse, disparar bombas, etc. Además del combustible precargado, el jugador cuenta con una reserva extra de combustible que puede repartir entre las unidades que desee, potenciando ciertas unidades puntuales.

Dado que es común que los jugadores reposicionen y modifiquen los niveles de combustible de las unidades constantemente durante su turno, el sistema de nuestro juego funciona del siguiente modo:

- Durante el transcurso del turno, cada unidad de ataque agregada se instancia independientemente. 
- Al momento de finalizar el turno, se revisa que el jugador no haya asignado más combustible extra del que tenía disponible en su reserva. De haber asignado combustible correctamente, se efectiviza el final del turno.
- Una vez finalizado el turno, se corre una optimización que reemplaza todas las instancias independientes de unidades equivalentes por una única instancia "compartida"" (donde dos unidades son equivalentes si el resultado de aplicar una función de hash dada sobre cada una es el mismo).

![alt text](img/optimizacion.jpg)

**a)** Programar en lenguaje assembler una función que, dado el puntero a un personaje, "optimice" todas las unidades del mapa que sean
equivalentes utilizando en su lugar la versión pasada por parámetro. La solución debe hacer un uso apropiado
de la memoria, teniendo en cuenta que las referencias a unidades solo son guardadas en el mapa.

`void optimizar(mapa_t mapa, personaje_t* compartida, uint32_t *fun_hash)`

**b)** Programar en lenguaje assembler una función

`uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char*))`

que se utilizará para calcular, antes de finalizar el turno del jugador, la cantidad de combustible **de la reserva** que fue asignado por el jugador. La funcion fun_combustible pasada por parametro, toma una clase de unidad y devuelve la cantidad de combustible base que le corresponde.

---

Luego de la optimización cominenza la fase de batalla, en la que las unidades realizarán acciones y sus niveles de combustible se modificarán de manera acorde. Si se modifica una unidad que está compartiendo instancia por una optimización, se debe crear una nueva instancia individual para esta en lugar de modificar la instancia compartida (lo cual resultaría en modificaciones indebidas en otras unidades).

**c)** Programar en lenguaje assembler una función
    
`void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void *fun_modificar)`

que dada una posición en el mapa permita aplicar la función modificadora a la unidad en esa posición **únicamente**. 
La solución propuesta debe tener en cuenta el caso en que se quiera modificar una unidad que previamente había sido optimizada, sin hacer uso excesivo o innecesario de recursos del sistema.

De no haber una unidad en la posición especificada, no se debe hacer nada.

---
**Observaciones:**

- La instancia compartida podría ser una **nueva instancia** o **alguna de las instancias individuales preexistentes**.
- En los tests se utiliza un area del mapa de 5x5 lugares para simplificar la visualización, pero es importante que se resuelva correctamente para el mapa completo.
- Para cada función se incluye un último test que sí trabaja sobre un mapa de tamaño máximo. Este test no correrá hasta que los anteriores pasen exitosamente.
- A fin de debuggear puede ser útil revisar la función de hash utilizada en los tests, la cual está definida al principio de `test.c`.

# Ejercicio 3

Un prestigioso banco de los Estados Unidos, el **Orga2-Morgan**, nos solicitó ayuda para procesar sus colas de atención al cliente. Poder priorizar los casos es de suma importancia para el banco, ya que si los usuarios dejan buenas reseñas, les resulta más fácil atraer nuevos clientes.

El equipo de IT del banco nos brinda las siguientes estructuras:

## Estructura: Caso

```
typedef struct {
	char[3] categoria;
	uint16_t estado;
	usuario_t* usuario;
} caso_t;
```

Esta estructura representa un caso. Contiene:

- `categoria`: puede ser `"CLT"`, `"RBO"`, `"KSC"` o `"KDT"`.
- `estado`: puede tomar los valores:
  - `0`: caso abierto
  - `1`: cerrado favorablemente
  - `2`: cerrado desfavorablemente
- `usuario`: puntero a un usuario asociado al caso.

## Estructura: Usuario

```
typedef struct {
	uint32_t id;
	uint32_t nivel;
} usuario_t;
```

Donde:

- `id`: identificador único del usuario.
- `nivel`: puede ser `0`, `1` o `2`, representando el nivel de prioridad del cliente.

---

## Ejercicio 3a

La primer funcionalidad que nos solicitaron es poder segmentar los casos según el nivel del usuario, para así poder priorizar la atención en función de la importancia de cada cliente para la compañía.

La firma de la función a implementar es:

```
segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo)
```

Donde:

```
typedef struct {
	caso_t* casos_nivel_0;
	caso_t* casos_nivel_1;
	caso_t* casos_nivel_2;
} segmentacion_t;
```
Que dada una lista de casos, los ordene de acuerdo al nivel de prioridad del usuario que lo abrió. El parametro `largo` indica la longitud del arreglo pasado por parametro. La estructura retornada no debe utilizar más memoria de la necesaria.

> 💡 **Sugerencia**: puede ser útil comenzar implementando una función auxiliar como:
> 
> ```
> int contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int nivel)
> ```

> ⚠️ **Importante**: asegurarse de que los *offsets* estén correctamente definidos y utilizados.

---

## Ejercicio 3b

El segundo requerimiento consiste en implementar una funcionalidad de cierre automático de casos utilizando inteligencia artificial, con el objetivo de reducir costos operativos.

El equipo de Machine Learning de Orga2-Morgan (liderado por el prestigioso científico **Satoshi Nakamoto**) proveerá una función que, dado un caso, indicará si puede cerrarse automáticamente o no.

La función a implementar es:

```
void resolver_automaticamente(funcionCierraCasos* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo)
```

### Lógica a implementar

- Para los casos de usuarios de nivel `1` o `2`:
  - Llamar a `funcionCierraCasos` que recibe un caso y retorna 0 o 1.
  - Si el resultado es `1`, el caso se puede cerrar automáticamente, marcándolo como cerrado favorablemente (`estado = 1`).
  - Si el resultado es `0` y la categoría del caso es `"CLT"` o `"RBO"`, el caso se puede cerrar automáticamente, marcando el caso como cerrado desfavorablemente (`estado = 2`).
  - En otros casos, el caso no se puede cerrar automáticamente por lo que no se debe modificar el estado.

- Para los casos de usuarios de nivel `0`, no se realiza ninguna acción (no se pueden cerrar automáticamente).
- Además, se solicita que los casos en los que no se tomo accion, es decir los que no se cerraron automáticamente, sean agregados al arreglo `casos_a_revisar` pasado por parámetro. 

> 🛠️ **Tip**: para comparar strings se puede utilizar la función `strncmp(char* str1, char* str2, size_t n)` de la biblioteca `string.h`. Notar que el campo categoría no termina con '\0'!

> 🛠️ **Tip**: se puede asumir que el arreglo `casos_a_revisar` tiene tamaño suficiente y está inicializado con todas sus posiciones en 0.

---

## Ejercicio 3c

Por último nos pidieron implementar una función que calcule estadísticas. 

```
estadisticas_t* calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id);
```

Donde:

```
typedef struct {
	uint8_t cantidad_CLT;
	uint8_t cantidad_RBO;
	uint8_t cantidad_KSC;
	uint8_t cantidad_KDT;
	uint8_t cantidad_estado_0;
	uint8_t cantidad_estado_1;
	uint8_t cantidad_estado_2;
} estadisticas_t; 

```

Que dada una lista de casos y un id de usuario
- Si `usuario_id != 0`: cuente la cantidad de casos de cada categoría y estado que pertenezcan al usuario dado.
- Si `usuario_id = 0`, contabilizará el total de los casos sin importar el usuario al que pertenezcan. 
