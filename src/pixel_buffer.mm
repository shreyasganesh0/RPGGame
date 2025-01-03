#include "pixel_buffer.h"
#include "global.h"
#include "drawing.h"
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

void populate_buffer (uint32_t* back_buffer,int x_offset, int y_offset, int buffer_width, int buffer_height){
    for(int y{0}; y< buffer_height; y++){
        for (int x{0}; x< buffer_width; x++){
            uint8_t red = (x-x_offset)%256;
            uint8_t green{126};
            uint8_t blue = (y-y_offset)%256; 
            pixel_t pix{
                    red,
                    green,
                    blue,
                    };//TODO: check performance difference between pixel_t and directly assigning using manip of colors
            back_buffer[y*(buffer_width)+int(x)] = pix;
        }
    }
    return;

}

void draw_rectangle (uint32_t* back_buffer, int x_offset, int y_offset, int buffer_width, int buffer_height, int x_start, int y_start, int x_end, int y_end){
    
    for (int y = 0; y < buffer_height; y++){
        for (int x = 0; x < buffer_width; x++){
            if (y >= y_start+y_offset && y < y_end+y_offset && x >= x_start+x_offset && x < x_end+x_offset){
                uint8_t red = 100;
                uint8_t  blue = 0;
                uint8_t green = 0;
                pixel_t pix{ red, green ,blue};
                back_buffer[y * buffer_width + x] = pix;
            }
        }
    }
}


void draw_circle (uint32_t* back_buffer, int x_offset, int y_offset, int buffer_width, int buffer_height, int radius, int origin_x, int origin_y, scale_t scale){

   
    // scale the circle to the screen size

    //int scaled_radius = radius * std::min(scale.scale_x, scale.scale_y);
    //int scaled_origin_x = origin_x * scale.scale_x;
    //int scaled_origin_y = origin_y * scale.scale_y;

    for (int y = 0; y < buffer_height; y++){
        for (int x = 0; x < buffer_width; x++){
            float distance = (x+x_offset - origin_x) * (x+x_offset - origin_x)+ (y+y_offset - origin_y) * (y+y_offset - origin_y);
            if (std::sqrt(distance) <= float(radius)){
                uint8_t red = x%256;
                uint8_t  blue = 0;
                uint8_t green = 0;
                pixel_t pix{ red, green ,blue};
                back_buffer[y * buffer_width + x] = pix;
            }
        }
    }
}

void load_image_to_buffer (uint32_t *buffer, int x_offset, int y_offset, int buffer_width, int buffer_height, const char *file_path){
    if (!raw_pixels){ 
        CFStringRef path = CFStringCreateWithCString(kCFAllocatorDefault, file_path, kCFStringEncodingUTF8);
        CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path, kCFURLPOSIXPathStyle, false);
        CGImageSourceRef source = CGImageSourceCreateWithURL(url, nullptr);
    
        if(!source){
            printf("Failed to fetch image\n");
            CFRelease(url);
            CFRelease(path);
            return;
        }
    
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, nullptr);
    
        if(!image){
            printf("Failed to create image from file\n");
            CFRelease(source);
            CFRelease(url);
            CFRelease(path);
            return;
        }
    
        image_width = CGImageGetWidth(image);
        image_height = CGImageGetHeight(image);
        bytes_per_row = CGImageGetBytesPerRow(image);
        CFRelease(source);
        CFRelease(url);
        CFRelease(path);
    
        g_image_data = CGDataProviderCopyData(CGImageGetDataProvider(image));
        if(!g_image_data){
            printf("Failed to get image data\n");
            CGImageRelease(image);
            return;
        }
    
        raw_pixels = (const uint8_t *)CFDataGetBytePtr(g_image_data);
        CGImageRelease(image);
    }

    for (int y = 0; y < buffer_height; y++) {
        for (int x = 0; x < buffer_width; x++) {
            int src_x = x + x_offset;
            int src_y = y + y_offset;

            if (src_x >= 0 && src_x < image_width && src_y >= 0 && src_y < image_height) {
                int src_idx = src_y * bytes_per_row + src_x * 4;
                uint8_t blue = raw_pixels[src_idx];
                uint8_t green = raw_pixels[src_idx + 1];
                uint8_t red = raw_pixels[src_idx + 2];
                pixel_t pix{red, green, blue};
                buffer[y * buffer_width + x] = pix;
            }
            else{
                //pixel_t pix{0, 0, 0};
                //buffer[y * buffer_width + x] = pix;
            }
        }
    }
}