#include <iostream>
#include <CoreGraphics/CoreGraphics.h>
#include "pixel_buffer.h"
#include "global.h"
#include "tile_loading.h"
#include "support.h"

void load_image(const char *file_path){

    image_t image{};

    char absolute_path[PATH_MAX];
    if (realpath(file_path, absolute_path) == NULL) {
        printf("Path is: %s", absolute_path);
        perror("Failed to resolve absolute path");
        return;
    }
    printf("Path is: %s", absolute_path); 
    CFStringRef path = CFStringCreateWithCString(kCFAllocatorDefault, absolute_path, kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path, kCFURLPOSIXPathStyle, false);
    CGImageSourceRef source = CGImageSourceCreateWithURL(url, nullptr);

    if(!source){
        printf("Failed to fetch image\n");
        CFRelease(url);
        CFRelease(path);
        return;
    }

    CGImageRef image_ref = CGImageSourceCreateImageAtIndex(source, 0, nullptr);

    if(!image_ref){
        printf("Failed to create image from file\n");
        CFRelease(source);
        CFRelease(url);
        CFRelease(path);
        return;
    }

    image.width = (CGImageGetWidth(image_ref));
    image.height = (CGImageGetHeight(image_ref));
    image.bytes_per_row = (CGImageGetBytesPerRow(image_ref));
    CGBitmapInfo bitmap_info = CGImageGetBitmapInfo(image_ref);
    
    decodeBitmapInfo(bitmap_info);
    CFRelease(source);
    CFRelease(url);
    CFRelease(path);

    g_image_data = CGDataProviderCopyData(CGImageGetDataProvider(image_ref));
    if(!g_image_data){
        printf("Failed to get image data\n");
        CGImageRelease(image_ref);
        return;
    }

    image.raw_pixels = (const uint8_t *)CFDataGetBytePtr(g_image_data);
    image_list.push_back(image);
    CGImageRelease(image_ref);
    return;
}

