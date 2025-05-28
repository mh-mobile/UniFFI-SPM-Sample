# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rust-based mobile library project using UniFFI to generate Swift bindings for iOS/macOS applications. The library provides:
- A Calculator class with basic arithmetic operations
- JWT decoding functionality with error handling
- Cross-platform support for iOS, iOS Simulator, and macOS

## Build Commands

### Build Everything for iOS/macOS
```bash
./build-ios.sh
```
This script:
1. Builds the Rust library in release mode
2. Generates Swift bindings using UniFFI
3. Builds for all Apple platforms (iOS, iOS Simulator, macOS)
4. Creates an XCFramework containing all architectures
5. Copies generated Swift files to the appropriate location

### Build Rust Library Only
```bash
cargo build --release
```

### Run Tests
```bash
cargo test
```

### Generate Swift Bindings Manually
```bash
cargo run --bin uniffi-bindgen generate --library ./target/release/libmobile.dylib --language swift --out-dir ./bindings
```

## Architecture

### Core Components

1. **Rust Library (`src/lib.rs`)**: Contains the main functionality
   - `Calculator`: Thread-safe calculator with Arc<Mutex> pattern
   - `say_hi()`: Simple greeting function
   - `decode_jwt()`: JWT decoder with comprehensive error handling
   - UniFFI annotations for Swift binding generation

2. **Build System**:
   - Uses UniFFI's attribute macro system (no UDL files required)
   - Builds static libraries for multiple Apple architectures
   - Creates XCFramework for distribution

3. **Swift Package**: Defined in `Package.swift`
   - Binary target pointing to XCFramework
   - Swift wrapper target in `ios/src/Mobile/`

### Key Patterns

- **Thread Safety**: Calculator uses `Arc<Mutex<T>>` for thread-safe state management
- **Error Handling**: Custom `JwtError` enum with `#[uniffi::Error]` for Swift interop
- **Object Lifecycle**: UniFFI handles memory management between Rust and Swift

### iOS Integration Examples

1. **SwiftUI with ObservableObject** (`HelloWorldSample`): Wraps the Rust Calculator in an ObservableObject for reactive UI updates
2. **Direct Function Calls** (`JwtViewerSample`): Calls Rust functions directly and handles errors in Swift
3. **CLI Usage** (`SwiftCLI`): Simple command-line tool using the library

## Development Notes

- The `mobile.swift` file in `ios/src/Mobile/` is auto-generated - do not edit manually
- XCFramework is gitignored as it's built from source
- All Rust types exposed to Swift must have UniFFI annotations
- Test your Rust code before building for iOS to catch errors early