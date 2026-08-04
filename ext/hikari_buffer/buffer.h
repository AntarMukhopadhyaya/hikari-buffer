#ifndef HIKARI_BUFFER_BUFFER_H
#define HIKARI_BUFFER_BUFFER_H

#include "hikari_buffer.h"

typedef struct {
    uint8_t * data;
    size_t size;
    size_t capacity;
    size_t cursor;
} Buffer;

void Init_hikari_buffer_class(void);

#endif //HIKARI_BUFFER_BUFFER_H
