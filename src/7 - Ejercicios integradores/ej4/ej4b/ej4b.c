#include "ej4b.h"

#include <string.h>

#define ABILITY_NAME_SIZE 10
// OPCIONAL: implementar en C
void invocar_habilidad(void* carta_generica, char* habilidad) {
	card_t* carta = carta_generica;

	int cant_entries = carta->__dir_entries;
	for(int i = 0; i < cant_entries; i++){
		directory_entry_t* habilidad_actual = carta->__dir[i];

		if(strncmp(habilidad_actual->ability_name, habilidad, ABILITY_NAME_SIZE) == 0){
			void (*func) (void* carta) = habilidad_actual->ability_ptr;
			func(carta);
			return;
		}
	}
	if(carta->__archetype != NULL){
		carta = (card_t*) carta->__archetype;
		invocar_habilidad(carta, habilidad);
	}
	return;
}


#include "ej4b.h"

#include <string.h>