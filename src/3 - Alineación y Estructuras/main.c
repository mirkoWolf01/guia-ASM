#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "Estructuras.h"

#define N1_SIZE 3
#define N2_SIZE 2
#define N3_SIZE 6

#define NP1_SIZE 10
#define NP2_SIZE 15
#define NP3_SIZE 7

enum nodos
{
	N1,
	N2,
	N3
};


void check_list();
void check_plist();

int main()
{
	check_list();

	check_plist();

	return 0;
}

void check_list()
{
	lista_t *lst = malloc(sizeof(lista_t));
	lst->head = NULL;

	// Nodo 1
	nodo_t *n1 = malloc(sizeof(nodo_t));
	uint32_t *arr1 = malloc(N1_SIZE * sizeof(uint32_t));
	arr1[0] = 1;
	arr1[1] = 2;
	arr1[2] = 3;
	n1->categoria = N1;
	n1->arreglo = arr1;
	n1->longitud = N1_SIZE;
	n1->next = NULL;

	// Nodo 2
	nodo_t *n2 = malloc(sizeof(nodo_t));
	uint32_t *arr2 = malloc(N2_SIZE * sizeof(uint32_t));
	arr2[0] = 10;
	arr2[1] = 20;
	n2->categoria = N2;
	n2->arreglo = arr2;
	n2->longitud = N2_SIZE;
	n2->next = NULL;

	// Nodo 3
	nodo_t *n3 = malloc(sizeof(nodo_t));
	uint32_t *arr3 = malloc(N3_SIZE * sizeof(uint32_t));
	arr3[0] = 6;
	arr3[1] = 11;
	arr3[2] = 12;
	arr3[3] = 1;
	arr3[4] = 7;
	arr3[5] = 2;
	n3->categoria = N3;
	n3->arreglo = arr3;
	n3->longitud = N3_SIZE;
	n3->next = NULL;


	lst->head = n1;
	n1->next = n2;
	n2->next = n3;

	printf("Cantidad de elems: %d\n",cantidad_total_de_elementos(lst));

	// Libero memoria
	free(arr1);
	free(n1);
	free(arr2);
	free(n2);
	free(arr3);
	free(n3);
	free(lst);
	
	return;
}

void check_plist(){
	packed_lista_t *lst = malloc(sizeof(packed_lista_t));
	lst->head = NULL;

	// Nodo 1
	packed_nodo_t *n1 = malloc(sizeof(packed_nodo_t));
	uint32_t *arr1 = malloc(NP1_SIZE * sizeof(uint32_t));
	arr1[0] = 1;
	arr1[1] = 2;
	arr1[2] = 3;
	n1->categoria = N1;
	n1->arreglo = arr1;
	n1->longitud = NP1_SIZE;
	n1->next = NULL;

	// Nodo 2
	packed_nodo_t *n2 = malloc(sizeof(packed_nodo_t));
	uint32_t *arr2 = malloc(NP2_SIZE * sizeof(uint32_t));
	arr2[0] = 10;
	arr2[1] = 20;
	n2->categoria = N2;
	n2->arreglo = arr2;
	n2->longitud = NP2_SIZE;
	n2->next = NULL;

	// Nodo 3
	packed_nodo_t *n3 = malloc(sizeof(packed_nodo_t));
	uint32_t *arr3 = malloc(NP3_SIZE * sizeof(uint32_t));
	arr3[0] = 6;
	arr3[1] = 11;
	arr3[2] = 12;
	arr3[3] = 1;
	arr3[4] = 7;
	arr3[5] = 2;
	n3->categoria = N3;
	n3->arreglo = arr3;
	n3->longitud = NP3_SIZE;
	n3->next = NULL;


	lst->head = n1;
	n1->next = n2;
	n2->next = n3;

	printf("Cantidad de elems en packed: %d\n",cantidad_total_de_elementos_packed(lst));

	// Libero memoria
	free(arr1);
	free(n1);
	free(arr2);
	free(n2);
	free(arr3);
	free(n3);
	free(lst);
	return;
}