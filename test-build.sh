#!/bin/bash
# test-build.sh - Test building the plugin

echo "🧪 Testing build..."

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "❌ Rust is not installed"
    exit 1
fi

# Check if wasm target is available
if ! rustup target list --installed | grep -q "wasm32-unknown-unknown"; then
    echo "📦 Installing wasm32-unknown-unknown target..."
    rustup target add wasm32-unknown-unknown
fi

# Try to build
echo "🔨 Building plugin..."
if cargo build --target wasm32-unknown-unknown; then
    echo "✅ Build successful!"
    echo ""
    echo "WASM file created at:"
    echo "target/wasm32-unknown-unknown/debug/dprint_plugin_assignment_fixer.wasm"
else
    echo "❌ Build failed"
    exit 1
fi
