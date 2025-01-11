#include "global.h"
#include <vector>
#include <utility>


std::vector<image_t> image_list{};
CFDataRef g_image_data = nullptr;
int x_offset = 0;
int y_offset = 0;
input_keys_t input{};