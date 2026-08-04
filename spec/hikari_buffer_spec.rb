# frozen_string_literal: true

RSpec.describe Hikari::Buffer do
  let(:buffer) { Hikari::Buffer.new }

  describe ".new" do
    it "creates a new buffer" do
      expect(buffer).to be_a(Hikari::Buffer)
    end

    it "uses the default capacity" do
      expect(buffer.capacity).to eq(1024)
    end

    it "accepts a custom capacity" do
      expect(Hikari::Buffer.new(256).capacity).to eq(256)
    end

    it "raises when capacity is zero" do
      expect do
        Hikari::Buffer.new(0)
      end.to raise_error(ArgumentError)
    end

    it "raises when too many arguments are given" do
      expect do
        Hikari::Buffer.new(1, 2)
      end.to raise_error(ArgumentError)
    end
  end

  describe "#size" do
    it "starts at zero" do
      expect(buffer.size).to eq(0)
    end
  end

  describe "#cursor" do
    it "starts at zero" do
      expect(buffer.cursor).to eq(0)
    end
  end

  describe "#clear" do
    it "returns itself" do
      expect(buffer.clear).to equal(buffer)
    end

    it "resets size and cursor" do
      buffer.write_u32(123)
      buffer.clear

      expect(buffer.size).to eq(0)
      expect(buffer.cursor).to eq(0)
    end
  end

  describe "#rewind" do
    it "returns itself" do
      expect(buffer.rewind).to equal(buffer)
    end

    it "moves the cursor to the beginning" do
      buffer.write_u32(123)

      expect(buffer.cursor).to eq(4)

      buffer.rewind

      expect(buffer.cursor).to eq(0)
    end
  end

  describe "#tell" do
    it "returns the current cursor position" do
      expect(buffer.tell).to eq(0)

      buffer.write_u16(10)

      expect(buffer.tell).to eq(2)
    end
  end

  describe "#remaining" do
    it "returns remaining readable bytes" do
      expect(buffer.remaining).to eq(0)

      buffer.write_u32(123)

      buffer.rewind

      expect(buffer.remaining).to eq(4)

      buffer.seek(2)

      expect(buffer.remaining).to eq(2)
    end
  end

  describe "#seek" do
    before do
      buffer.write_u64(123)
    end

    it "moves the cursor" do
      buffer.seek(4)

      expect(buffer.cursor).to eq(4)
    end

    it "returns itself" do
      expect(buffer.seek(0)).to equal(buffer)
    end

    it "raises when seeking past the end" do
      expect do
        buffer.seek(9)
      end.to raise_error(RangeError)
    end

    it "allows seeking exactly to the end" do
      expect do
        buffer.seek(8)
      end.not_to raise_error

      expect(buffer.cursor).to eq(8)
    end
  end

  describe "integer writes" do
    it "write_u8 advances the cursor and size" do
      buffer.write_u8(255)

      expect(buffer.cursor).to eq(1)
      expect(buffer.size).to eq(1)
    end

    it "write_u16 advances the cursor and size" do
      buffer.write_u16(65_535)

      expect(buffer.cursor).to eq(2)
      expect(buffer.size).to eq(2)
    end

    it "write_u32 advances the cursor and size" do
      buffer.write_u32(123)

      expect(buffer.cursor).to eq(4)
      expect(buffer.size).to eq(4)
    end

    it "write_u64 advances the cursor and size" do
      buffer.write_u64(123)

      expect(buffer.cursor).to eq(8)
      expect(buffer.size).to eq(8)
    end

    it "write_i8 advances the cursor and size" do
      buffer.write_i8(-10)

      expect(buffer.cursor).to eq(1)
      expect(buffer.size).to eq(1)
    end

    it "write_i16 advances the cursor and size" do
      buffer.write_i16(-100)

      expect(buffer.cursor).to eq(2)
      expect(buffer.size).to eq(2)
    end

    it "write_i32 advances the cursor and size" do
      buffer.write_i32(-1000)

      expect(buffer.cursor).to eq(4)
      expect(buffer.size).to eq(4)
    end

    it "write_i64 advances the cursor and size" do
      buffer.write_i64(-10_000)

      expect(buffer.cursor).to eq(8)
      expect(buffer.size).to eq(8)
    end
  end

  describe "#write_bool" do
    it "writes true" do
      buffer.write_bool(true)

      expect(buffer.size).to eq(1)
      expect(buffer.cursor).to eq(1)
    end

    it "writes false" do
      buffer.write_bool(false)

      expect(buffer.size).to eq(1)
      expect(buffer.cursor).to eq(1)
    end

    it "raises for non booleans" do
      expect do
        buffer.write_bool(123)
      end.to raise_error(TypeError)
    end
  end
  describe "primitive round trips" do
    it "round trips u8" do
      buffer.write_u8(255)

      buffer.rewind

      expect(buffer.read_u8).to eq(255)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips u16" do
      buffer.write_u16(65_535)

      buffer.rewind

      expect(buffer.read_u16).to eq(65_535)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips u32" do
      value = 4_294_967_295

      buffer.write_u32(value)

      buffer.rewind

      expect(buffer.read_u32).to eq(value)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips u64" do
      value = 18_446_744_073_709_551_615

      buffer.write_u64(value)

      buffer.rewind

      expect(buffer.read_u64).to eq(value)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips i8" do
      buffer.write_i8(-128)

      buffer.rewind

      expect(buffer.read_i8).to eq(-128)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips i16" do
      buffer.write_i16(-32_768)

      buffer.rewind

      expect(buffer.read_i16).to eq(-32_768)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips i32" do
      value = -2_147_483_648

      buffer.write_i32(value)

      buffer.rewind

      expect(buffer.read_i32).to eq(value)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips i64" do
      value = -9_223_372_036_854_775_808

      buffer.write_i64(value)

      buffer.rewind

      expect(buffer.read_i64).to eq(value)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips true" do
      buffer.write_bool(true)

      buffer.rewind

      expect(buffer.read_bool).to be(true)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips false" do
      buffer.write_bool(false)

      buffer.rewind

      expect(buffer.read_bool).to be(false)
      expect(buffer.remaining).to eq(0)
    end
  end
  describe "mixed primitive round trip" do
    it "reads values back in the order they were written" do
      buffer
        .write_u8(42)
        .write_i16(-1234)
        .write_u32(123_456)
        .write_bool(true)
        .write_i64(-987_654_321)

      buffer.rewind

      expect(buffer.read_u8).to eq(42)
      expect(buffer.read_i16).to eq(-1234)
      expect(buffer.read_u32).to eq(123_456)
      expect(buffer.read_bool).to be(true)
      expect(buffer.read_i64).to eq(-987_654_321)

      expect(buffer.remaining).to eq(0)
    end
  end
  describe "#write_bytes" do
    it "writes a string of bytes" do
      buffer.write_bytes("hello")

      expect(buffer.size).to eq(5)
      expect(buffer.cursor).to eq(5)
    end

    it "writes an empty string" do
      buffer.write_bytes("")

      expect(buffer.size).to eq(0)
      expect(buffer.cursor).to eq(0)
    end

    it "raises for non strings" do
      expect do
        buffer.write_bytes(123)
      end.to raise_error(TypeError)
    end
  end

  describe "byte round trips" do
    it "round trips bytes" do
      bytes = "Hello, Hikari!"

      buffer.write_bytes(bytes)

      buffer.rewind

      expect(buffer.read_bytes(bytes.bytesize)).to eq(bytes)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips empty bytes" do
      buffer.write_bytes("")

      buffer.rewind

      expect(buffer.read_bytes(0)).to eq("")
      expect(buffer.remaining).to eq(0)
    end
  end
  describe "#write_string" do
    it "writes a string with its length prefix" do
      buffer.write_string("hello")

      expect(buffer.size).to eq(4 + 5)
      expect(buffer.cursor).to eq(4 + 5)
    end

    it "writes an empty string" do
      buffer.write_string("")

      expect(buffer.size).to eq(4)
      expect(buffer.cursor).to eq(4)
    end

    it "raises for non strings" do
      expect do
        buffer.write_string(123)
      end.to raise_error(TypeError)
    end
  end

  describe "string round trips" do
    it "round trips a string" do
      text = "Hello, Hikari!"

      buffer.write_string(text)

      buffer.rewind

      expect(buffer.read_string).to eq(text)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips an empty string" do
      buffer.write_string("")

      buffer.rewind

      expect(buffer.read_string).to eq("")
      expect(buffer.remaining).to eq(0)
    end

    it "round trips unicode strings" do
      text = "こんにちは世界 🌸"

      buffer.write_string(text)

      buffer.rewind

      expect(buffer.read_string).to eq(text)
      expect(buffer.remaining).to eq(0)
    end
  end
  describe "float round trips" do
    it "round trips f32" do
      value = Math::PI.to_f

      buffer.write_f32(value)

      buffer.rewind

      expect(buffer.read_f32).to be_within(1e-6).of(value)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips f64" do
      value = Math::PI

      buffer.write_f64(value)

      buffer.rewind

      expect(buffer.read_f64).to be_within(1e-12).of(value)
      expect(buffer.remaining).to eq(0)
    end

    it "round trips negative floats" do
      value = -12_345.6789

      buffer.write_f64(value)

      buffer.rewind

      expect(buffer.read_f64).to be_within(1e-12).of(value)
    end

    it "round trips zero" do
      buffer.write_f32(0.0)

      buffer.rewind

      expect(buffer.read_f32).to eq(0.0)
    end
  end
  describe "mixed serialization" do
    it "round trips every supported primitive" do
      buffer
        .write_u8(42)
        .write_bool(true)
        .write_f64(Math::E)
        .write_string("Hikari")
        .write_bytes("\x01\x02\x03")
        .write_i32(-12_345)

      buffer.rewind

      expect(buffer.read_u8).to eq(42)
      expect(buffer.read_bool).to be(true)
      expect(buffer.read_f64).to be_within(1e-12).of(Math::E)
      expect(buffer.read_string).to eq("Hikari")
      expect(buffer.read_bytes(3)).to eq("\x01\x02\x03")
      expect(buffer.read_i32).to eq(-12_345)

      expect(buffer.remaining).to eq(0)
    end
  end
end
