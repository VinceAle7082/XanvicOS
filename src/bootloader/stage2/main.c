#include "stdint.h"
#include "stdio.h"

void _cdecl cstart_(uint16_t bootDrive)
{
    const char far* far_str = "far string";

    puts("Hello World from Stage2!");
    printf("Hello World from printf!");
    for (;;);

}
