#include "drawing.h"
#include "pixel_buffer.h"

@implementation CustomView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.wantsLayer = NO; // important for direct drawing
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

    populate_buffer(self.bitmap_buffer, self.x_offset, self.y_offset, self.buffer_width, self.buffer_height);

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
        CGRect imageRect = self.bounds; 
        CGContextDrawImage(context, imageRect, image);
        CFRelease(image);
    }
    CFRelease(colorSpace);
}


-(void)keyDown:(NSEvent *)event{
    if (![self.window isKeyWindow]) {
        NSLog(@"Window is not key!");
        return;
    }
    NSLog(@"Key pressed: %@", event.charactersIgnoringModifiers);
    NSString *key = [event charactersIgnoringModifiers];
    unichar key_val{};
    if ([key length] > 0){
        key_val = [key characterAtIndex:0];
    }
    else{
        NSLog(@"Key not detected");
    }

    switch (key_val){
        case NSUpArrowFunctionKey:
        {
            self.y_offset -=10;
            break;
        }
        case NSDownArrowFunctionKey:
        {
            self.y_offset +=10;
            break;
        }
        case NSRightArrowFunctionKey:
        {
            self.x_offset +=10;
            break;
        }
        case NSLeftArrowFunctionKey:
        {
            self.x_offset -=10;
            break;
        }
        default:
        { // Handle any other key press with the default key
            [super keyDown:event];
            break;
        }
    }
}


//-(void)keyUp:(NSEvent *)event{} this can be implemented if we want to do stuff when the key is released

@end
