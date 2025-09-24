#include "../ejs.h"

#define ESTADO_CLT "CLT"
#define ESTADO_RBO "RBO"
#define ESTADO_KSC "KSC"
#define ESTADO_KDT "KDT"

#define CATEGORIA_SIZE 4

estadisticas_t* calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id){

    estadisticas_t* stats = malloc(sizeof(estadisticas_t));
    
    stats->cantidad_CLT = 0;
    stats->cantidad_RBO = 0;
    stats->cantidad_KSC = 0;
    stats->cantidad_KDT = 0;
    stats->cantidad_estado_0 = 0;
    stats->cantidad_estado_1 = 0;
    stats->cantidad_estado_2 = 0;


    for(int i = 0; i < largo; i++){

        caso_t caso = arreglo_casos[i];

        bool debo_registrar = false;
        if(usuario_id == 0 || caso.usuario->id == usuario_id)
            debo_registrar = true;
        
        if(debo_registrar){
            if(strncmp(caso.categoria, ESTADO_CLT, CATEGORIA_SIZE) == 0)
                stats->cantidad_CLT++;
            else if(strncmp(caso.categoria, ESTADO_RBO, CATEGORIA_SIZE) == 0)
                stats->cantidad_RBO++;
            else if(strncmp(caso.categoria, ESTADO_KSC, CATEGORIA_SIZE) == 0)
                stats->cantidad_KSC++;
            else if(strncmp(caso.categoria, ESTADO_KDT, CATEGORIA_SIZE) == 0)
                stats->cantidad_KDT++;
            
            if(caso.estado == 0)
                stats->cantidad_estado_0++;
            else if(caso.estado == 1)
                stats->cantidad_estado_1++;
            else if(caso.estado == 2)
                stats->cantidad_estado_2++;
        }
    }
    return stats;
}

