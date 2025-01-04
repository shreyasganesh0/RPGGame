#ifndef DRAWING_H
#define DRAWING_H

#include <Cocoa/Cocoa.h>
#include <stdint.h>

typedef struct Scale{
    CGFloat scale_x;
    CGFloat scale_y;

} scale_t;

typedef struct RenderBuffer{
    uint32_t *buffer;
    int height;
    int width;

    RenderBuffer(uint32_t *buf, int w, int h) noexcept : buffer(buf), height(h), width(w) {}

    RenderBuffer(RenderBuffer &&other) noexcept
        : buffer(other.buffer), height(other.height), width(other.width) {
        other.buffer = nullptr;  // Nullify the source buffer
        other.height = 0;
        other.width = 0;
    }

    // Move assignment operator
    RenderBuffer &operator=(RenderBuffer &&other) noexcept {
        if (this != &other) {
            delete[] buffer; // Free existing resources

            buffer = other.buffer;
            height = other.height;
            width = other.width;

            other.buffer = nullptr;  // Nullify the source buffer
            other.height = 0;
            other.width = 0;
        }
        return *this;
    }

} buffer_t;

@interface CustomView : NSView
@property (nonatomic, retain) NSTimer *timer;
@property uint32_t *bitmap_buffer;
@property (nonatomic, retain) NSString *path;
@property int buffer_width;
@property int buffer_height;
@property int x_offset;
@property int y_offset;
@end

#endif