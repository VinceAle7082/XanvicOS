#pragma once
#include "stdint.h"
#include <cstdint>
#include <stdio.h>

typedef struct {
    uint8_t id;
    uint16_t cilindri;
    uint16_t settori;
    uint16_t testine;
} DISCO;

bool InizializzaDisco(DISCO* disco, uint8_t numeroDisco);
bool leggiSettoriDisco(DISCO* disco, uint32_t lba, uint8_t settori, uint8_t far* dataOut);
