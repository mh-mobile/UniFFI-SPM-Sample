#!/bin/bash

# Exit on error
set -e

# Build the dylib
cargo build --release

# Generate bindings
cargo run --bin uniffi-bindgen generate --library ./target/release/libmobile.dylib --language swift --out-dir ./bindings

# Add targets and build
for TARGET in \
       aarch64-apple-ios \
       aarch64-apple-ios-sim \
       x86_64-apple-ios \
       aarch64-apple-darwin
do
   rustup target add $TARGET
   cargo build --release --target=$TARGET
done

# Copy files to framework project
cp ./bindings/mobile.swift ./ios/src/Mobile/
cp ./bindings/mobileFFI.h ./ios/src/Mobile/
cp ./bindings/mobileFFI.modulemap ./bindings/module.modulemap

# Create fat library for iOS Simulator (combining arm64 and x86_64)
mkdir -p ./target/ios-simulator-universal/release
lipo -create \
   ./target/aarch64-apple-ios-sim/release/libmobile.a \
   ./target/x86_64-apple-ios/release/libmobile.a \
   -output ./target/ios-simulator-universal/release/libmobile.a

# Create XCFramework
rm -rf "ios/bin/MobileCore.xcframework"
xcodebuild -create-xcframework \
   -library  ./target/aarch64-apple-ios/release/libmobile.a -headers ./bindings \
   -library  ./target/ios-simulator-universal/release/libmobile.a -headers ./bindings \
   -library  ./target/aarch64-apple-darwin/release/libmobile.a -headers ./bindings \
   -output "ios/bin/MobileCore.xcframework"

# Cleanup
rm -rf bindings
