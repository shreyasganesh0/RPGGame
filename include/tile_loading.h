#ifndef TILE_LOADING_H
#define TILE_LOADING_H

#define TILE_SIDE 16

typedef struct {
    int group;
    int sub_id;
    int start_x;
    int start_y;
} tile_t;


void load_image(const char *file_path);

#endif
