# TODO - TÖVE Love2D 12.0 Compatibility

This file tracks bugs, errors, and compatibility issues discovered while updating TÖVE to work with Love2D 12.0.

## Demo Compatibility Status

| Demo | Status | Issues | Priority |
|------|--------|--------|----------|
| alpha | ⚠️ Issues | Deprecation warnings only | Medium |
| assets | ❌ Broken | Not a runnable demo (assets folder) | N/A |
| blob | ❌ Broken | Shader uniform size error, compute feed error | High |
| clippath | ⚠️ Issues | Deprecation warnings only | Medium |
| debug | ❌ Broken | Not a runnable demo (subfolder structure) | Low |
| editor | ❌ Broken | Shader uniform size error | High |
| fillrule | ❌ Broken | Shader uniform size error | Medium |
| gradients | ❌ Broken | Shader uniform size error | High |
| hearts | ❌ Broken | Shader uniform size error | High |
| morph | ❌ Broken | Shader uniform size error | Medium |
| renderers | ❌ Broken | Shader uniform size error | High |
| retro | ⚠️ Issues | Deprecation warnings only | Medium |
| shaders | ❌ Broken | Shader uniform size error | High |
| tesselation | ⚠️ Issues | Deprecation warnings only | Medium |
| warp | ⚠️ Issues | Deprecation warnings only | Medium |
| zoom | ❌ Broken | Shader uniform size error | Medium |

Legend: ✅ Working | ⚠️ Issues | ❌ Broken | 🔍 Testing

**Summary:** 0 working, 5 with warnings only, 11 broken demos

## Known Issues

### Critical Shader Errors (High Priority)
**Error:** `Size (X) must be a multiple of the uniform's size in bytes (16)`
- **Files affected:** `tove/init.lua:2000`, `tove/init.lua:2075`
- **Demos broken:** blob, editor, fillrule, gradients, hearts, morph, renderers, shaders, zoom
- **Root cause:** Love2D 12.0 changed shader uniform alignment requirements
- **Fix needed:** Update shader uniform buffer sizes to be 16-byte aligned

### Deprecation Warnings (Medium Priority)
1. **Canvas/Texture API:** `love.graphics.getCanvasFormats` → `love.graphics.getTextureFormats`
2. **Require paths:** Forward slashes in require strings → use dots instead  
3. **Mesh vertex format:** Array values → named table fields with 'format' and 'location'
4. **Vertex attributes:** Missing 'location' layout qualifier in shader code
5. **Stencil functions:** `love.graphics.stencil` and `setStencilTest` → `setStencilMode`/`setStencilState`

### Structural Issues (Low Priority)
- **assets/debug folders:** Not proper demo directories, lack main.lua files
- Should be excluded from automated testing

### Compute Shader Issues (High Priority)
**Error:** `Size to copy must be greater than 0`
- **Location:** `tove/init.lua:2075` in `endInit` function
- **Affects:** blob demo (and likely others using compute features)
- **Cause:** Buffer size calculation issues with Love2D 12.0

## Fix Categories

### High Priority (11 demos broken)
1. **Shader uniform alignment errors** - Affects 9 demos
2. **Compute shader buffer issues** - Affects blob demo specifically
3. **Editor demo** - Main showcase, critical for project

### Medium Priority (5 demos with warnings only)
1. **Deprecation warnings** - Non-breaking but should be addressed
2. **API modernization** - Update to Love2D 12.0 standards
3. **Mesh/vertex format updates** - Replace deprecated patterns

### Low Priority
1. **Test script improvements** - Exclude non-demo folders
2. **Code cleanup** - Remove obsolete patterns
3. **Documentation updates** - Reflect Love2D 12.0 requirements

## Fix Implementation Plan

### Phase 1: Critical Shader Fixes
1. **Fix uniform buffer alignment** (`tove/init.lua:2000`, `tove/init.lua:2075`)
   - Ensure all uniform data is 16-byte aligned
   - Update buffer size calculations
2. **Fix compute shader issues** (`tove/init.lua:2075`)
   - Debug buffer size calculation in `endInit`
   - Ensure non-zero buffer sizes

### Phase 2: API Modernization  
1. **Update deprecated function calls**
   - Replace `getCanvasFormats` with `getTextureFormats`
   - Update stencil function calls
2. **Fix vertex format definitions**
   - Convert array format to named table fields
   - Add location qualifiers to shader attributes
3. **Update require statements**
   - Replace forward slashes with dots in require paths

### Phase 3: Testing & Validation
1. **Improve test script**
   - Filter out non-demo directories (assets, debug)
   - Add better error categorization
2. **Validate all fixes**
   - Re-run automated testing
   - Manual testing of complex demos (editor)

## Testing Notes

- Testing performed with Love2D 12.0 (Bestest Friend)
- Automated script tests each demo for 3 seconds
- 11/16 demos completely broken, 5/16 have warnings only
- Main issue: Shader uniform alignment changes in Love2D 12.0

## Files Requiring Updates

### Primary Target
- `src/lua/main.lua` - Source of `tove/init.lua` 
- Shader-related functions around lines 2000, 2075, 2362

### Secondary Targets
- Demo `main.lua` files - Fix require statements
- Shader code - Add location qualifiers