# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About TÖVE

TÖVE is a C++/Lua vector graphics library for LÖVE (Love2D) that enables efficient animated SVG rendering. It combines C++ performance with Lua scripting and targets real-time graphics applications.

## Build System

TÖVE uses SCons (Python-based build system):
- **Build library**: `scons` (creates `tove/libTove.dylib` on macOS, `.so` on Linux, `.dll` on Windows)
- **Debug build**: `scons --tovedebug`
- **Static library**: `scons --static`
- **CPU optimization**: `scons --arch=sandybridge` or `scons --arch=haswell`
- **Hardware FP16**: `scons --f16c` (POSIX only)

Windows setup requires running `setup.bat` once to create demo symlinks.

## Running Demos

All demos require LÖVE2D and are run from project root:
- `love demos/hearts` - Procedural animation demo
- `love demos/blob` - Morphing blob animation
- `love demos/gradients` - Gradient rendering showcase
- `love demos/editor` - Interactive SVG editor

Demo structure: Each demo has `main.lua`, `conf.lua` (LÖVE config), and symlinked `tove/` and `assets/` folders.

## Architecture

### Core Components
- **src/cpp/**: C++ core library with FFI bindings
  - `interface/api.h` - C API definitions exported to Lua
  - `graphics.cpp` - Main graphics primitives
  - `mesh/` - Tessellation and triangulation
  - `gpux/` - GPU-accelerated rendering
  - `paint.cpp` - Colors, gradients, shaders
  - `path.cpp`, `subpath.cpp` - Vector path handling

### Lua Integration  
- **src/lua/main.lua**: Primary Lua API that generates `tove/init.lua`
- Uses FFI to bind C++ functions defined in `interface/api.h`
- Build system minifies and concatenates Lua files with `--!! include` directives

### Third-party Dependencies
- **NanoSVG**: SVG parsing and rasterization
- **Clipper**: Boolean path operations
- **polypartition**: Polygon tessellation
- **tinyxml2**: XML processing
- **fp16**: 16-bit floating point operations

### Rendering Pipeline
1. SVG/vector data parsed into path/subpath structures
2. Tessellation converts paths to triangle meshes
3. Multiple renderer backends: mesh, texture, GPU compute (gpux)
4. Real-time animation through curve morphing and paint interpolation

## Development Workflow

1. **C++ changes**: Modify sources, run `scons` to rebuild library
2. **Lua API changes**: Edit `src/lua/*.lua`, rebuild to regenerate `tove/init.lua`  
3. **Demo testing**: Use `love demos/<name>` to test changes
4. **API changes**: Update both `interface/api.h` (C) and corresponding Lua bindings

## Key Files for Understanding

- `SConstruct` - Build configuration and source file listing
- `src/lua/main.lua` - Lua API entry point
- `src/cpp/interface/api.h` - Complete C API surface
- `demos/hearts/main.lua` - Simple demo showing basic usage
- `docs/tutorials/Getting_Started.md` - Official getting started guide