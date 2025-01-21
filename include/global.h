#ifndef GLOBAL_H
#define GLOBAL_H
#include <stdint.h>
#include <CoreFoundation/CoreFoundation.h> 
#include "game_update.h"
#include <vector>
#include <utility>


extern int x_offset;
extern int y_offset;
extern std::vector<image_t> image_list;
extern CFDataRef g_image_data;
extern input_keys_t input;
#endif
