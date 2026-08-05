# frozen_string_literal: true

require "benchmark/ips"

require "hikari_buffer"

buf = Hikari::Buffer.new

Benchmark.ips do |x|
  x.report("Protocol") do
    buf.clear

    buf
      .write_u16(0xCAFE)
      .write_u32(100)
      .write_bool(true)
      .write_f64(99.5)
      .write_string("Player")
      .write_bytes("abcd")
  end
end
