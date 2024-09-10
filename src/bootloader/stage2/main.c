#include "stdint.h"
#include "stdio.h"

void _cdecl cstart_(uint16_t bootDrive)
{
    const char far* far_str = "far string";

    printf("Hello world from printf!");
    for (;;);

}
