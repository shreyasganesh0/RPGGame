#include <stdio.h>
#include <dispatch/dispatch.h>
#include <Cocoa/Cocoa.h> // Correct import (includes Foundation)
#include "types.h"
#include "pixel_buffer.h"
#include <sys/mman.h>

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


@interface CustomView : NSView
@property (nonatomic, retain) NSTimer *timer;
@property uint32_t *bitmap_buffer;
@property int buffer_width;
@property int buffer_height;
@property int x_offset;
@property int y_offset;
@end

@implementation CustomView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.wantsLayer = NO; // Important for direct drawing
        self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawDuringViewResize;
    }
    return self;
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    if (self.window) {
        [self startTimer];
    } else {
        [self stopTimer];
    }
}

- (void)startTimer {
    [self stopTimer]; // Invalidate any existing timer

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                                 target:self
                                               selector:@selector(timerFired:)
                                               userInfo:nil
                                                repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerFired:(NSTimer *)timer {

    populate_buffer(self.bitmap_buffer, self.x_offset, self.y_offset);

    self.x_offset++;
    self.y_offset++;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay:YES]; // Redraw the entire view
    });
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); // More descriptive name

    if (!self.bitmap_buffer) { // Check for null buffer *before* context creation
        CFRelease(colorSpace);
        return;
    }

    CGContextRef bitmapContext = CGBitmapContextCreate(
        self.bitmap_buffer, self.buffer_width, self.buffer_height, 8, self.buffer_width * 4, colorSpace,
        kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little
    );

    if (!bitmapContext) { 
        CFRelease(colorSpace);
        return;
    }

    CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
    CFRelease(bitmapContext);

    if (image) {
        CGRect imageRect = CGRectMake(0, 0, self.buffer_width, self.buffer_height); // More descriptive name
        CGContextDrawImage(context, imageRect, image);
        CFRelease(image);
    }
    CFRelease(colorSpace);
}

@end

int main(int argc, char *argv[]) {
    uint32_t *back_buffer; 

    while (1){
        back_buffer = create_buffer(WIDTH, HEIGHT);
        if (!back_buffer){
            printf("back buffer allocation failed, retrying");
        }
        else{
            break;
        }
    }


    NSApplication *app = [NSApplication sharedApplication]; // Create the application

    NSRect rect = NSMakeRect(ORIGIN_X, ORIGIN_Y, WIDTH, HEIGHT);

    NSWindowStyleMask style = (NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled);

    NSWindow *window = [[NSWindow alloc] initWithContentRect:rect
                                                    styleMask:style
                                                      backing:NSBackingStoreBuffered
                                                        defer:NO]; // Use NO, not false

    [window setTitle:@"GameWindow"];
    [window makeKeyAndOrderFront:nil];

    CustomView *view = [[CustomView alloc] initWithFrame:rect];
    view.bitmap_buffer = back_buffer; 
    view.buffer_width = WIDTH;
    view.buffer_height = HEIGHT;
    view.x_offset = 0;
    view.y_offset = 0;
    [window setContentView:view];

    [app run];
    printf("My app is running\n"); // Add newline for clarity
    return 0;
}