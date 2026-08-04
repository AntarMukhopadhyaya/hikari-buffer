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
      expect {
        Hikari::Buffer.new(0)
      }.to raise_error(ArgumentError)
    end

    it "raises when too many arguments are given" do
      expect {
        Hikari::Buffer.new(1, 2)
      }.to raise_error(ArgumentError)
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
      expect {
        buffer.seek(9)
      }.to raise_error(RangeError)
    end

    it "allows seeking exactly to the end" do
      expect {
        buffer.seek(8)
      }.not_to raise_error

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
      buffer.write_i64(-10000)

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
      expect {
        buffer.write_bool(123)
      }.to raise_error(TypeError)
    end
  end
end
