#include "pixel_buffer.h"
#include "global.h"
#include "drawing.h"
#include "support.h"
#include <cmath>
#include <algorithm>
#include <sys/mman.h>
#include <CoreGraphics/CoreGraphics.h>


//This is what allocates a page aligned buffer
uint32_t * create_buffer(int width, int height){
    size_t size = width*height*(sizeof(uint32_t));

    uint32_t *buffer = (uint32_t *)mmap(nullptr, // Let system choose address
                                        size, 
                                        PROT_READ | PROT_WRITE, // Memory protection: Read and Write
                                        MAP_PRIVATE | MAP_ANON, // Anonymous mapping, not backed by a file
                                        -1, // File desc (not used since MAP_ANON) 
                                        0 // offset from address space 
                                        );
    if (buffer == MAP_FAILED){
        return nullptr;
    }
    return buffer;
}


//Fill the initialzed buffer with color pixels

void populate_buffer (buffer_t &buffer){
    for(int y{0}; y< buffer.height; y++){
        for (int x{0}; x< buffer.width; x++){
            uint8_t red = (x-x_offset)%256;
            uint8_t green{135};
            uint8_t blue = (y-y_offset)%256; 
            uint8_t alpha = 100;
            pixel_t pix{
                    blue,
                    green,
                    red,
                    alpha
                    };//TODO: check performance difference between pixel_t and directly assigning using manip of colors
            buffer.buffer[y*(buffer.width)+int(x)] = pix;
        }
    }
    return;

}

void draw_rectangle (buffer_t &buffer, int x_start, int y_start, int x_end, int y_end){
    
    for (int y = 0; y < buffer.height; y++){
        for (int x = 0; x < buffer.width; x++){
            if (y >= y_start+y_offset && y < y_end+y_offset && x >= x_start+x_offset && x < x_end+x_offset){
                uint8_t red = 100;
                uint8_t  blue = 0;
                uint8_t green = 0;
                pixel_t pix{ red, green ,blue, 0};
                buffer.buffer[y * buffer.width + x] = pix;
            }
        }
    }
}


void draw_circle (buffer_t buffer, int radius, int origin_x, int origin_y, scale_t scale){

   
    // scale the circle to the screen size

    //int scaled_radius = radius * std::min(scale.scale_x, scale.scale_y);
    //int scaled_origin_x = origin_x * scale.scale_x;
    //int scaled_origin_y = origin_y * scale.scale_y;

    for (int y = 0; y < buffer.height; y++){
        for (int x = 0; x < buffer.width; x++){
            float distance = (x+x_offset - origin_x) * (x+x_offset - origin_x)+ (y+y_offset - origin_y) * (y+y_offset - origin_y);
            if (std::sqrt(distance) <= float(radius)){
                uint8_t red = x%256;
                uint8_t  blue = 0;
                uint8_t green = 0;
                pixel_t pix{ red, green ,blue, 0};
                buffer.buffer[y * buffer.width + x] = pix;
            }
        }
    }
}

void load_image_to_buffer (buffer_t &buffer, image_t image, bool fg_marker){
    if (!image.raw_pixels){ 
        printf("Pixels are not available for the image");
       
    }

    for (int y = 0; y < buffer.height; y++) {
        for (int x = 0; x < buffer.width; x++) {

            int src_x = x;
            int src_y = y;

            if (fg_marker){ // this is so that foreground charcters move and not background
                src_x += x_offset;
                src_y += y_offset;
            }

            if (src_x >= 0 && src_x < image.width && src_y >= 0 && src_y < image.height) {

                //TODO: fix the color and blending
                
                // Retrieve premultiplied background pixel
                pixel_t bg_pix = pixel_t::from_uint32(buffer.buffer[y * buffer.width + x]);
                float bg_alpha = bg_pix.alpha / 255.0f;
                float bg_red   = bg_pix.red   / 255.0f * bg_alpha;
                float bg_green = bg_pix.green / 255.0f * bg_alpha;
                float bg_blue  = bg_pix.blue  / 255.0f * bg_alpha;

                // Retrieve premultiplied foreground pixel (assuming ABGR order)
                int src_idx = src_y * image.bytes_per_row + src_x * 4;
                float fg_red = image.raw_pixels[src_idx] / 255.0f; //red
                float fg_green  = image.raw_pixels[src_idx + 1] / 255.0f; //green
                float fg_blue = image.raw_pixels[src_idx + 2] / 255.0f; //blue
                float fg_alpha  = image.raw_pixels[src_idx + 3] / 255.0f; //alpha

                // Perform premultiplied alpha blending
                float out_alpha = fg_alpha + bg_alpha * (1.0f - fg_alpha);
                float out_red   = fg_red   + bg_red   * (1.0f - fg_alpha);
                float out_green = fg_green + bg_green * (1.0f - fg_alpha);
                float out_blue  = fg_blue  + bg_blue  * (1.0f - fg_alpha);

                pixel_t curr_pix{
                    uint8_t (out_alpha * 255.0f), // alpha
                    uint8_t(out_blue * 255.0f), // blue
                    uint8_t(out_green * 255.0f), // green
                    uint8_t(out_red * 255.0f) // red
                };
                buffer.buffer[y * buffer.width + x] = curr_pix;

            }
            else{
                //pixel_t pix{0, 0, 0};
                //buffer[y * buffer_width + x] = pix;
            }
        }
    }  
}

