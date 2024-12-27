#include "pixel_buffer.h"

void populate_buffer (uint32_t* back_buffer,int x_offset, int y_offset){
    for(int y{0}; y<HEIGHT; y++){
        for (int x{0}; x<WIDTH; x++){
            uint8_t red = (x+x_offset)%256;
            uint8_t green{126};
            uint8_t blue = (y+y_offset)%256; 
            pixel_t pix{
                    red,
                    green,
                    blue,
                    };//TODO: check performance difference between pixel_t and directly assigning using manip of colors
            back_buffer[y*(WIDTH)+int(x)] = pix;
        }
    }
    return;
}

