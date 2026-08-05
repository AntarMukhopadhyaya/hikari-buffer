# frozen_string_literal: true

require "benchmark/ips"
require "hikari_buffer"

buf = Hikari::Buffer.new

Benchmark.ips do |x|
  x.report("Marshal") do
    Marshal.dump({
                   hp: 100,
                   mana: 50,
                   x: 12.3,
                   y: 45.6,
                   alive: true,
                   level: 99
                 })
  end

  x.report("Hikari") do
    buf.clear

    buf
      .write_i32(100)
      .write_i32(50)
      .write_f32(12.3)
      .write_f32(45.6)
      .write_bool(true)
      .write_u16(99)
  end

  x.compare!
end
