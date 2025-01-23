#ifndef MEMORY_H
#define MEMORY_H

#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>

typedef struct Arena arena_t;

typedef struct Arena {
   char *base;
   char *current;
   arena_t *next_arena;
   size_t capacity; 
} arena_t;

void arena_init(arena_t *arena, size_t num_pages);

void *arena_alloc(arena_t *arena, size_t size);

void arena_free(arena_t *arena);

void arena_reset(arena_t *arena);

#endif
