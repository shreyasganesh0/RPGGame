#ifndef MAIN_H
#define MAIN_H

#include <Cocoa/Cocoa.h>
#include "types.h"
#include "drawing.h"

@interface CustomApplication : NSApplication
@end

@interface AppDelegate : NSObject<NSApplicationDelegate, NSWindowDelegate>
@property(strong, nonatomic) NSWindow *window;
@end


#endif