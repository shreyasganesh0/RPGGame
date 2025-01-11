#include "pixel_buffer.h"
#include "game_update.h"
#include "global.h"

void render_update_buffer (buffer_t &buffer){


    switch (int(input)){
        case 0b100:
            y_offset +=10;
            input.keys.reset();
            break;
        case 0b101:
            y_offset -=10;
            input.keys.reset();
            break;
        case 0b110:
            x_offset -=10;
            input.keys.reset();
            break;
        case 0b111:
            x_offset +=10;
            input.keys.reset();
            break;
        default:

    } 
    
    // load images from the image list onto the screen
    bool fg_marker = false;
    for (int i = 0; i < image_list.size(); i++){ 
        if (i > 0){
            fg_marker = true;
        }
        load_image_to_buffer(buffer, image_list[i], fg_marker);
    }
}