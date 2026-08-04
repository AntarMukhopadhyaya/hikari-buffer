#include "hikari_buffer.h"
#include "buffer.h"
VALUE rb_mHikari;
VALUE rb_cBuffer;

RUBY_FUNC_EXPORTED void
Init_hikari_buffer(void)
{
  rb_mHikari = rb_define_module("Hikari");
  Init_hikari_buffer_class();
}

