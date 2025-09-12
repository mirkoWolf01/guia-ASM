#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "Memoria.h"

int main() {
	assert(strCmp("marcelo", "marca") == -1);

	char* str = "mamaguebo";
	printf("Largo de %s: %d\n", str, strLen(str));

	char* copia = strClone(str);

	printf("Valor del str copiado: %s\n", copia);

	strDelete(copia);

	FILE* archivo = fopen("ARCHIVO MARCELISITICO", "w");

	// ESTO LO ESTOY HACIENDO DESPUES DE ESTAR ESTUDIANDO POR MAS DE 8 HORAS SEGUIDAS IGNORAR LOS NOMBRE RAROS
	strPrint("mamaguebazo mistico ancestral", archivo);
	return 0;
}
