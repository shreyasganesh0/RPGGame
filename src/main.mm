#include <stdio.h>
#include <dispatch/dispatch.h>
#import <Cocoa/Cocoa.h> // Correct import (includes Foundation)
#include "types.h"
#include "pixel_buffer.h"

@interface CustomView : NSView
@property (nonatomic, retain) NSTimer *timer;
@property uint32_t *bitmap_buffer;
@property int buffer_width;
@property int buffer_height;
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

    if (!bitmapContext) { // Handle bitmap context creation failure
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

int main(int argc __unused, char *argv[] __unused) {
    NSApplication *app = [NSApplication sharedApplication]; // Use NSApplication

    NSRect rect = NSMakeRect(ORIGIN_X, ORIGIN_Y, WIDTH, HEIGHT);

    NSWindowStyleMask style = (NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled);

    NSWindow *window = [[NSWindow alloc] initWithContentRect:rect
                                                    styleMask:style
                                                      backing:NSBackingStoreBuffered
                                                        defer:NO]; // Use NO, not false

    [window setTitle:@"GameWindow"];
    [window makeKeyAndOrderFront:nil];

    CustomView *view = [[CustomView alloc] initWithFrame:rect];
    view.bitmap_buffer = create_buffer();
    view.buffer_width = WIDTH;
    view.buffer_height = HEIGHT;
    [window setContentView:view];

    [app run];
    printf("My app is running\n"); // Add newline for clarity
    return 0;
}