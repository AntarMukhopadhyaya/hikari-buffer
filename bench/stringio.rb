# frozen_string_literal: true

require "benchmark/ips"
require "stringio"

require "hikari_buffer"

buf = Hikari::Buffer.new
io = StringIO.new

Benchmark.ips do |x|
  x.report("StringIO") do
    io.rewind
    io.write([123].pack("L"))
  end

  x.report("Hikari") do
    buf.clear
    buf.write_u32(123)
  end

  x.compare!
end
