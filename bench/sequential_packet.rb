# frozen_string_literal: true

require "benchmark/ips"
require "hikari_buffer"

TEXT = "Hello"

buf = Hikari::Buffer.new

Benchmark.ips do |x|
  x.report("Hikari packet") do
    buf.clear

    buf
      .write_u8(42)
      .write_i16(-123)
      .write_u32(999_999)
      .write_f64(Math::PI)
      .write_bool(true)
      .write_string(TEXT)

    buf.rewind

    buf.read_u8
    buf.read_i16
    buf.read_u32
    buf.read_f64
    buf.read_bool
    buf.read_string
  end
end
