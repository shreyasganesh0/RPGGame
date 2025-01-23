#include <fcntl.h>
#include <string.h>

#include "memory.h"
#include "json_parser.h"


void parse_json_from_file(const char *file_path){

    int fd = open(file_path, O_RDONLY, 644);

    if (fd == -1) {
        int errsv = errno;
        printf("Failed to read asset json\n%d", errsv);
        return;
    }

    struct stat_t *file_stats;
    int err = fstat(fd, file_stats); 
    if (err == -1){
        int errsv = errno;
        printf("Failed to read asset json\n%d", errsv);
        return;
    }

    size_t file_size = file_stats.st_size;

    json_string = (char *)mmap(NULL,file_size, PROT_READ|PROT_WRITE, MAP_FILE|MAP_PRIVATE, fd, 0);
    if (json_string == NULL){
        int errsv = errno;
        printf("Failed to read asset json\n%d", errsv);
        return;
    }

    return;
}

//TODO: SKIP WHITESPACE FUNCTION NEEDED
char *parse_string(arena_t *arena){
   if(*json_string != '\"'){
       printf("Invalid string while parsing json");
       return NULL;
   }

   json_string++; // consume the " char
   char *start = json_string;

   while(*json_string && *json_string != '\"' && *json_string != '\0' ){
       json_string++;
   }

   if (!*json_string || *json_string == '\0'){
       printf("Invalid string while parsing json");
       return NULL;
   }

   size_t str_size = json_string - start;
   char *ret_str = (char *)arena_alloc(arena, str_size + 1);
   if (ret_str == NULL){
       printf("Allocation failed during string parsing);
       return NULL;
   }

   strncpy(ret_str, start, str_size);
   ret_str[str_size] = '\0';

   json_string++; // consume the ending "

   return ret_str;
}

int *parse_number();

object_t *parse_object();

array_t *parse_array();
