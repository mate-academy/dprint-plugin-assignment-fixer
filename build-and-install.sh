#!/bin/bash
# build-and-install.sh - Build and install the dprint assignment fixer plugin

set -e

echo "🔧 Building dprint Assignment Fixer Plugin..."

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "❌ Rust is not installed. Please install Rust first:"
    echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

# Check if wasm32-unknown-unknown target is installed
if ! rustup target list --installed | grep -q "wasm32-unknown-unknown"; then
    echo "📦 Installing wasm32-unknown-unknown target..."
    rustup target add wasm32-unknown-unknown
fi

# Build the plugin
echo "🔨 Building plugin in release mode..."
cargo build --release --target wasm32-unknown-unknown

# Create plugins directory
echo "📁 Creating plugins directory..."
mkdir -p ~/.dprint/plugins

# Copy the plugin
echo "📦 Installing plugin..."
cp target/wasm32-unknown-unknown/release/dprint_plugin_assignment_fixer.wasm ~/.dprint/plugins/

# Optional: Optimize with wasm-opt if available
if command -v wasm-opt &> /dev/null; then
    echo "🚀 Optimizing plugin with wasm-opt..."
    wasm-opt -O3 ~/.dprint/plugins/dprint_plugin_assignment_fixer.wasm \
        -o ~/.dprint/plugins/dprint_plugin_assignment_fixer_opt.wasm
    mv ~/.dprint/plugins/dprint_plugin_assignment_fixer_opt.wasm \
        ~/.dprint/plugins/dprint_plugin_assignment_fixer.wasm
fi

# Check if dprint is installed
if ! command -v dprint &> /dev/null; then
    echo "⚠️  Warning: dprint is not installed. Install it with:"
    echo "   curl -fsSL https://dprint.dev/install.sh | sh"
else
    echo "✅ Plugin installed successfully!"
    echo ""
    echo "📝 Add this to your dprint.json plugins array:"
    echo '   "~/.dprint/plugins/dprint_plugin_assignment_fixer.wasm"'
    echo ""
    echo "Make sure it comes AFTER the TypeScript plugin in the array."
fi

# Run tests if test file exists
if [ -f "test-assignment-fixer.ts" ]; then
    echo ""
    echo "🧪 Running test file..."
    if command -v dprint &> /dev/null; then
        dprint fmt test-assignment-fixer.ts
        echo "✅ Test completed! Check test-assignment-fixer.ts for results."
    fi
fi

echo ""
echo "🎉 Build and installation complete!"
