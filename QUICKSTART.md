# Quick Start Guide

## 1. Prerequisites

Make sure you have Rust and dprint installed:

```bash
# Install Rust (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Install dprint (if not already installed)
curl -fsSL https://dprint.dev/install.sh | sh
```

## 2. Build and Install

The easiest way:

```bash
cd /Users/yuriiholiuk/mate/dprint-plugin-assignment-fixer
./build-and-install.sh
```

Or using Make:

```bash
cd /Users/yuriiholiuk/mate/dprint-plugin-assignment-fixer
make install
```

## 3. Configure Your Project

Add to your project's `dprint.json`:

```json
{
  "plugins": [
    "https://plugins.dprint.dev/typescript-0.91.1.wasm",
    "~/.dprint/plugins/dprint_plugin_assignment_fixer.wasm"
  ]
}
```

## 4. Test It

```bash
# Format the test file to see the plugin in action
dprint fmt test-assignment-fixer.ts

# Or format your entire project
dprint fmt
```

## Common Issues

1. **Rust not found**: Install Rust from https://rustup.rs
2. **wasm32 target missing**: Run `rustup target add wasm32-unknown-unknown`
3. **Plugin not working**: Make sure it's listed AFTER the TypeScript plugin in dprint.json

## Uninstall

```bash
./uninstall.sh
# or
make uninstall
```
