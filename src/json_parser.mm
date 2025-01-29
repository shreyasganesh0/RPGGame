#include <fcntl.h>
#include <string.h>
#include <ctype.h>

#include "memory.h"
#include "json_parser.h"

void skip_whitespace(){
    assert(json_string != NULL);

    while (*json_string == '\n' || *json_string == '\t' || *json_string == ' ' || *json_string == '\r'){
        json_string++;
    }

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

char *parse_string(arena_t *arena){
   skip_whitespace();
   if(*json_string != '\"'){
       printf("Invalid string while parsing json");
       return NULL;
   }

   json_string++; // consume the " char
   char *start = json_string;

   while(json_string && *json_string != '\"' && *json_string != '\0' ){
       json_string++;
   }

   if (!json_string || *json_string == '\0'){
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

int *parse_number(arena_t *arena){
    skip_whitespace();
    if (!isdigit(*json_string)){
        printf("Invalid number while passing json\n");
        return NULL;
    }

    char *start = json_string;
    while(isdigit(*json_string)){
        json_string++;
    }

   if (!json_string || *json_string == '\0'){
       printf("Invalid string while parsing json");
       return NULL;
   }

   size_t str_size = json_string - start;
   char *ret_str = (char *)arena_alloc(arena, str_size + 1);
   if (ret_str == NULL){
       printf("Allocation failed during string parsing");
       return NULL;
   }

   strncpy(ret_str, start, str_size);
   ret_str[str_size] = '\0';

   int ret_int = atoi(ret_str);

   return &ret_int;
}

array_t *parse_array(arena_t *arena){

    if(*json_string != '['){
        printf("Invalid character while parsing array expected [\n");
        return NULL;
    }

    array_t *ret_array = (array_t *)arena_alloc(arena, sizeof(array_t));
    ret_array->capcity = 1;
    ret_array->objects = &(object_t *)arena_alloc(arena, ret_array->capacity * sizeof(object_t *)); 
    if (ret_array->objects == NULL){
        printf("Failed to allocate space in parse_array\n");
        return NULL;
    }
    ret_array->count = 1;

    json_string++; //consume [

   while(json_string && *json_string != ']' && *json_string != '\0'){

        skip_whitespace();
        if(*json_string != '{'){
            printf("Invalid character while parsing array expected [\n");
            return NULL;
        }
        object_t *ret_obj = parse_object();

        ret_array->*objects = ret_obj;
        ret_array->count++;
        if (ret_array->capacity < ret_array->count){
            // this allocates memory for the object pointers by +1 if capcity too less (could change this if needed)
            ret_array->objects = &(object_t *)arena_alloc(arena, sizeof(object_t *));
            if (ret_array->objects == NULL){
                printf("Failed to allocate space in parse_array\n");
                //arena free object_t
                return NULL;
            }
            ret_array->capacity += 1; 
        }
        ret_array->objects++;

        skip_whitespace();
        if (*json_string == ','){
            json_string++;
        }
    }

    return ret_array;
}


//TODO: create an arena intra free incase we fail to do capacity change and also add capacity thing for objects    
object_t *parse_object(arena_t *arena){
    
    if(*json_string != '{'){
        printf("Invalid character while parsing array expected [\n");
        return NULL;
    }
    
    object_t *ret_obj = (object_t *)arena_alloc(arena, sizeof(object_t));
    if (ret_obj == NULL){
        printf("Invalid character while parsing array expected [\n");
        return NULL;
    }
    ret_obj->capacity = 1;
    ret_obj->key_values = &(kv_t *)arena_alloc(arena, ret_object->capacity * sizeof(object_t *));
    if (ret_obj->key_values == NULL){
        printf("Invalid character while parsing array expected [\n");
        return NULL;
    }


    json_string++; // Consume {

    skip_whitespace();

    while(1){

        kv_t *curr_kv = (kv_t *)arena_alloc(arena, sizeof(kv_t));

        if (*json_string != '\"'){
            printf("Key wasnt proper\n");
            return NULL;
        }
        else {
            char *ret_str = parse_string(arena);
            if (ret_str == NULL){
                printf("Error parsing string in object\n");
                return NULL;
            curr_kv->key = ret_str;
        }
        
        skip_whitespace();

        if (*json_string != :){

            printf("Sepreator for the key value wsnt present\n");
            return NULL;
        }

        json_string++; // Consume :
        skip_whiltespace();

        value_t *val = (value_t *)arena_alloc(arena, sizeof(value_t));
        if (*json_string == '\"'){
            val->string_v = parse_string(arena);
            if (ret_str == NULL){
                printf("Error parsing string in object\n");
                return NULL;
            } 

        }
        else if (*json_string == '{'){
        
            val->object_v = parse_object(arena);
            if (ret_obj == NULL){
                printf("Error parsing string in object\n");
                return NULL;
            } 
        }
        else if (*json_string == '['){
        
            val->array_v = parse_array(arena);
            if (ret_array == NULL){
                printf("Error parsing string in object\n");
                return NULL;
            }
        }
        
        else if (isdigit(*json_string)){
            val->number_v = parse_number(arena);
            if (ret_num == NULL){
                printf("Error parsing string in object\n");
                return NULL;
            }
        }
        else{
            printf("Invalid value found while parsing object\n");
            return NULL;
        }


            

