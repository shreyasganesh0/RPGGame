#ifndef GLOBAL_H
#define GLOBAL_H
#include <stdint.h>
#include <CoreFoundation/CoreFoundation.h> 
#include "game_update.h"

extern int x_offset;
extern int y_offset;
extern const uint8_t *raw_pixels;
extern int image_width;
extern int image_height;
extern size_t bytes_per_row;
extern CFDataRef g_image_data;
extern input_keys_t input;
#endif