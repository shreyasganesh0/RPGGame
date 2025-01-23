#ifndef JSON_PARSER_H
#define JSON_PARSER_H


typedef struct {
    char *key;
    value_t *value; // will this work with pointer types?
} kv_t;

typedef struct {
kv_t **key_values; // stores a list of key values
    size_t count;
} object_t;

typedef struct { 
    object_t **objects; // stores a list of objects (for now)
    size_t count;
} array_t;

typedef union {
    char *string_v; // strings

    int number_v; // numbers

    object_t object_v; // objects

    array_t array_v; // arrays
} value_t;

void parse_json_from_file(const char *file_path);

char *parse_string();

int *parse_number();

object_t *parse_object();

array_t *parse_array();

#endif
