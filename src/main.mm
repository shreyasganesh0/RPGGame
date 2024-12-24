#include <stdio.h>
#include "types.h"
#include "pixel_buffer.h"

@interface CustomView : NSView
@property uint32_t *bitmap_buffer;
@property int buffer_width;
@property int buffer_height;
@end
@implementation CustomView
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap_context = CGBitmapContextCreate(
        self.bitmap_buffer, self.buffer_width, self.buffer_height, 8, self.buffer_width * 4, color_space,
        kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little
    );
    CGImageRef image = CGBitmapContextCreateImage(bitmap_context);
    CGRect rect = CGRectMake(0, 0, self.buffer_width, self.buffer_height);
    CGContextDrawImage(context, rect, image);
}
@end



int main(int argc, char* argv[]){

    app_t* app = [app_t sharedApplication];

    rect_t rect = NSMakeRect(ORIGIN_X, ORIGIN_Y, WIDTH, HEIGHT);

    style_t style = (NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable|NSWindowStyleMaskTitled);

    wind_t* window = [[wind_t alloc] initWithContentRect: rect
                                     styleMask: style
                                     backing: NSBackingStoreBuffered
                                     defer: false];

    [window setTitle:@"GameWindow"];
    [window makeKeyAndOrderFront:nil];

    CustomView* view = [[CustomView alloc] initWithFrame:rect];
    view.bitmap_buffer = create_buffer();
    view.buffer_width = WIDTH;
    view.buffer_height = HEIGHT; 
    [view setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawDuringViewResize];
    [view setWantsLayer:NO];
    [window setContentView:view];

    [app run];
    printf("My app is running");
}
