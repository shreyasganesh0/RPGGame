#include <stdio.h>
#include "types.h"

int x = 100;
int y = 100;
int width = 800;
int height = 600;
int main(int argc, char* argv[]){

    app_t* app = [app_t sharedApplication];

    rect_t rect = NSMakeRect(x, y, width, height);

    style_t style = (NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable|NSWindowStyleMaskTitled);

    wind_t* window = [[wind_t alloc] initWithContentRect: rect
                                     styleMask: style
                                     backing: NSBackingStoreBuffered
                                     defer: false];

    [window setTitle:@"GameWindow"];
    [window makeKeyAndOrderFront:nil];
    [app run];
    printf("My app is running");
}
