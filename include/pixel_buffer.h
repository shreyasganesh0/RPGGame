#ifndef PIXEL_BUFFER_H
#define PIXEL_BUFFER_H
#include <stdint.h>
#include "drawing.h"


typedef struct Pixel{
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    uint8_t alpha;

    operator uint32_t() const{
        uint32_t pixel = (blue | (green << 8) | (red << 16) | (alpha << 24) );
        return pixel;
    }
} pixel_t;

uint32_t * create_buffer(int width, int height);

void populate_buffer(buffer_t &buffer, int, int);
void draw_rectangle (buffer_t &buffer, int x_offset, int y_offset, int x_start, int y_start, int x_end, int y_end);
void draw_circle (buffer_t &buffer, int x_offset, int y_offset, int radius, int origin_x, int origin_y, scale_t scale);
void load_image_to_buffer (buffer_t &buffer, int x_offset, int y_offset, const char *file_path);

#endif