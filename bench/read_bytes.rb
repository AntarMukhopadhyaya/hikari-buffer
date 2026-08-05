# frozen_string_literal: true

require "benchmark/ips"
require "hikari_buffer"

DATA = Random.bytes(512)

buf = Hikari::Buffer.new
buf.write_bytes(DATA)

Benchmark.ips do |x|
  x.report("Hikari") do
    buf.rewind
    buf.read_bytes(DATA.bytesize)
  end
end
