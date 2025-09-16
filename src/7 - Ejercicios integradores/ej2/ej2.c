#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej2.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_2A_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - contarCombustibleAsignado
 */
bool EJERCICIO_2B_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - modificarUnidad
 */
bool EJERCICIO_2C_HECHO = true;


void optimizar(mapa_t mapa, attackunit_t *compartida, uint32_t (*fun_hash)(attackunit_t *))
{
    for (int i = 0; i < 255; i++)
    {
        for (int j = 0; j < 255; j++)
        {
            attackunit_t *unidad_actual = mapa[i][j];

            if (unidad_actual != NULL)
            {
                if (fun_hash(compartida) == fun_hash(unidad_actual))
                {
                    unidad_actual->references --;
                    mapa[i][j] = compartida;
                    compartida->references++;
                }
            }
        }
    }
    return;
}

uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char *))
{
    uint32_t res = 0;
     for (int i = 0; i < 255; i++)
    {
        for (int j = 0; j < 255; j++)
        {
            attackunit_t *unidad_actual = mapa[i][j];

            if (unidad_actual != NULL)
                res += unidad_actual->combustible - fun_combustible(unidad_actual->clase);
        }
    }
    return res;
}

void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t *))
{
    attackunit_t *unidad_actual = mapa[x][y];

    if (unidad_actual == NULL)
        return;

    if(unidad_actual->references == 1)
        fun_modificar(unidad_actual);
    else{
        attackunit_t * copia_instancia = malloc(sizeof(attackunit_t));

        for(int i = 0; i < 20; i++)
            copia_instancia->clase[i] = unidad_actual->clase[i];
        
        copia_instancia->combustible = unidad_actual->combustible;
        copia_instancia->references = 1;
        unidad_actual->references --;

        fun_modificar(copia_instancia);
        mapa[x][y] = copia_instancia;
    }
    return;
}
