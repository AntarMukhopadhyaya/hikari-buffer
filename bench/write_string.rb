# frozen_string_literal: true

require "benchmark/ips"
require "hikari_buffer"

TEXT = "Hello, Hikari Buffer!"

buf = Hikari::Buffer.new

Benchmark.ips do |x|
  x.report("String#dup") do
    TEXT.dup
  end

  x.report("Hikari") do
    buf.clear
    buf.write_string(TEXT)
  end

  x.compare!
end
