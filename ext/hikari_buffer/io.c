#include "io.h"

void buffer_ensure_capacity(Buffer *buffer, size_t additional)
{
    size_t required = buffer->cursor + additional;
    if (required <= buffer->capacity)
        return;

    while (buffer->capacity < required)
    {
        buffer->capacity *= 2;
    }
    // Reallocate the buffer's data to the new capacity

    REALLOC_N(
        buffer->data,
        uint8_t,
        buffer->capacity);
}
static inline void
buffer_commit_write(Buffer *buffer, size_t bytes)
{
    buffer->cursor += bytes;

    if (buffer->cursor > buffer->size)
    {
        buffer->size = buffer->cursor;
    }
}
void buffer_write(Buffer *buffer, const void *data, size_t length)
{
    buffer_ensure_capacity(buffer, length);
    memcpy(buffer->data + buffer->cursor, data, length);
    buffer_commit_write(buffer, length);
}
void buffer_check_read_bounds(Buffer *buffer, size_t length)
{
    if (buffer->cursor + length > buffer->size)
    {
        rb_raise(rb_eEOFError, "end of buffer reached while reading");
    }
}

void buffer_read(Buffer *buffer, void *dst, size_t length)
{
    buffer_check_read_bounds(buffer, length);

    memcpy(
        dst,
        buffer->data + buffer->cursor,
        length);
    buffer->cursor += length;
}
void buffer_peek(
    Buffer *buffer,
    void *dst,
    size_t length)
{
    size_t cursor = buffer->cursor;

    buffer_read(buffer, dst, length);

    buffer->cursor = cursor;
}
