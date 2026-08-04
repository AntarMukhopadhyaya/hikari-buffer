#ifndef HIKARI_CONVERT_H
#define HIKARI_CONVERT_H

#include <stdint.h>
#include <limits.h>

#include "ruby.h"

uint8_t rb_value_to_u8(VALUE value);
uint16_t rb_value_to_u16(VALUE value);
uint32_t rb_value_to_u32(VALUE value);
uint64_t rb_value_to_u64(VALUE value);

VALUE rb_u8_to_value(uint8_t value);
VALUE rb_u16_to_value(uint16_t value);
VALUE rb_u32_to_value(uint32_t value);
VALUE rb_u64_to_value(uint64_t value);


int8_t rb_value_to_i8(VALUE value);
int16_t rb_value_to_i16(VALUE value);
int32_t rb_value_to_i32(VALUE value);
int64_t rb_value_to_i64(VALUE value);

VALUE rb_i8_to_value(int8_t value);
VALUE rb_i16_to_value(int16_t value);
VALUE rb_i32_to_value(int32_t value);
VALUE rb_i64_to_value(int64_t value);

float rb_value_to_f32(VALUE value);
double rb_value_to_f64(VALUE value);

VALUE rb_f32_to_value(float value);
VALUE rb_f64_to_value(double value);



#endif
