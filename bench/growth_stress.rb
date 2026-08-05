# frozen_string_literal: true

require "benchmark/ips"

require "hikari_buffer"

Benchmark.ips do |x|
  x.report("Growth (8 -> many)") do
    buf = Hikari::Buffer.new(8)

    10_000.times do |i|
      buf.write_u32(i)
    end
  end

  x.compare!
end
