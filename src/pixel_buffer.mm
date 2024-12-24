#include "pixel_buffer.h"

uint32_t* create_buffer (){
    uint32_t* back_buffer = new uint32_t[WIDTH*HEIGHT];
    
    int y{0};

    uint8_t red{0};
    uint8_t green{0};
    uint8_t blue{100};
    for(; y<HEIGHT; y++){
        for (int x{0}; x<WIDTH; x++){

            pixel_t pix{red, green, blue};//TODO: check performance difference between pixel_t and directly assigning using manip of colors
            back_buffer[y*WIDTH+x] = pix;
        }
    }

    return back_buffer;
}

