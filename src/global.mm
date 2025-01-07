#include "global.h"

const uint8_t *raw_pixels = nullptr;
int image_width = 0;
int image_height = 0;
size_t bytes_per_row = 0;
CFDataRef g_image_data = nullptr;
int x_offset = 0;
int y_offset = 0;
input_keys_t input{};