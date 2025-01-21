#include "support.h"
#include "global.h"

void decodeBitmapInfo(CGBitmapInfo info) {
    // Decode alpha info (lower bits)
    switch (info & kCGBitmapAlphaInfoMask) {
        case kCGImageAlphaNone:
            printf("Alpha Info: kCGImageAlphaNone\n");
            break;
        case kCGImageAlphaPremultipliedLast:
            printf("Alpha Info: kCGImageAlphaPremultipliedLast\n");
            break;
        case kCGImageAlphaPremultipliedFirst:
            printf("Alpha Info: kCGImageAlphaPremultipliedFirst\n");
            break;
        case kCGImageAlphaNoneSkipLast:
            printf("Alpha Info: kCGImageAlphaNoneSkipLast\n");
            break;
        case kCGImageAlphaNoneSkipFirst:
            printf("Alpha Info: kCGImageAlphaNoneSkipFirst\n");
            break;
        case kCGImageAlphaOnly:
            printf("Alpha Info: kCGImageAlphaOnly\n");
            break;
        default:
            printf("Alpha Info: Unknown\n");
            break;
    }

    // Decode byte order (higher bits)
    switch (info & kCGBitmapByteOrderMask) {
        case kCGBitmapByteOrderDefault:
            printf("Byte Order: kCGBitmapByteOrderDefault\n");
            break;
        case kCGBitmapByteOrder16Little:
            printf("Byte Order: kCGBitmapByteOrder16Little\n");
            break;
        case kCGBitmapByteOrder32Little:
            printf("Byte Order: kCGBitmapByteOrder32Little\n");
            break;
        case kCGBitmapByteOrder16Big:
            printf("Byte Order: kCGBitmapByteOrder16Big\n");
            break;
        case kCGBitmapByteOrder32Big:
            printf("Byte Order: kCGBitmapByteOrder32Big\n");
            break;
        default:
            printf("Byte Order: Unknown\n");
            break;
    }
}


