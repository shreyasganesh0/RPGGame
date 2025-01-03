#include "global.h"

const uint8_t *raw_pixels = nullptr;
int image_width = 0;
int image_height = 0;
size_t bytes_per_row = 0;
CFDataRef g_image_data = nullptr;