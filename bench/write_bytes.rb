# frozen_string_literal: true

require "benchmark/ips"
require "hikari_buffer"

DATA = Random.bytes(512)

buf = Hikari::Buffer.new

Benchmark.ips do |x|
  x.report("String#dup") do
    DATA.dup
  end

  x.report("Hikari") do
    buf.clear
    buf.write_bytes(DATA)
  end

  x.compare!
end
