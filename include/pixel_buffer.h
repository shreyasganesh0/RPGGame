#ifndef PIXEL_BUFFER_H
#define PIXEL_BUFFER_H
#include <stdint.h>

typedef struct Pixel{
    uint8_t red;
    uint8_t green;
    uint8_t blue;

    operator uint32_t() const{
        uint32_t pixel = (blue | (green << 8) | (red << 16) );
        return pixel;
    }
} pixel_t;

uint32_t * create_buffer(int width, int height);

void populate_buffer(uint32_t*, int, int, int, int);
void draw_rectangle (uint32_t* back_buffer, int x_offset, int y_offset, int buffer_width, int buffer_height, int x_start, int y_start, int x_end, int y_end);
void draw_circle (uint32_t* back_buffer, int x_offset, int y_offset, int buffer_width, int buffer_height, int radius, int origin_x, int origin_y);

#endif