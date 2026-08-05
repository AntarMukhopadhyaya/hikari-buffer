# frozen_string_literal: true

require "benchmark/ips"
require "hikari_buffer"
buf = Hikari::Buffer.new
Benchmark.ips do |x|
  x.report("Array#pack") do
    [123_456_789].pack("L")
  end
  x.report("Hikari") do
    buf.write_u32(123_456_789)
  end
  x.compare!
end
