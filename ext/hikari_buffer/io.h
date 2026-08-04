#ifndef HIKARI_IO_H
#define HIKARI_IO_H

#include "buffer.h"

void buffer_write(Buffer *buffer, const void *src, size_t length);
void buffer_read(Buffer *buffer, void *dst, size_t length);

void buffer_ensure_capacity(Buffer *buffer, size_t additional);
void buffer_check_read(Buffer *buffer, size_t length);


#endif
