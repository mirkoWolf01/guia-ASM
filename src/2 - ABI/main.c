#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "ABI.h"

int main()
{
	/* Acá pueden realizar sus propias pruebas */
	 assert(alternate_sum_4_using_c(8, 2, 5, 1) == 10);

	assert(alternate_sum_4_using_c_alternative(8, 2, 5, 1) == 10);
	
	assert((alternate_sum_8(8, 2, 4, 5, 20, 15, 8, 16)) == 2);

	uint32_t prod2;
	product_2_f(&prod2, 3, 13.1);
	assert(prod2 == 39);

	double prod9;
	product_9_f(&prod9, 2, 1.5, 2, 1.5, 2, 1.5, 2, 1.5, 2, 1.5, 2, 1.5, 2, 1.5, 2, 1.5, 2, 1.5);
	assert(prod9 == 19683);
	return 0;
}
