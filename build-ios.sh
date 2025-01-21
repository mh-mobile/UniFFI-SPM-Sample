!/bin/bash

# Exit on error
set -e

# Build the dylib
cargo build

# Generate bindings
cargo run --bin uniffi-bindgen generate --library ./target/debug/libmobile.dylib --language swift --out-dir ./bindings

# Add targets and build
for TARGET in \
       aarch64-apple-ios \
       aarch64-apple-ios-sim \
       aarch64-apple-darwin
do
   rustup target add $TARGET
   cargo build --release --target=$TARGET
done

# Copy files to framework project
cp ./bindings/mobile.swift ./ios/src/Mobile/
cp ./bindings/mobileFFI.h ./ios/src/Mobile/
cp ./bindings/mobileFFI.modulemap ./bindings/module.modulemap

# Create XCFramework
rm -rf "ios/bin/MobileCore.xcframework"
xcodebuild -create-xcframework \
   -library  ./target/aarch64-apple-ios/release/libmobile.a -headers ./bindings \
   -library  ./target/aarch64-apple-ios-sim/release/libmobile.a -headers ./bindings \
   -library  ./target/aarch64-apple-darwin/release/libmobile.a -headers ./bindings \
   -output "ios/bin/MobileCore.xcframework"

# Cleanup
rm -rf bindings
