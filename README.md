# dprint Assignment Fixer Plugin

A post-processing plugin for [dprint](https://dprint.dev) that fixes assignment operator formatting to prevent line breaks around `=` operators while preserving other formatting rules.

## Features

- ✅ Prevents line breaks around assignment operators (`=`)
- ✅ Wraps long assignments in parentheses when they exceed line width
- ✅ Preserves destructuring assignment formatting
- ✅ Handles method chaining correctly
- ✅ Works with TypeScript, JavaScript, JSX, and TSX files
- ✅ Configurable line width and indentation

## Requirements

- Rust (for building)
- dprint CLI
- wasm32-unknown-unknown target (`rustup target add wasm32-unknown-unknown`)

## Quick Start

### Option 1: Using Make

```bash
# Clone the repository
git clone <your-repo-url>
cd dprint-plugin-assignment-fixer

# Build and install
make install

# Or with optimization
make optimize
```

### Option 2: Using Shell Script

```bash
# Make the script executable
chmod +x build-and-install.sh

# Run it
./build-and-install.sh
```

### Option 3: Manual Build

```bash
# Build the plugin
cargo build --release --target wasm32-unknown-unknown

# Install it
mkdir -p ~/.dprint/plugins
cp target/wasm32-unknown-unknown/release/dprint_plugin_assignment_fixer.wasm ~/.dprint/plugins/
```

## Configuration

Add the plugin to your `dprint.json` **after** the TypeScript plugin:

```json
{
  "typescript": {
    "operatorPosition": "nextLine",
    "binaryExpression.operatorPosition": "nextLine"
  },
  "assignmentFixer": {
    "lineWidth": 80,
    "wrapLongAssignments": true,
    "indentWidth": 2
  },
  "plugins": [
    "https://plugins.dprint.dev/typescript-0.91.1.wasm",
    "~/.dprint/plugins/dprint_plugin_assignment_fixer.wasm"
  ]
}
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `lineWidth` | number | 80 | Maximum line length before wrapping |
| `wrapLongAssignments` | boolean | true | Wrap long assignments in parentheses |
| `indentWidth` | number | 2 | Spaces for indentation in wrapped expressions |

## Examples

### Before (dprint TypeScript plugin output):
```typescript
// Short assignment broken unnecessarily
const x
=
42;

// Long assignment without proper handling
const veryLongVariableName
=
veryLongExpressionThatExceedsLineWidth;

// Method chain assignment
const result
=
object
  .method()
  .chain();
```

### After (with Assignment Fixer plugin):
```typescript
// Short assignment on one line
const x = 42;

// Long assignment wrapped in parentheses
const veryLongVariableName = (
  veryLongExpressionThatExceedsLineWidth
);

// Method chain assignment fixed
const result = object
  .method()
  .chain();
```

## Testing

Run the test suite:
```bash
make test
```

Or test with a sample file:
```bash
dprint fmt test-assignment-fixer.ts
```

## Development

### Project Structure
```
dprint-plugin-assignment-fixer/
├── Cargo.toml              # Rust dependencies
├── src/
│   └── lib.rs             # Plugin implementation
├── test-assignment-fixer.ts # Test file
├── build-and-install.sh    # Build script
├── Makefile               # Make targets
└── README.md              # This file
```

### Making Changes

1. Edit `src/lib.rs`
2. Run `make test` to test your changes
3. Run `make install` to rebuild and install
4. Test with `dprint fmt` on your code

### Debugging

Enable debug output by adding `eprintln!` statements:
```rust
eprintln!("Debug: Processing assignment: {} = {}", left_side, right_side);
```

View output with:
```bash
dprint fmt --verbose 2>&1 | grep "Debug:"
```

## Uninstallation

Using Make:
```bash
make uninstall
```

Or manually:
```bash
rm ~/.dprint/plugins/dprint_plugin_assignment_fixer.wasm
```

## Known Limitations

- Regex-based parsing (not full AST analysis)
- May not handle all edge cases perfectly
- Requires TypeScript plugin to run first

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for your changes
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Troubleshooting

### Plugin not loading
- Check file path in dprint.json
- Ensure TypeScript plugin is listed first
- Run `dprint check --verbose` for errors

### Formatting not as expected
- Check your configuration options
- Use `dprint output-resolved-config` to verify settings
- Test with the provided test file

### Build errors
- Update Rust: `rustup update`
- Check wasm target: `rustup target list --installed`
- Verify dependencies in Cargo.toml
