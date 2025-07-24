# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a dprint plugin written in Rust that fixes assignment operator formatting in TypeScript/JavaScript code. It's a WebAssembly-based post-processing plugin that runs after the TypeScript dprint plugin to ensure assignment operators aren't split across lines.

## Development Commands

### Building
```bash
# Build the plugin (creates target/wasm32-unknown-unknown/release/dprint_plugin_assignment_fixer.wasm)
make build

# Build and install to ~/.dprint/plugins/
make install

# Build with optimizations
make optimize
```

### Testing
```bash
# Run all tests
make test

# Run tests with output
cargo test -- --nocapture

# Test specific functionality
cargo test test_name
```

### Development Workflow
```bash
# Clean build artifacts
make clean

# Uninstall the plugin
make uninstall
# or
./uninstall.sh
```

## Architecture

The plugin uses regex-based parsing (not full AST) to fix assignment formatting. Key architectural decisions:

1. **Core Logic** (`src/lib.rs`):
   - Implements `SyncPluginHandler` trait from dprint-core
   - Main function: `format_text()` - processes file content using regex patterns
   - Key patterns handled:
     - Simple assignments: `variable = value`
     - Method chain assignments: `object.method() = value`
     - Destructuring: `{ a, b } = object` or `[x, y] = array`

2. **Configuration Structure**:
   ```rust
   pub struct Configuration {
       pub line_width: u32,        // default: 80
       pub wrap_long_assignments: bool,  // default: true
       pub indent_width: u8,       // default: 2
   }
   ```

3. **Processing Flow**:
   - Receives formatted text from TypeScript plugin
   - Applies regex patterns to fix broken assignments
   - Optionally wraps long assignments in parentheses
   - Returns processed text

## Testing Patterns

When adding new functionality:
1. Add test cases to the test module in `src/lib.rs`
2. Use the pattern: create input string → process with `format_text()` → assert expected output
3. Test file `test-assignment-fixer.ts` contains real-world examples

## Integration with dprint

The plugin must be configured in `dprint.json`:
```json
{
  "plugins": [
    "https://plugins.dprint.dev/typescript-x.x.x.wasm",
    "file://~/.dprint/plugins/dprint_plugin_assignment_fixer.wasm"
  ],
  "assignmentFixer": {
    "lineWidth": 80,
    "wrapLongAssignments": true,
    "indentWidth": 2
  }
}
```

Note: Plugin must be listed AFTER the TypeScript plugin as it processes its output.