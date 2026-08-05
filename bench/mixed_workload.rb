# frozen_string_literal: true

require "benchmark/ips"
require "hikari_buffer"

TEXT = "Hello World"

buf = Hikari::Buffer.new

Benchmark.ips do |x|
  x.report("Array#pack") do
    [
      42,
      -1234,
      3.1415926535
    ].pack("L<q<d") + [1].pack("C") + [TEXT.bytesize].pack("L<") + TEXT
  end

  x.report("Hikari") do
    buf.clear

    buf
      .write_u32(42)
      .write_i64(-1234)
      .write_f64(3.1415926535)
      .write_bool(true)
      .write_string(TEXT)
  end

  x.compare!
end
