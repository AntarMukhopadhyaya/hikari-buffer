# Hikari Buffer

[![Ruby](https://github.com/AntarMukhopadhyaya/hikari-buffer/actions/workflows/main.yml/badge.svg)](https://github.com/AntarMukhopadhyaya/hikari-buffer/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/hikari_buffer.svg)](https://badge.fury.io/rb/hikari_buffer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A fast, lightweight binary buffer for Ruby built as a native C extension. Hikari Buffer provides efficient serialization and deserialization of primitive data types, strings, and raw bytes through a clean, chainable API.

## Why Hikari Buffer?

Hikari Buffer is designed for applications that require efficient binary
serialization, such as network protocols, game development, file formats,
and custom binary data processing.

Implemented as a native C extension, it avoids much of the overhead of
pure Ruby implementations while exposing a simple Ruby API.

## Features

* 🚀 Native C extension for maximum performance
* 📦 Binary serialization and deserialization
* 🔢 Signed integers (`i8`, `i16`, `i32`, `i64`)
* 🔢 Unsigned integers (`u8`, `u16`, `u32`, `u64`)
* 🌊 Floating-point numbers (`f32`, `f64`)
* ✅ Boolean support
* 📝 UTF-8 string serialization
* 📄 Raw byte serialization
* 🎯 Cursor-based reading and writing
* 🔄 Automatic buffer growth
* 🧪 Comprehensive RSpec test suite

## Installation

### RubyGems

```bash
gem install hikari_buffer
```

### Bundler

```ruby
gem "hikari_buffer"
```

## Quick Start

```ruby
require "hikari_buffer"

buffer = Hikari::Buffer.new

buffer
  .write_u32(42)
  .write_bool(true)
  .write_f64(Math::PI)
  .write_string("Hello, Hikari!")

buffer.rewind

puts buffer.read_u32      # => 42
puts buffer.read_bool     # => true
puts buffer.read_f64      # => 3.141592653589793
puts buffer.read_string   # => "Hello, Hikari!"
```

### Method Chaining

All write operations return the buffer itself, allowing a fluent API.

```ruby
buffer
  .write_u8(255)
  .write_i32(-42)
  .write_f32(1.5)
  .write_bool(true)
  .write_string("Ruby")
```

This makes building binary packets concise and expressive.

## Supported Types

| Type   | Read | Write |
| ------ | :--: | :---: |
| u8     |   ✅  |   ✅   |
| u16    |   ✅  |   ✅   |
| u32    |   ✅  |   ✅   |
| u64    |   ✅  |   ✅   |
| i8     |   ✅  |   ✅   |
| i16    |   ✅  |   ✅   |
| i32    |   ✅  |   ✅   |
| i64    |   ✅  |   ✅   |
| f32    |   ✅  |   ✅   |
| f64    |   ✅  |   ✅   |
| bool   |   ✅  |   ✅   |
| bytes  |   ✅  |   ✅   |
| string |   ✅  |   ✅   |

## Buffer API

```ruby
buffer.capacity
buffer.size
buffer.cursor
buffer.tell
buffer.remaining

buffer.seek(position)
buffer.rewind
buffer.clear
```

## Development

Clone the repository and install dependencies:

```bash
git clone https://github.com/AntarMukhopadhyaya/hikari-buffer.git
cd hikari-buffer
bundle install
```

Compile the native extension:

```bash
bundle exec rake compile
```

Run the test suite:

```bash
bundle exec rspec
```

Run RuboCop:

```bash
bundle exec rubocop
```

## Roadmap

* [x] Primitive integer serialization
* [x] Floating-point serialization
* [x] Boolean serialization
* [x] String serialization
* [x] Raw byte serialization
* [x] Automatic buffer growth
* [x] Peek operations
* [x] Benchmarks
* [ ] Endianness support
* [ ] Array serialization
* [ ] UUID serialization
* [ ] Precompiled native gems for Windows, Linux, and macOS

## Contributing

Bug reports, feature requests, and pull requests are welcome.

If you'd like to contribute:

1. Fork the repository
2. Create a feature branch
3. Add tests for your changes
4. Ensure all tests pass
5. Open a Pull Request

## License

Released under the MIT License. See the `LICENSE` file for details.
