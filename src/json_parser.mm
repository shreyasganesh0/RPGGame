#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <string.h>

char * map_json_file(const char *file_path) {

    int fd = open(file_path, O_RDONLY);
    if (fd == -1) {

        printf("failed to open file\n");
        return NULL;
    }

    struct stat fstat_buf;

    if (fstat(fd, &fstat_buf) == -1) {

        printf("failed to get file size\n");
        return NULL;
    }

    char *fp = mmap(NULL, fstat_buf->st_size, PROT_READ, MAP_ANONYMOUS, fd, 0); 
    if (fp == NULL) {

        printf("failed to mmap file\n");
        return NULL;
    }

    return fp;
}


void parse_json() {

    char *ptr = map_json_file();
    if (ptr == NULL) {

        printf("failed to map json file\n");
        return;
    }

    if (*ptr != '{') {

        printf("Invalid file\n");
        return;
    }

    while (1) {

        *ptr++;

        skip_whitespace(ptr);

        if (*ptr != '"') {

            printf("Looking for key found %c\n", *ptr);
            return;
        }

        ptr++; // skip "
        qstrchr(ptr, '"');
