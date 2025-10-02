# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

ngit-lib is a build system for creating XCFrameworks that bundle libgit2, libssh2, OpenSSL, and libcurl for iOS, macOS, Mac Catalyst, watchOS and tvOS platforms.

## Build Commands

### Primary Build Commands
- `make` - Build the default XCFramework with static libraries
- `make framework_static` - Full build creating static XCFramework for all platforms
- `make clean` - Clean all build artifacts in target directory and XCFramework

### Platform-Specific Build Commands
- `make build_ios` - Build for iOS ARM64
- `make build_macos` - Build for macOS x86_64
- `make build_macos_arm64` - Build for macOS ARM64
- `make build_macos_catalyst` - Build for Mac Catalyst x86_64
- `make build_macos_catalyst_arm64` - Build for Mac Catalyst ARM64
- `make build_sim` - Build for iOS Simulator x86_64
- `make build_sim_arm64` - Build for iOS Simulator ARM64

### Code Signing
- `make codesign` - Sign the XCFramework with the appropriate certificate

## Architecture

The build system follows a hierarchical structure:

1. **Makefile** (root) - Orchestrates the entire build process
   - Defines platform targets and SDK versions
   - Controls build order: OpenSSL → libssh2 → libgit2
   - Creates final XCFramework from platform-specific builds

2. **Build Scripts** (src/*/build-*.sh)
   - Each library has its own build script handling cross-compilation
   - Scripts manage platform-specific configurations and SDK settings
   - Handle CMake/configure invocations with appropriate flags

3. **Dependencies**
   - OpenSSL (1.1.1q) - Built first, provides crypto foundation
   - libssh2 (1.10.0) - Built second, depends on OpenSSL
   - libgit2 - Built last, depends on both OpenSSL and libssh2

4. **Output Structure**
   - Individual platform builds: `target/{platform}/libgit2static.a`
   - Combined universal binaries created via `lipo`
   - Final XCFramework: `libgit2.xcframework/`

## Key Implementation Details

- All builds target minimum deployment: iOS 13.1, macOS 14.0
- Static libraries are combined using `libtool` to bundle all dependencies
- Build scripts support verbose logging and parallel make jobs
- Bitcode can be disabled via `--disable-bitcode` flag
- Each platform build maintains its own isolated environment in `target/`

## Commit Style

Follow existing commit patterns - concise messages without emojis describing the change made.