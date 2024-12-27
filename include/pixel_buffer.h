#ifndef PIXEL_BUFFER_H
#define PIXEL_BUFFER_H
#include <stdint.h>
#include "types.h"
typedef struct Pixel{
    uint8_t red;
    uint8_t green;
    uint8_t blue;

    operator uint32_t() const{
        uint32_t pixel = (blue | (green << 8) | (red << 16) );
        return pixel;
    }
} pixel_t;
void populate_buffer(uint32_t*, int, int);
#endif