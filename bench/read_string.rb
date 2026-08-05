# frozen_string_literal: true

require "benchmark/ips"
require "hikari_buffer"

TEXT = "Hello, Hikari Buffer!"

buf = Hikari::Buffer.new
buf.write_string(TEXT)

Benchmark.ips do |x|
  x.report("Hikari") do
    buf.rewind
    buf.read_string
  end
end
