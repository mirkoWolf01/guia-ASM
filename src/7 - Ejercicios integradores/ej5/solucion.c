#include <stdlib.h>
#include <string.h>

#include "ejercicio.h"

/**
 * Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - hay_accion_que_toque
 */
bool EJERCICIO_1_HECHO = true;

/**
 * Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - invocar_acciones
 */
bool EJERCICIO_2_HECHO = true;

/**
 * Marca el ejercicio 3 como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - contar_cartas
 */
bool EJERCICIO_3_HECHO = true;

#define NAME_SIZE 12

#define ANCHO_CAMPO 10
#define ALTO_CAMPO 5
/**
 * Dada una secuencia de acciones determinar si hay alguna cuya carta tenga un
 * nombre idéntico (mismos contenidos, no mismo puntero) al pasado por
 * parámetro.
 *
 * El resultado es un valor booleano, la representación de los booleanos de C es
 * la siguiente:
 *   - El valor `0` es `false`
 *   - Cualquier otro valor es `true`
 */
bool hay_accion_que_toque(accion_t *accion, char *nombre)
{
	accion_t *accion_actual = accion;
	while (accion_actual != NULL)
	{
		carta_t *carta = accion_actual->destino;

		if (!strncmp(carta->nombre, nombre, NAME_SIZE))
			return true;

		accion_actual = accion_actual->siguiente;
	}
	return false;
}

/**
 * Invoca las acciones que fueron encoladas en la secuencia proporcionada en el
 * primer parámetro.
 *
 * A la hora de procesar una acción esta sólo se invoca si la carta destino
 * sigue en juego.
 *
 * Luego de invocar una acción, si la carta destino tiene cero puntos de vida,
 * se debe marcar ésta como fuera de juego.
 *
 * Las funciones que implementan acciones de juego tienen la siguiente firma:
 * ```c
 * void mi_accion(tablero_t* tablero, carta_t* carta);
 * ```
 * - El tablero a utilizar es el pasado como parámetro
 * - La carta a utilizar es la carta destino de la acción (`accion->destino`)
 *
 * Las acciones se deben invocar en el orden natural de la secuencia (primero
 * la primera acción, segundo la segunda acción, etc). Las acciones asumen este
 * orden de ejecución.
 */

void invocar_acciones(accion_t *accion, tablero_t *tablero)
{
	accion_t *accion_actual = accion;
	while (accion_actual != NULL)
	{
		carta_t *carta_destino = accion_actual->destino;

		if (carta_destino->en_juego)
		{
			void (*aplicar_accion)(tablero_t *tablero, carta_t *carta) = accion_actual->invocar;
			aplicar_accion(tablero, carta_destino);
			if (carta_destino->en_juego && carta_destino->vida <= 0)
			{
				carta_destino->en_juego = false;
			}
		}

		accion_actual = accion_actual->siguiente;
	}
}

/**
 * Cuenta la cantidad de cartas rojas y azules en el tablero.
 *
 * Dado un tablero revisa el campo de juego y cuenta la cantidad de cartas
 * correspondientes al jugador rojo y al jugador azul. Este conteo incluye
 * tanto a las cartas en juego cómo a las fuera de juego (siempre que estén
 * visibles en el campo).
 *
 * Se debe considerar el caso de que el campo contenga cartas que no pertenecen
 * a ninguno de los dos jugadores.
 *
 * Las posiciones libres del campo tienen punteros nulos en lugar de apuntar a
 * una carta.
 *
 * El resultado debe ser escrito en las posiciones de memoria proporcionadas
 * como parámetro.
 */
void contar_cartas(tablero_t *tablero, uint32_t *cant_rojas, uint32_t *cant_azules)
{
	*cant_rojas = *cant_azules = 0;

	for (int i = 0; i < ALTO_CAMPO; i++)
	{
		for (int j = 0; j < ANCHO_CAMPO; j++)
		{
			carta_t *carta = tablero->campo[i][j];

			if (carta)
			{
				// NOTA: NO ES LO MISMO QUE HACER *cant_azules ++;
				if (carta->en_juego && carta->jugador == JUGADOR_AZUL)
					*cant_azules = *cant_azules +1;
				else if (carta->en_juego && carta->jugador == JUGADOR_ROJO)
					*cant_rojas = *cant_rojas +1;
			}
		}
	}
}
