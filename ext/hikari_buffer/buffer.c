#include "buffer.h"
#include "convert.h"
#include "io.h"

static VALUE
buffer_alloc(VALUE klass);

#define BUFFER_INITIAL_CAPACITY 1024

static void
buffer_mark(void *ptr)
{
  (void)ptr; // No Ruby objects to mark
}

static void
buffer_free(void *ptr)
{
 Buffer *buffer = ptr;
 if (buffer == NULL)
    return;
  xfree(buffer->data);
}

static const rb_data_type_t buffer_type = {
  .wrap_struct_name = "Hikari::Buffer",
  .function = {
    .dmark = buffer_mark,
    .dfree = buffer_free,
    .dsize = NULL
  },
  .flags = RUBY_TYPED_FREE_IMMEDIATELY
};

static inline Buffer *
get_buffer_struct(VALUE self)
{
    Buffer *buffer;
    TypedData_Get_Struct(
        self,
        Buffer,
        &buffer_type,
        buffer
    );
    return buffer;
}

static VALUE
buffer_initialize(int argc, VALUE *argv, VALUE self)
{

    Buffer *buffer = get_buffer_struct(self);
    size_t capacity = BUFFER_INITIAL_CAPACITY;
    if(argc > 1)
        rb_raise(rb_eArgError, "wrong number of arguments (given %d, expected 0 or 1)", argc);
    if(argc == 1)
        capacity = NUM2SIZET(argv[0]);
    if (capacity == 0)
        rb_raise(rb_eArgError, "capacity must be greater than 0");
    buffer->capacity = capacity;
    buffer->size = 0;
    buffer->cursor = 0;
    buffer->data = ALLOC_N(uint8_t, capacity);
    return Qnil;
}





static VALUE
buffer_alloc(VALUE klass)
{
  Buffer *buffer;

  VALUE obj = TypedData_Make_Struct(
    klass,
    Buffer,
    &buffer_type,
    buffer
  );
  buffer->data = NULL;
  buffer->size = 0;
  buffer->cursor = 0;
  buffer->capacity = 0;
  return obj;
}

static VALUE
buffer_capacity(VALUE self)
{
    Buffer* buffer = get_buffer_struct(self);

    return SIZET2NUM(buffer->capacity);
}

static VALUE
buffer_size(VALUE self)
{
    Buffer * buffer = get_buffer_struct(self);

    return SIZET2NUM(buffer->size);
}

static VALUE
buffer_cursor(VALUE self)
{
    Buffer * buffer = get_buffer_struct(self);

    return SIZET2NUM(buffer->cursor);
}

static VALUE
buffer_clear(VALUE self)
{
    Buffer * buffer = get_buffer_struct(self);

    buffer->size = 0;
    buffer->cursor = 0;

    return self;
}
static VALUE
buffer_rewind(VALUE self)
{
    Buffer * buffer = get_buffer_struct(self);

    buffer->cursor = 0;

    return self;
}
static VALUE
buffer_tell(VALUE self)
{
    Buffer * buffer = get_buffer_struct(self);

    return SIZET2NUM(buffer->cursor);
}
static VALUE
buffer_remaining(VALUE self)
{
    Buffer * buffer = get_buffer_struct(self);

    return SIZET2NUM(buffer->size - buffer->cursor);
}
static VALUE
buffer_seek(VALUE self, VALUE pos)
{
    Buffer * buffer = get_buffer_struct(self);
    size_t position = NUM2SIZET(pos);
   if (position > buffer->size) {
        rb_raise(
            rb_eRangeError,
            "seek position %zu exceeds buffer size %zu",
            position,
            buffer->size
        );
    }
    buffer->cursor = position;
    return self;
}


static VALUE
buffer_write_u8(VALUE self, VALUE val)
{
    Buffer *buffer = get_buffer_struct(self);
    uint8_t value = rb_value_to_u8(val);
    buffer_write(
        buffer,
        &value,
        sizeof(value)
    );
    return self;
}

static VALUE
buffer_write_u16(VALUE self, VALUE val)
{
    Buffer *buffer = get_buffer_struct(self);
    uint16_t value = rb_value_to_u16(val);
    buffer_write(
        buffer,
        &value,
        sizeof(value)
    );
    return self;
}

static VALUE
buffer_write_u32(VALUE self, VALUE val)
{
    Buffer *buffer = get_buffer_struct(self);
    uint32_t value = rb_value_to_u32(val);
    buffer_write(
        buffer,
        &value,
        sizeof(value)
    );
    return self;
}

static VALUE
buffer_write_u64(VALUE self, VALUE val)
{
    Buffer *buffer = get_buffer_struct(self);
    uint64_t value = rb_value_to_u64(val);
    buffer_write(
        buffer,
        &value,
        sizeof(value)
    );
    return self;
}
static VALUE
buffer_write_bool(VALUE self, VALUE val)
{
    if(val != Qtrue && val != Qfalse)
        rb_raise(rb_eTypeError, "expected a boolean value");
    Buffer *buffer = get_buffer_struct(self);
    uint8_t value = RTEST(val) ? 1 : 0;
    buffer_write(
        buffer,
        &value,
        sizeof(value)
    );
    return self;
}

static VALUE
buffer_write_i8(VALUE self, VALUE val)
{
    Buffer *buffer = get_buffer_struct(self);
    int8_t value = rb_value_to_i8(val);
    buffer_write(
        buffer,
        &value,
        sizeof(value)
    );
    return self;
}
static VALUE
buffer_write_i16(VALUE self, VALUE val)
{
    Buffer *buffer = get_buffer_struct(self);
    int16_t value = rb_value_to_i16(val);
    buffer_write(
        buffer,
        &value,
        sizeof(value)
    );
    return self;
}
static VALUE
buffer_write_i32(VALUE self, VALUE val)
{
    Buffer *buffer = get_buffer_struct(self);
    int32_t value = rb_value_to_i32(val);
    buffer_write(
        buffer,
        &value,
        sizeof(value)
    );
    return self;
}
static VALUE
buffer_write_i64(VALUE self, VALUE val)
{
    Buffer *buffer = get_buffer_struct(self);
    int64_t value = rb_value_to_i64(val);
    buffer_write(
        buffer,
        &value,
        sizeof(value)
    );
    return self;
}

void
Init_hikari_buffer_class(void)
{
    rb_cBuffer = rb_define_class_under(
        rb_mHikari,
        "Buffer",
        rb_cObject
    );

    rb_define_alloc_func(
        rb_cBuffer,
        buffer_alloc
    );
    rb_define_method(
        rb_cBuffer,
        "initialize",
        buffer_initialize,
        -1
    );
    rb_define_method(
        rb_cBuffer,
        "capacity",
        buffer_capacity,
        0
    );
    rb_define_method(
        rb_cBuffer,
        "size",
        buffer_size,
        0
    );
    rb_define_method(
        rb_cBuffer,
        "cursor",
        buffer_cursor,
        0
    );
    rb_define_method(
        rb_cBuffer,
        "clear",
        buffer_clear,
        0
    );
    rb_define_method(
        rb_cBuffer,
        "rewind",
        buffer_rewind,
        0
    );
    rb_define_method(
        rb_cBuffer,
        "tell",
        buffer_tell,
        0
    );
    rb_define_method(
        rb_cBuffer,
        "seek",
        buffer_seek,
        1
    );
    rb_define_method(
        rb_cBuffer,
        "remaining",
        buffer_remaining,
        0
    );
    rb_define_method(
        rb_cBuffer,
        "write_u8",
        buffer_write_u8,
        1
    );
    rb_define_method(
        rb_cBuffer,
        "write_u16",
        buffer_write_u16,
        1
    );
    rb_define_method(
        rb_cBuffer,
        "write_u32",
        buffer_write_u32,
        1
    );
    rb_define_method(
        rb_cBuffer,
        "write_u64",
        buffer_write_u64,
        1
    );
    rb_define_method(
        rb_cBuffer,
        "write_bool",
        buffer_write_bool,
        1
    );
    rb_define_method(
        rb_cBuffer,
        "write_i8",
        buffer_write_i8,
        1
    );
    rb_define_method(
        rb_cBuffer,
        "write_i16",
        buffer_write_i16,
        1
    );
    rb_define_method(
        rb_cBuffer,
        "write_i32",
        buffer_write_i32,
        1
    );
    rb_define_method(
        rb_cBuffer,
        "write_i64",
        buffer_write_i64,
        1
    );
}









