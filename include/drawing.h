#ifndef DRAWING_H
#define DRAWING_H

#include <Cocoa/Cocoa.h>
#include <stdint.h>

@interface CustomView : NSView
@property (nonatomic, retain) NSTimer *timer;
@property uint32_t *bitmap_buffer;
@property int buffer_width;
@property int buffer_height;
@property int x_offset;
@property int y_offset;
@end

#endif