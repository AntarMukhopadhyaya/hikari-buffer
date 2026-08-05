# Hikari Buffer

[![Ruby](https://github.com/AntarMukhopadhyaya/hikari-buffer/actions/workflows/main.yml/badge.svg)](https://github.com/AntarMukhopadhyaya/hikari-buffer/actions/workflows/main.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A fast, lightweight binary buffer for Ruby built as a native C extension. Hikari Buffer provides efficient serialization and deserialization of primitive data types, strings, and raw bytes through a clean, chainable API.

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

puts buffer.read_u32
puts buffer.read_bool
puts buffer.read_f64
puts buffer.read_string
```

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
* [ ] Peek operations
* [ ] Endianness support
* [ ] Array serialization
* [ ] UUID serialization
* [ ] Benchmarks
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
