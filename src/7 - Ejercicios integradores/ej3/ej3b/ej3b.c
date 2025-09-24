#include "../ejs.h"

#define CATERGORIA_CASO_CLT "CLT"
#define CATERGORIA_CASO_RBO "RBO"
#define CATEGORIA_SIZE 4

void resolver_automaticamente(funcionCierraCasos_t* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo){

    int k = 0;

    for(int i = 0; i < largo; i++){
        caso_t caso = arreglo_casos[i];
        
        if(caso.usuario->nivel == 0){
            casos_a_revisar[k] = caso;
            k++;
        }
        else{
            uint16_t func_res = funcion(&caso);

            if(func_res == 1)
                caso.estado = 1;
            else if(strncmp(caso.categoria, CATERGORIA_CASO_CLT, CATEGORIA_SIZE) == 0 || strncmp(caso.categoria, CATERGORIA_CASO_RBO, CATEGORIA_SIZE) == 0)
                caso.estado = 2;
            else{
                casos_a_revisar[k] = caso;
                k++;
            }
            arreglo_casos[i] = caso;
        }
    }
}

