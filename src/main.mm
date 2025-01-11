#include "main.h"
#include "pixel_buffer.h"
#include "global.h"
#include "game_update.h"
#include <iostream>
#include <fstream>
#include <string>
#include <chrono>
#include <iomanip> // For std::put_time
#include <sstream> // For std::ostringstream
#include <fcntl.h>
#include <unistd.h> // For dup2

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
    auto now = std::chrono::system_clock::now();

    // Convert to time_t to extract calendar time
    std::time_t now_time = std::chrono::system_clock::to_time_t(now);

    // Format the time using std::put_time and a stringstream
    std::ostringstream datetime_stream;
    datetime_stream << std::put_time(std::localtime(&now_time), "%Y-%m-%d_%H-%M-%S");

    // Get the formatted date-time string[]
    std::string datetime = datetime_stream.str();

    // Construct the log file path
    std::string log_path = "/Users/shreyas/Projects/Rpgdemo/logs/" + datetime + ".log";

    // Open the log file
    int out = open(log_path.c_str(), O_RDWR | O_CREAT | O_APPEND, 0600);
    if (out == -1) {
        perror("Failed to open log file");
        return 1;
    }

    // Redirect stdout and stderr to the log file
    dup2(out, STDOUT_FILENO);
    dup2(out, STDERR_FILENO);
    close(out);

    std::vector<const char *> file_path_list;
    const std::string path_1 = "/Users/shreyas/Projects/Rpgdemo/assets/Cerulean_City.png";
    const std::string path_2 = "/Users/shreyas/Projects/Rpgdemo/assets/Sprite_0001.png";
    file_path_list.push_back(path_1.c_str());
    file_path_list.push_back(path_2.c_str());

    for (auto &path : file_path_list){
        load_image(path);
    }

    NSApplication *app = [CustomApplication sharedApplication]; // Create the application

    AppDelegate *delegate = [[AppDelegate alloc] init];

    [app setDelegate: delegate];

    [app run];
    
    return 0;
}