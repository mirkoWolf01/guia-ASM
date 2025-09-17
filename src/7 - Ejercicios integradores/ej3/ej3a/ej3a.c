#include "../ejs.h"

// Función auxiliar para contar casos por nivel
int contar_casos_por_nivel(caso_t *arreglo_casos, int largo, int nivel)
{
    int res = 0;
    for (int i = 0; i < largo; i++)
    {
        caso_t caso_i = arreglo_casos[i];
        if (caso_i.usuario->nivel == (uint32_t) nivel)
            res++;
    }
    return res;
}

segmentacion_t *segmentar_casos(caso_t *arreglo_casos, int largo)
{

    segmentacion_t *res = malloc(sizeof(segmentacion_t));
    res->casos_nivel_0 = NULL;
    res->casos_nivel_1 = NULL;
    res->casos_nivel_2 = NULL;

    int cant_nivel0 = contar_casos_por_nivel(arreglo_casos, largo, 0);
    int cant_nivel1 = contar_casos_por_nivel(arreglo_casos, largo, 1);
    int cant_nivel2 = contar_casos_por_nivel(arreglo_casos, largo, 2);

    if (cant_nivel0 != 0)
        res->casos_nivel_0 = malloc(cant_nivel0 * sizeof(caso_t));
    if (cant_nivel1 != 0)
        res->casos_nivel_1 = malloc(cant_nivel1 * sizeof(caso_t));
    if (cant_nivel2 != 0)
        res->casos_nivel_2 = malloc(cant_nivel2 * sizeof(caso_t));

    int n = 0, m = 0, k = 0;
    for (int i = 0; i < largo; i++)
    {
        caso_t caso_i = arreglo_casos[i];

        switch (caso_i.usuario->nivel)
        {
        case 0:
            res->casos_nivel_0[k] = caso_i;
            k++;
            break;
        case 1:
            res->casos_nivel_1[n] = caso_i;
            n++;
            break;

        case 2:
            res->casos_nivel_2[m] = caso_i;
            m++;
            break;
        }
    }
    return res;
}
