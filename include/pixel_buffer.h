#ifndef PIXEL_BUFFER_H
#define PIXEL_BUFFER_H
#include <stdint.h>
#include "drawing.h"


typedef struct Pixel{
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    uint8_t alpha;

    operator uint32_t() const{ // from pixel_t to uint32_t
        uint32_t pixel = (blue | (green << 8) | (red << 16) | (alpha << 24) );
        return pixel;
    }

    static Pixel from_uint32(uint32_t pixel_value) { //from uint32_t to pixel_t
        return {
            static_cast<uint8_t>((pixel_value >> 16) & 0xFF), // red
            static_cast<uint8_t>((pixel_value >> 8) & 0xFF),  // green
            static_cast<uint8_t>(pixel_value & 0xFF),         // blue
            static_cast<uint8_t>((pixel_value >> 24) & 0xFF)  // alpha
        };
    }
} pixel_t;

uint32_t * create_buffer(int width, int height);
void populate_buffer(buffer_t &buffer);
void draw_rectangle (buffer_t &buffer, int x_start, int y_start, int x_end, int y_end);
void draw_circle (buffer_t &buffer, int radius, int origin_x, int origin_y, scale_t scale);
void load_image_to_buffer (buffer_t &buffer, image_t image, bool fg_marker);
void load_image(const char *file_path);

#endif