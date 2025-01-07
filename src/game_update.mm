#include "pixel_buffer.h"
#include "game_update.h"
#include "global.h"

void render_update_buffer (buffer_t &buffer){


    switch (int(input)){
        case 0b100:
            x_offset +=10;
            input.keys.set(2, false);
            break;
        case 0b101:
            x_offset -=10;
            input.keys.set(2, false);
            break;
        case 0b110:
            y_offset -=10;
            input.keys.set(2, false);
            break;
        case 0b111:
            y_offset +=10;
            input.keys.set(2, false);
            break;
        default:

            input.keys.set(2, false);
    } 

    std::string path = "../Resources/assets/Sprite_0001.png";
    const char *c_path = path.c_str();

    populate_buffer(buffer);
    load_image_to_buffer(buffer, c_path);
}