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
// pixel drawing logic lies here
- (void)timerFired:(NSTimer *)timer {
   
    int radius = 300;
    int origin_x = 100;
    int origin_y = 100; 
    // scale the circle to the screen size
    CGFloat scale_x = self.bounds.size.width / self.buffer_width;
    CGFloat scale_y = self.bounds.size.height / self.buffer_height;

    int scaled_radius = radius * MIN(scale_x, scale_y);
    int scaled_origin_x = origin_x * scale_x;
    int scaled_origin_y = origin_y * scale_y;

    populate_buffer(self.bitmap_buffer, self.x_offset, self.y_offset, self.buffer_width, self.buffer_height);
    draw_circle(self.bitmap_buffer, self.x_offset, self.y_offset, self.buffer_width, self.buffer_height, scaled_radius, scaled_origin_x, scaled_origin_y);

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

        // scale the image drawn to have a fixed aspect ratio
        CGFloat window_aspect = self.bounds.size.width / self.bounds.size.height;
        CGFloat buffer_aspect = (CGFloat)self.buffer_width / (CGFloat)self.buffer_height;


        CGRect image_rect;

        if (window_aspect > buffer_aspect){

            CGFloat width = self.bounds.size.height * buffer_aspect;
            CGFloat x_offset = (self.bounds.size.width - width) / 2.0;
            image_rect = CGRectMake(x_offset, 0, width, self.bounds.size.height);
        }   
        else{

            CGFloat height = self.bounds.size.width / buffer_aspect;
            CGFloat y_offset = (self.bounds.size.height - height) / 2.0;
            image_rect = CGRectMake(0, y_offset, self.bounds.size.width, height);
        }
        CGContextDrawImage(context, image_rect, image);
        CFRelease(image);
    }
    CFRelease(colorSpace);
}

// user input from keyboard
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
            self.y_offset +=10;
            break;
        }
        case NSDownArrowFunctionKey:
        {
            self.y_offset -=10;
            break;
        }
        case NSRightArrowFunctionKey:
        {
            self.x_offset -=10;
            break;
        }
        case NSLeftArrowFunctionKey:
        {
            self.x_offset +=10;
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
