#include "convert.h"

uint8_t
rb_value_to_u8(VALUE value)
{
    unsigned int n = NUM2UINT(value);

    if (n > UINT8_MAX) {
        rb_raise(
            rb_eRangeError,
            "value %u is out of range for u8",
            n
        );
    }

    return (uint8_t)n;
}

uint16_t
rb_value_to_u16(VALUE value)
{
    unsigned int n = NUM2UINT(value);

    if (n > UINT16_MAX) {
        rb_raise(
            rb_eRangeError,
            "value %u is out of range for u16",
            n
        );
    }

    return (uint16_t)n;
}

uint32_t
rb_value_to_u32(VALUE value)
{
    return (uint32_t)NUM2UINT(value);
}

uint64_t
rb_value_to_u64(VALUE value)
{
    return (uint64_t)NUM2ULL(value);
}

VALUE rb_u8_to_value(uint8_t value)
{
    return UINT2NUM(value);
}

VALUE rb_u16_to_value(uint16_t value)
{
    return UINT2NUM(value);
}

VALUE rb_u32_to_value(uint32_t value)
{
    return UINT2NUM(value);
}

VALUE rb_u64_to_value(uint64_t value)
{
    return ULL2NUM(value);
}


int8_t
rb_value_to_i8(VALUE value)
{
    long n = NUM2LONG(value);
    if (n < INT8_MIN || n > INT8_MAX) {
        rb_raise(
            rb_eRangeError,
            "value %ld is out of range for i8",
            n
        );
    }
    return (int8_t)n;
}
int16_t
rb_value_to_i16(VALUE value)
{
    long n = NUM2LONG(value);
    if (n < INT16_MIN || n > INT16_MAX) {
        rb_raise(
            rb_eRangeError,
            "value %ld is out of range for i16",
            n
        );
    }
    return (int16_t)n;
}
int32_t
rb_value_to_i32(VALUE value)
{
    return (int32_t)NUM2INT(value);
}

int64_t
rb_value_to_i64(VALUE value)
{
    return (int64_t)NUM2LL(value);
}
