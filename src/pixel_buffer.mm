#include "pixel_buffer.h"
#include <sys/mman.h>

//This is what allocates a page aligned buffer
uint32_t * create_buffer(int width, int height){
    size_t size = width*height*(sizeof(uint32_t));

    uint32_t *buffer = (uint32_t *)mmap(NULL, // Let system choose address
                                        size, 
                                        PROT_READ | PROT_WRITE, // Memory protection: Read and Write
                                        MAP_PRIVATE | MAP_ANON, // Anonymous mapping, not backed by a file
                                        -1, // File desc (not used since MAP_ANON) 
                                        0 // offset from address space 
                                        );
    if (buffer == MAP_FAILED){
        return NULL;
    }
    return buffer;
}


//Fill the initialzed buffer with color pixels

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

