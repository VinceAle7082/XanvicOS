#pragma once
#include "stdint.h"

void _cdecl x86_div64_32(uint64_t dividend, uint32_t divisor, uint64_t* quotientOut, uint32_t* remainderOut);
void _cdecl x86_Video_WriteCharTeletype(char c, uint8_t page);
void _cdecl x86_ResettaDisco(uint8_t drive);
void _cdecl x86_LeggiDisco(uint8_t drive, uint16_t cilindro, uint16_t testina, uint16_t settore, uint8_t numeroSettore, uint8_t far * dataOut);
void _cdecl X86_OttieniParametriDisco(uint8_t drive, uint16_t tipoDriveOut, uint16_t cilindriOut, uint16_t settoriOut, uint16_t testineOut);
