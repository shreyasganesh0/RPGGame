#include "main.h"
#include "pixel_buffer.h"

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)notificaiton{

    uint32_t *back_buffer; 

    while (1){
        back_buffer = create_buffer(BUFFER_WIDTH, BUFFER_HEIGHT);
        if (!back_buffer){
            printf("back buffer allocation failed, retrying");
        }
        else{
            break;
        }
    }

    NSRect rect = NSMakeRect(ORIGIN_X, ORIGIN_Y, SCREEN_WIDTH, SCREEN_HEIGHT);

    NSWindowStyleMask style = (NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled);

    NSWindow *window = [[NSWindow alloc] initWithContentRect:rect
                                                    styleMask:style
                                                      backing:NSBackingStoreBuffered
                                                        defer:NO]; // Use NO, not false

    [window setTitle : @"GameWindow"];
    [window setDelegate : self];
    [NSApp activateIgnoringOtherApps:YES];
    [window makeKeyAndOrderFront : nil];
    if (![window isKeyWindow]) {
        NSLog(@"Window failed to become key");
    }
    CustomView *view = [[CustomView alloc] initWithFrame:rect];
    view.bitmap_buffer = back_buffer; 
    view.buffer_width = BUFFER_WIDTH;
    view.buffer_height = BUFFER_HEIGHT;
    view.x_offset = 0;
    view.y_offset = 0;
    [window setContentView:view];
    [window makeFirstResponder:view];
}

-(BOOL)windowShouldClose:(NSWindow *)window{
    NSLog(@"Window is closing");
    //this is where any future logic for things to be done after the close button is hit should be done
    [NSApp terminate:self];
    return YES;
}
@end


@implementation CustomApplication
- (void)sendEvent:(NSEvent *)event {
    [super sendEvent:event];
    if ([event type] == NSEventTypeKeyDown) {
        NSLog(@"KeyDown at application level: %@", event.charactersIgnoringModifiers);
    }
}
@end



int main(int argc, char *argv[]) {

    NSApplication *app = [CustomApplication sharedApplication]; // Create the application

    AppDelegate *delegate = [[AppDelegate alloc] init];

    [app setDelegate: delegate];

    [app run];
    
    return 0;
}