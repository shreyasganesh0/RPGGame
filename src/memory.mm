#include <sys/mman.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <assert.h>

#include "memory.h"

void arena_init(arena_t *arena, size_t num_pages){

    long pagesize =  sysconf (_SC_PAGESIZE);
    if (pagesize == -1){
        int errsv = errno;
        printf("Error in sysconf %d\n", errsv); 
        pagesize = 4096;
    }

    size_t page_size = (size_t)pagesize*num_pages;

    arena = (arena_t *)mmap(NULL, page_size, PROT_READ|PROT_WRITE, MAP_ANON|MAP_PRIVATE, -1, 0);
    
    if (arena == NULL){
        int errsv = errno;
        printf("Error in mmap during arena creation %d\n", errsv); 
        return;
    }

    arena->base = (char *)arena; //should work?
    arena->current = (char *)arena;
    arena->next_arena = NULL;
    arena->capacity = page_size * num_pages;

    return;
}

void *arena_alloc(arena_t *arena, size_t size){

    assert(arena != NULL);

    static size_t alloc_counter = 1;
    void *ret_p = NULL;
    
    size_t curr_size = arena->current - arena->base;
    size_t exp_size = curr_size + size;

    int flag = arena->capacity < exp_size ? 1 : 0;

    if (exp_size >= arena->capacity){
        arena_t *new_arena = NULL;
        arena_init(new_arena, alloc_counter * 1); 
        alloc_counter++;
        arena->next_arena = new_arena;

        if (flag){
            new_arena->current += size;
            ret_p = (void *)new_arena->base;        
        }
    }

    if (!flag){
        arena->current += size;
        ret_p = (void *)(arena->current - size);
    }

    return ret_p;
}

void arena_reset(arena_t *arena){
    
    assert(arena != NULL);

    arena_t *temp_arena;
    temp_arena = arena->next_arena;

    while(temp_arena){
        arena_t* curr_arena = temp_arena;
        temp_arena = temp_arena->next_arena;
        free(curr_arena);
    }

    arena->base = arena->current;
    return;
}

void arena_free(arena_t *arena){

    assert(arena != NULL);

    arena_t *temp_arena;
    temp_arena = arena->next_arena;

    while(temp_arena){
        arena_t* curr_arena = temp_arena;
        temp_arena = temp_arena->next_arena;
        free(curr_arena);
    }

    free(arena);
    return;
}
        
