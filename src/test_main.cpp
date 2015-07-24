#include<stdio.h>
#include <stdlib.h>
#include "sfh_string.h"

int main(int argc, char *argv[])
{
	char *str1 = argv[1];
	char *str2 = argv[2];
	if (IsStringContain(str1, str2))
		printf("%s is a substr of  %s   \n", str2 , str1);
}
