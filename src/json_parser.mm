#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <string.h>
#include <json_parser.h>

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

    char *fp = mmap(NULL, fstat_buf->st_size, PROT_READ, MAP_FILE, fd, 0); 
    if (fp == NULL) {

        printf("failed to mmap file\n");
        return NULL;
    }

    return fp;
}

char * string_parse(char *ptr) {


        ptr++; // skip "

        char *temp = strchr(ptr, '"');
        if (temp == NULL) {

            printf("failed to find end quote\n");
            return NULL;
        }


        char *ret_str = mallock(temp - ptr);
        if(strncpy(ret_str, ptr, temp - ptr) == NULL) {

            printf("failed to copy\n");
            return NULL;
        }

        *(ret_str + (temp - ptr)) = '\0'; //set terminator

        return ret_str;
}



void parse_json() {

    char *ptr = map_json_file();
    int item_count = 0;
    int is_key = 1;
    if (ptr == NULL) {

        printf("failed to map json file\n");
        return;
    }

    kv_t *json_kv_store = malloc(100*sizeof(kv_t));

    if (*ptr != '{') {

        printf("Invalid file\n");
        return;
    }

    while (1) {

        *ptr++;

        skip_whitespace(ptr);
        
        switch (*ptr) {

            case '"':
                {
                    char *ret_str = string_parse(ptr);

                    if (is_key) {

                        is_key = 0;
                        json_kv_store[item_count].key = ret_str;
                    } else {

                        is_key = 1;
                        json_kv_store[item_count].val.string_v = ret_str;
                    }

                } break;
            case '[':
                {
                    
                }

        if (*ptr != '"') {

            printf("Looking for key found %c\n", *ptr);
            return;
        }

        skip_whitespace();

        if (*ptr != ':') {

            printf("tried to find : found %c\n", *ptr);
            return;
        }

        ptr++; //skip :

        skip_whitespace();





