# frozen_string_literal: true

RSpec.describe Hikari::Buffer do
  let(:buffer) { Hikari::Buffer.new }

  # ------------------------------------------------------------------
  # Constructor & initial state
  # ------------------------------------------------------------------

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
      expect { Hikari::Buffer.new(0) }.to raise_error(ArgumentError)
    end

    it "raises when too many arguments are given" do
      expect { Hikari::Buffer.new(1, 2) }.to raise_error(ArgumentError)
    end
  end

  describe "#capacity" do
    it "returns the allocated capacity" do
      expect(buffer.capacity).to be >= 0
    end

    it "does not change after writes within capacity" do
      cap = buffer.capacity
      buffer.write_u32(1)
      expect(buffer.capacity).to eq(cap)
    end

    it "may increase after writes exceeding capacity (auto-resize)" do
      small = Hikari::Buffer.new(1)
      small.write_u64(123)
      expect(small.capacity).to be >= 8
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

  # ------------------------------------------------------------------
  # Lifecycle: clear, rewind, tell, seek, remaining, skip
  # ------------------------------------------------------------------

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

    it "allows new writes after clear" do
      buffer.write_u32(123)
      buffer.clear
      buffer.write_u8(42)
      expect(buffer.size).to eq(1)
      buffer.rewind
      expect(buffer.read_u8).to eq(42)
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

    it "does not change size" do
      buffer.write_u32(123)
      buffer.rewind
      expect(buffer.size).to eq(4)
    end
  end

  describe "#tell" do
    it "returns the current cursor position" do
      expect(buffer.tell).to eq(0)
      buffer.write_u16(10)
      expect(buffer.tell).to eq(2)
    end

    it "reflects seek and rewind" do
      buffer.write_u64(1)
      buffer.rewind
      expect(buffer.tell).to eq(0)
      buffer.seek(4)
      expect(buffer.tell).to eq(4)
    end
  end

  describe "#remaining" do
    it "returns zero for empty buffer" do
      expect(buffer.remaining).to eq(0)
    end

    it "returns size - cursor after write" do
      buffer.write_u32(123)
      buffer.rewind
      expect(buffer.remaining).to eq(4)
    end

    it "decreases after reads" do
      buffer.write_u64(123)
      buffer.rewind
      buffer.read_u32
      expect(buffer.remaining).to eq(4) # 8 - 4
    end

    it "is zero after full read" do
      buffer.write_u16(1)
      buffer.rewind
      buffer.read_u16
      expect(buffer.remaining).to eq(0)
    end
  end

  describe "#seek" do
    before { buffer.write_u64(123) }

    it "moves the cursor" do
      buffer.seek(4)
      expect(buffer.cursor).to eq(4)
    end

    it "returns itself" do
      expect(buffer.seek(0)).to equal(buffer)
    end

    it "raises RangeError when seeking past the end" do
      expect { buffer.seek(9) }.to raise_error(RangeError)
    end

    it "allows seeking exactly to the end" do
      expect { buffer.seek(8) }.not_to raise_error
      expect(buffer.cursor).to eq(8)
    end

    it "can seek to zero after writes" do
      buffer.seek(0)
      expect(buffer.cursor).to eq(0)
    end
  end

  describe "#skip" do
    before do
      buffer.write_bytes("hello world") # 11 bytes
      buffer.rewind
    end

    it "advances the cursor" do
      buffer.skip(5)
      expect(buffer.tell).to eq(5)
    end

    it "returns itself" do
      expect(buffer.skip(0)).to equal(buffer)
    end

    it "allows skipping zero bytes" do
      buffer.skip(0)
      expect(buffer.tell).to eq(0)
    end

    it "raises EOFError when skipping beyond available data" do
      expect { buffer.skip(12) }.to raise_error(EOFError, /end of buffer/)
    end

    it "allows skipping exactly to the end" do
      buffer.skip(11)
      expect(buffer.tell).to eq(11)
      expect(buffer.remaining).to eq(0)
    end
  end

  # ------------------------------------------------------------------
  # Boolean write/read/peek
  # ------------------------------------------------------------------

  describe "#write_bool" do
    it "writes true as single byte" do
      buffer.write_bool(true)
      expect(buffer.size).to eq(1)
    end

    it "writes false as single byte" do
      buffer.write_bool(false)
      expect(buffer.size).to eq(1)
    end

    it "raises TypeError for non-boolean" do
      expect { buffer.write_bool(123) }.to raise_error(TypeError)
      expect { buffer.write_bool("true") }.to raise_error(TypeError)
      expect { buffer.write_bool(nil) }.to raise_error(TypeError)
    end

    it "returns self" do
      expect(buffer.write_bool(true)).to equal(buffer)
    end
  end

  describe "#read_bool" do
    it "reads true back" do
      buffer.write_bool(true)
      buffer.rewind
      expect(buffer.read_bool).to be(true)
    end

    it "reads false back" do
      buffer.write_bool(false)
      buffer.rewind
      expect(buffer.read_bool).to be(false)
    end

    it "advances cursor by 1" do
      buffer.write_bool(true)
      buffer.rewind
      buffer.read_bool
      expect(buffer.tell).to eq(1)
      expect(buffer.remaining).to eq(0)
    end

    it "raises EOFError when no data available" do
      expect { buffer.read_bool }.to raise_error(EOFError)
    end
  end

  describe "#peek_bool" do
    it "peeks without moving cursor" do
      buffer.write_bool(false)
      buffer.rewind
      expect(buffer.peek_bool).to be(false)
      expect(buffer.tell).to eq(0)
      expect(buffer.read_bool).to be(false) # still readable
    end

    it "raises EOFError on empty buffer" do
      expect { buffer.peek_bool }.to raise_error(EOFError)
    end
  end

  # ------------------------------------------------------------------
  # Integer types: u8, u16, u32, u64, i8, i16, i32, i64
  # ------------------------------------------------------------------

  shared_examples "integer type" do |type_sym, byte_size, min_val, max_val|
    write_method = "write_#{type_sym}"
    read_method  = "read_#{type_sym}"
    peek_method  = "peek_#{type_sym}"

    describe write_method.to_s do
      it "writes the value and advances cursor/size" do
        buffer.send(write_method, min_val)
        expect(buffer.size).to eq(byte_size)
        expect(buffer.cursor).to eq(byte_size)
      end

      it "returns self" do
        expect(buffer.send(write_method, max_val)).to equal(buffer)
      end

      if min_val < 0
        it "accepts negative values" do
          buffer.send(write_method, -1)
          buffer.rewind
          expect(buffer.send(read_method)).to eq(-1)
        end
      end
    end

    describe read_method.to_s do
      it "round trips min value" do
        buffer.send(write_method, min_val)
        buffer.rewind
        expect(buffer.send(read_method)).to eq(min_val)
        expect(buffer.remaining).to eq(0)
      end

      it "round trips max value" do
        buffer.send(write_method, max_val)
        buffer.rewind
        expect(buffer.send(read_method)).to eq(max_val)
      end

      it "advances cursor by correct byte count" do
        buffer.send(write_method, 1)
        buffer.rewind
        buffer.send(read_method)
        expect(buffer.tell).to eq(byte_size)
      end

      it "raises EOFError when insufficient data" do
        expect { buffer.send(read_method) }.to raise_error(EOFError)
      end
    end

    describe peek_method.to_s do
      it "returns the value without consuming it" do
        buffer.send(write_method, 42)
        buffer.rewind
        expect(buffer.send(peek_method)).to eq(42)
        expect(buffer.tell).to eq(0)
        expect(buffer.send(read_method)).to eq(42)
      end

      it "raises EOFError on empty buffer" do
        expect { buffer.send(peek_method) }.to raise_error(EOFError)
      end
    end
  end

  describe "integer types" do
    include_examples "integer type", :u8,  1, 0, 255
    include_examples "integer type", :u16, 2, 0, 65_535
    include_examples "integer type", :u32, 4, 0, 4_294_967_295
    include_examples "integer type", :u64, 8, 0, 18_446_744_073_709_551_615
    include_examples "integer type", :i8,  1, -128, 127
    include_examples "integer type", :i16, 2, -32_768, 32_767
    include_examples "integer type", :i32, 4, -2_147_483_648, 2_147_483_647
    include_examples "integer type", :i64, 8, -9_223_372_036_854_775_808, 9_223_372_036_854_775_807
  end

  # ------------------------------------------------------------------
  # Floating point types: f32, f64
  # ------------------------------------------------------------------

  shared_examples "float type" do |type_sym, byte_size, tolerance|
    write_method = "write_#{type_sym}"
    read_method  = "read_#{type_sym}"
    peek_method  = "peek_#{type_sym}"

    describe write_method.to_s do
      it "writes the value and advances cursor/size" do
        buffer.send(write_method, 1.0)
        expect(buffer.size).to eq(byte_size)
        expect(buffer.cursor).to eq(byte_size)
      end

      it "returns self" do
        expect(buffer.send(write_method, Math::PI)).to equal(buffer)
      end
    end

    describe read_method.to_s do
      it "round trips common values" do
        buffer.send(write_method, Math::PI)
        buffer.rewind
        expect(buffer.send(read_method)).to be_within(tolerance).of(Math::PI)
      end

      it "handles negative values" do
        buffer.send(write_method, -12_345.6789)
        buffer.rewind
        expect(buffer.send(read_method)).to be_within(tolerance).of(-12_345.6789)
      end

      it "handles zero" do
        buffer.send(write_method, 0.0)
        buffer.rewind
        expect(buffer.send(read_method)).to eq(0.0)
      end

      it "advances cursor" do
        buffer.send(write_method, 1.0)
        buffer.rewind
        buffer.send(read_method)
        expect(buffer.tell).to eq(byte_size)
      end

      it "raises EOFError when no data" do
        expect { buffer.send(read_method) }.to raise_error(EOFError)
      end
    end

    describe peek_method.to_s do
      it "peeks without consuming" do
        buffer.send(write_method, Math::E)
        buffer.rewind
        expect(buffer.send(peek_method)).to be_within(tolerance).of(Math::E)
        expect(buffer.tell).to eq(0)
        expect(buffer.send(read_method)).to be_within(tolerance).of(Math::E)
      end

      it "raises EOFError on empty buffer" do
        expect { buffer.send(peek_method) }.to raise_error(EOFError)
      end
    end
  end

  describe "float types" do
    include_examples "float type", :f32, 4, 1e-3
    include_examples "float type", :f64, 8, 1e-12
  end

  # ------------------------------------------------------------------
  # Raw bytes: write_bytes / read_bytes
  # ------------------------------------------------------------------

  describe "#write_bytes" do
    it "writes a string of bytes" do
      buffer.write_bytes("hello")
      expect(buffer.size).to eq(5)
      expect(buffer.cursor).to eq(5)
    end

    it "accepts empty string" do
      buffer.write_bytes("")
      expect(buffer.size).to eq(0)
      expect(buffer.cursor).to eq(0)
    end

    it "raises TypeError for non-string" do
      expect { buffer.write_bytes(123) }.to raise_error(TypeError)
    end

    it "returns self" do
      expect(buffer.write_bytes("data")).to equal(buffer)
    end

    it "handles binary data with null bytes" do
      data = "\x00\x01\x02\x00"
      buffer.write_bytes(data)
      buffer.rewind
      expect(buffer.read_bytes(data.bytesize)).to eq(data)
    end
  end

  describe "#read_bytes" do
    it "returns a string of the requested length" do
      buffer.write_bytes("hello")
      buffer.rewind
      expect(buffer.read_bytes(5)).to eq("hello")
    end

    it "raises EOFError if more bytes requested than available" do
      buffer.write_bytes("ab")
      buffer.rewind
      expect { buffer.read_bytes(3) }.to raise_error(EOFError)
    end

    it "returns an empty string when length zero" do
      buffer.write_bytes("x")
      buffer.rewind
      expect(buffer.read_bytes(0)).to eq("")
      expect(buffer.tell).to eq(0) # cursor unchanged
    end

    it "advances cursor by length" do
      buffer.write_bytes("12345")
      buffer.rewind
      buffer.read_bytes(3)
      expect(buffer.tell).to eq(3)
      expect(buffer.remaining).to eq(2)
    end

    it "raises EOFError on empty buffer" do
      expect { buffer.read_bytes(1) }.to raise_error(EOFError)
    end
  end

  # ------------------------------------------------------------------
  # Prefixed strings: write_string / read_string
  # ------------------------------------------------------------------

  describe "#write_string" do
    it "prepends 4-byte length" do
      buffer.write_string("hello")
      expect(buffer.size).to eq(4 + 5)
    end

    it "writes empty string with zero length" do
      buffer.write_string("")
      expect(buffer.size).to eq(4)
      buffer.rewind
      expect(buffer.read_string).to eq("")
    end

    it "returns self" do
      expect(buffer.write_string("x")).to equal(buffer)
    end

    it "raises TypeError for non-string" do
      expect { buffer.write_string(123) }.to raise_error(TypeError)
    end
  end

  describe "#read_string" do
    it "returns the written string" do
      buffer.write_string("Hikari")
      buffer.rewind
      expect(buffer.read_string).to eq("Hikari")
    end

    it "handles empty string" do
      buffer.write_string("")
      buffer.rewind
      expect(buffer.read_string).to eq("")
      expect(buffer.remaining).to eq(0)
    end

    it "preserves UTF-8 encoding" do
      text = "こんにちは世界 🌸"
      buffer.write_string(text)
      buffer.rewind
      result = buffer.read_string
      expect(result).to eq(text)
      expect(result.encoding).to eq(Encoding::UTF_8)
    end

    it "raises EOFError when no length prefix available" do
      expect { buffer.read_string }.to raise_error(EOFError)
    end

    it "raises EOFError when payload is truncated" do
      buffer.write_u8(0)
      buffer.rewind
      expect { buffer.read_string }.to raise_error(EOFError)
    end
  end

  # ------------------------------------------------------------------
  # Peek for all types (generic checks)
  # ------------------------------------------------------------------

  %i[u8 u16 u32 u64 i8 i16 i32 i64 f32 f64].each do |type|
    describe "peek_#{type}" do
      it "does not advance cursor" do
        buffer.send("write_#{type}", 1)
        buffer.rewind
        cursor_before = buffer.tell
        buffer.send("peek_#{type}")
        expect(buffer.tell).to eq(cursor_before)
      end

      it "returns the same value as read" do
        buffer.send("write_#{type}", 42)
        buffer.rewind
        peeked = buffer.send("peek_#{type}")
        read = buffer.send("read_#{type}")
        expect(peeked).to eq(read)
      end
    end
  end

  # ------------------------------------------------------------------
  # Error conditions & bounds checking
  # ------------------------------------------------------------------

  describe "error handling" do
    it "read_u8 raises EOFError on empty buffer" do
      expect { buffer.read_u8 }.to raise_error(EOFError)
    end

    it "peek_u8 raises EOFError on empty buffer" do
      expect { buffer.peek_u8 }.to raise_error(EOFError)
    end

    it "read_bytes raises EOFError on empty buffer" do
      expect { buffer.read_bytes(1) }.to raise_error(EOFError)
    end

    it "read_string raises EOFError on empty buffer" do
      expect { buffer.read_string }.to raise_error(EOFError)
    end

    it "peek_bool raises EOFError on empty buffer" do
      expect { buffer.peek_bool }.to raise_error(EOFError)
    end

    it "skip raises EOFError when offset exceeds remaining" do
      buffer.write_u32(123)
      buffer.rewind
      expect { buffer.skip(5) }.to raise_error(EOFError)
    end

    it "seek raises RangeError when position > size" do
      buffer.write_u32(123)
      expect { buffer.seek(5) }.to raise_error(RangeError)
    end

    it "write methods raise RangeError on out-of-range values" do
      expect { buffer.write_u8(256) }.to raise_error(RangeError)
    end
  end

  # ------------------------------------------------------------------
  # Buffer resizing and capacity behaviour
  # ------------------------------------------------------------------

  describe "capacity and resizing" do
    it "automatically grows when writing beyond initial capacity" do
      small_buffer = Hikari::Buffer.new(4)
      small_buffer.write_u32(0xFFFFFFFF)
      expect(small_buffer.capacity).to be >= 4
      small_buffer.write_u8(1)
      expect(small_buffer.capacity).to be >= 5
      expect(small_buffer.size).to eq(5)
      small_buffer.rewind
      expect(small_buffer.read_u32).to eq(0xFFFFFFFF)
      expect(small_buffer.read_u8).to eq(1)
    end

    it "preserves existing data after resize" do
      small_buffer = Hikari::Buffer.new(2)
      small_buffer.write_u32(123_456)
      small_buffer.rewind
      expect(small_buffer.read_u32).to eq(123_456)
    end

    it "grows to accommodate multiple large writes" do
      buf = Hikari::Buffer.new(1)
      data = "X" * 10_000
      buf.write_bytes(data)
      expect(buf.size).to eq(10_000)
      buf.rewind
      expect(buf.read_bytes(10_000)).to eq(data)
    end

    # Growth invariants (multiple resizes)
    it "preserves data through many reallocations" do
      buf = Hikari::Buffer.new(4) # small initial
      1000.times { |i| buf.write_u32(i) }
      buf.rewind
      1000.times do |i|
        expect(buf.read_u32).to eq(i)
      end
      expect(buf.remaining).to eq(0)
    end

    # Capacity invariants
    it "always has capacity >= size" do
      buf = Hikari::Buffer.new(1)
      50.times do |i|
        buf.write_u8(i % 256)
        expect(buf.capacity).to be >= buf.size
      end
    end

    # Empty string after resize
    it "handles empty string after resize without corruption" do
      buf = Hikari::Buffer.new(1)
      big = "x" * 10_000
      buf.write_bytes(big) # force resize
      buf.clear
      buf.write_string("")
      buf.write_u32(42)
      buf.rewind
      expect(buf.read_string).to eq("")
      expect(buf.read_u32).to eq(42)
    end
  end

  # ------------------------------------------------------------------
  # Method chaining
  # ------------------------------------------------------------------

  describe "method chaining" do
    it "allows chaining writes" do
      result = buffer
               .write_u8(1)
               .write_i16(-2)
               .write_bool(true)
               .write_string("chained")
               .write_bytes("\xFF\xFE")
               .write_f64(3.14)
      expect(result).to equal(buffer)
    end

    it "chained writes produce correct data" do
      buffer
        .write_u8(255)
        .write_i32(-999)
        .write_string("test")
        .write_f32(2.718)

      buffer.rewind
      expect(buffer.read_u8).to eq(255)
      expect(buffer.read_i32).to eq(-999)
      expect(buffer.read_string).to eq("test")
      expect(buffer.read_f32).to be_within(1e-6).of(2.718)
      expect(buffer.remaining).to eq(0)
    end
  end

  # ------------------------------------------------------------------
  # Cursor state integrity
  # ------------------------------------------------------------------

  describe "cursor state consistency" do
    it "write moves cursor to end, read advances forward" do
      buffer.write_u32(0xDEADBEEF)
      expect(buffer.cursor).to eq(4)
      buffer.rewind
      buffer.read_u16
      expect(buffer.cursor).to eq(2)
      buffer.read_u16
      expect(buffer.cursor).to eq(4)
      expect(buffer.remaining).to eq(0)
    end

    it "seek + skip + peek interplay" do
      buffer.write_bytes("abcdefgh")
      buffer.rewind

      buffer.seek(3)
      expect(buffer.peek_u8).to eq("d".ord)
      buffer.skip(2) # skip 'd' and 'e' -> cursor = 5
      expect(buffer.read_u8).to eq("f".ord) # reads 'f'
      expect(buffer.remaining).to eq(2) # 'g','h'
    end

    it "after clear, cursor and size are zero, writes resume from start" do
      buffer.write_u64(123)
      buffer.clear
      expect(buffer.size).to eq(0)
      expect(buffer.cursor).to eq(0)
      buffer.write_u8(9)
      expect(buffer.size).to eq(1)
      buffer.rewind
      expect(buffer.read_u8).to eq(9)
    end

    it "after rewind, cursor is zero but size remains" do
      buffer.write_u16(0xAABB)
      buffer.rewind
      expect(buffer.cursor).to eq(0)
      expect(buffer.size).to eq(2)
      expect(buffer.remaining).to eq(2)
      buffer.read_u16
      expect(buffer.remaining).to eq(0)
    end

    # Cursor invariants
    it "remaining equals size - cursor after every operation" do
      ops = [
        -> { buffer.write_u32(123) },
        -> { buffer.rewind },
        -> { buffer.read_u16 },
        -> { buffer.seek(0) },
        -> { buffer.skip(2) },
        -> { buffer.write_bool(true) },
        -> { buffer.clear },
        -> { buffer.write_string("a") },
        -> { buffer.rewind },
        -> { buffer.read_string }
      ]

      ops.each do |op|
        op.call
        expect(buffer.remaining).to eq(buffer.size - buffer.cursor)
      end
    end
  end

  # ------------------------------------------------------------------
  # Randomized round-trip tests
  # ------------------------------------------------------------------

  describe "randomized round-trip" do
    it "u32 random values survive" do
      1000.times do
        val = rand(0..0xFFFFFFFF)
        buffer.clear
        buffer.write_u32(val)
        buffer.rewind
        expect(buffer.read_u32).to eq(val)
      end
    end

    it "i32 random values survive" do
      1000.times do
        val = rand(-2_147_483_648..2_147_483_647)
        buffer.clear
        buffer.write_i32(val)
        buffer.rewind
        expect(buffer.read_i32).to eq(val)
      end
    end

    it "f32 random values survive" do
      1000.times do
        val = rand(-1e6..1e6).to_f
        buffer.clear
        buffer.write_f32(val)
        buffer.rewind
        expect(buffer.read_f32).to be_within(1e-6 * [1.0, val.abs].max).of(val)
      end
    end

    it "f64 random values survive" do
      1000.times do
        val = rand(-1e12..1e12).to_f
        buffer.clear
        buffer.write_f64(val)
        buffer.rewind
        expect(buffer.read_f64).to be_within(1e-12 * [1.0, val.abs].max).of(val)
      end
    end

    it "bool random values survive" do
      1000.times do
        val = [true, false].sample
        buffer.clear
        buffer.write_bool(val)
        buffer.rewind
        expect(buffer.read_bool).to eq(val)
      end
    end
  end

  # ------------------------------------------------------------------
  # Binary string with every byte (0..255)
  # ------------------------------------------------------------------

  describe "binary string round-trip (every byte)" do
    it "handles all 256 byte values" do
      bytes = Array(0..255).pack("C*")
      buffer.write_bytes(bytes)
      buffer.rewind
      expect(buffer.read_bytes(bytes.bytesize)).to eq(bytes)
      expect(buffer.remaining).to eq(0)
    end
  end

  # ------------------------------------------------------------------
  # Fuzz test (random sequences of mixed operations)
  # ------------------------------------------------------------------

  describe "fuzz test" do
    it "round-trips a random sequence of writes" do
      buf = Hikari::Buffer.new
      log = [] # store [type, value] for each write

      # Generate a random sequence of writes
      500.times do
        type = %i[u8 u16 u32 u64 i8 i16 i32 i64 f32 f64 bool string bytes].sample
        case type
        when :u8
          val = rand(0..255)
          buf.write_u8(val)
          log << [:u8, val]
        when :u16
          val = rand(0..65_535)
          buf.write_u16(val)
          log << [:u16, val]
        when :u32
          val = rand(0..0xFFFFFFFF)
          buf.write_u32(val)
          log << [:u32, val]
        when :u64
          val = rand(0..0xFFFFFFFFFFFFFFFF)
          buf.write_u64(val)
          log << [:u64, val]
        when :i8
          val = rand(-128..127)
          buf.write_i8(val)
          log << [:i8, val]
        when :i16
          val = rand(-32_768..32_767)
          buf.write_i16(val)
          log << [:i16, val]
        when :i32
          val = rand(-2_147_483_648..2_147_483_647)
          buf.write_i32(val)
          log << [:i32, val]
        when :i64
          val = rand(-9_223_372_036_854_775_808..9_223_372_036_854_775_807)
          buf.write_i64(val)
          log << [:i64, val]
        when :f32
          val = rand(-1e6..1e6).to_f
          buf.write_f32(val)
          log << [:f32, val]
        when :f64
          val = rand(-1e12..1e12).to_f
          buf.write_f64(val)
          log << [:f64, val]
        when :bool
          val = [true, false].sample
          buf.write_bool(val)
          log << [:bool, val]
        when :string
          val = (0...rand(0..30)).map { rand(32..126).chr }.join
          buf.write_string(val)
          log << [:string, val]
        when :bytes
          val = (0...rand(0..50)).map { rand(0..255).chr }.join
          buf.write_bytes(val)
          log << [:bytes, val]
        end
      end

      # Read back
      buf.rewind
      log.each do |type, expected|
        case type
        when :u8   then expect(buf.read_u8).to eq(expected)
        when :u16  then expect(buf.read_u16).to eq(expected)
        when :u32  then expect(buf.read_u32).to eq(expected)
        when :u64  then expect(buf.read_u64).to eq(expected)
        when :i8   then expect(buf.read_i8).to eq(expected)
        when :i16  then expect(buf.read_i16).to eq(expected)
        when :i32  then expect(buf.read_i32).to eq(expected)
        when :i64  then expect(buf.read_i64).to eq(expected)
        when :f32
          expect(buf.read_f32).to be_within(1e-6 * [1.0, expected.abs].max).of(expected)
        when :f64
          expect(buf.read_f64).to be_within(1e-12 * [1.0, expected.abs].max).of(expected)
        when :bool   then expect(buf.read_bool).to eq(expected)
        when :string then expect(buf.read_string).to eq(expected)
        when :bytes
          read = buf.read_bytes(expected.bytesize)
          expect(read).to eq(expected)
        end
      end

      expect(buf.remaining).to eq(0)
    end
  end
end
