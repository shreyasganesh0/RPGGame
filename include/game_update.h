#ifndef GAME_UPDATE_H
#define GAME_UPDATE_H
#include <bitset>
 
typedef struct InputKeys{

    std::bitset<3> keys;

    InputKeys() : keys(0) {}

    operator int() const{
        unsigned long k = keys.to_ulong();
        return (static_cast<int>(k));
    }

} input_keys_t;

typedef struct Scale{
    CGFloat scale_x;
    CGFloat scale_y;

} scale_t;

typedef struct RenderBuffer{
    uint32_t *buffer;
    int height;
    int width;

    RenderBuffer(uint32_t *buf, int w, int h) noexcept : buffer(buf), height(h), width(w) {}

    RenderBuffer(RenderBuffer &&other) noexcept
        : buffer(other.buffer), height(other.height), width(other.width) {
        other.buffer = nullptr;  // Nullify the source buffer
        other.height = 0;
        other.width = 0;
    }

    // Move assignment operator
    RenderBuffer &operator=(RenderBuffer &&other) noexcept {
        if (this != &other) {
            delete[] buffer; // Free existing resources

            buffer = other.buffer;
            height = other.height;
            width = other.width;

            other.buffer = nullptr;
            other.height = 0;
            other.width = 0;
        }
        return *this;
    }

} buffer_t;

typedef struct Image{
    const uint8_t *raw_pixels;
    int width;
    int height;
    size_t bytes_per_row;
} image_t;

void render_update_buffer(buffer_t &buffer);
#endif