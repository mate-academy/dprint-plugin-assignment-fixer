# Makefile for dprint Assignment Fixer Plugin

PLUGIN_NAME = dprint_plugin_assignment_fixer
WASM_FILE = $(PLUGIN_NAME).wasm
TARGET = wasm32-unknown-unknown
RELEASE_DIR = target/$(TARGET)/release
INSTALL_DIR = ~/.dprint/plugins

.PHONY: all build install test clean uninstall help

# Default target
all: build install

# Build the plugin
build:
	@echo "🔨 Building plugin..."
	@cargo build --release --target $(TARGET)
	@echo "✅ Build complete!"

# Install the plugin
install: build
	@echo "📦 Installing plugin..."
	@mkdir -p $(INSTALL_DIR)
	@cp $(RELEASE_DIR)/$(WASM_FILE) $(INSTALL_DIR)/
	@echo "✅ Plugin installed to $(INSTALL_DIR)/$(WASM_FILE)"

# Optimize the plugin (requires wasm-opt)
optimize: install
	@if command -v wasm-opt >/dev/null 2>&1; then \
		echo "🚀 Optimizing plugin..."; \
		wasm-opt -O3 $(INSTALL_DIR)/$(WASM_FILE) -o $(INSTALL_DIR)/$(WASM_FILE).opt; \
		mv $(INSTALL_DIR)/$(WASM_FILE).opt $(INSTALL_DIR)/$(WASM_FILE); \
		echo "✅ Optimization complete!"; \
	else \
		echo "⚠️  wasm-opt not found. Install with: npm install -g wasm-opt"; \
	fi

# Run tests
test:
	@echo "🧪 Running tests..."
	@cargo test
	@if [ -f test-assignment-fixer.ts ] && command -v dprint >/dev/null 2>&1; then \
		echo "🧪 Testing with dprint..."; \
		dprint fmt test-assignment-fixer.ts; \
	fi

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@cargo clean
	@echo "✅ Clean complete!"

# Uninstall the plugin
uninstall:
	@echo "🗑️  Uninstalling plugin..."
	@rm -f $(INSTALL_DIR)/$(WASM_FILE)
	@if [ -d $(INSTALL_DIR) ] && [ -z "$$(ls -A $(INSTALL_DIR))" ]; then \
		rmdir $(INSTALL_DIR); \
	fi
	@if [ -d ~/.dprint ] && [ -z "$$(ls -A ~/.dprint)" ]; then \
		rmdir ~/.dprint; \
	fi
	@echo "✅ Plugin uninstalled!"

# Development build (faster, larger file)
dev:
	@echo "🔧 Building plugin (dev mode)..."
	@cargo build --target $(TARGET)
	@cp target/$(TARGET)/debug/$(WASM_FILE) $(INSTALL_DIR)/
	@echo "✅ Dev build installed!"

# Check dependencies
check-deps:
	@echo "🔍 Checking dependencies..."
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "❌ Rust not installed. Install from https://rustup.rs"; \
		exit 1; \
	fi
	@if ! rustup target list --installed | grep -q $(TARGET); then \
		echo "📦 Installing $(TARGET) target..."; \
		rustup target add $(TARGET); \
	fi
	@if ! command -v dprint >/dev/null 2>&1; then \
		echo "⚠️  dprint not installed. Install from https://dprint.dev"; \
	fi
	@echo "✅ All dependencies satisfied!"

# Help
help:
	@echo "dprint Assignment Fixer Plugin - Makefile targets:"
	@echo ""
	@echo "  make build      - Build the plugin"
	@echo "  make install    - Build and install the plugin"
	@echo "  make optimize   - Optimize the installed plugin (requires wasm-opt)"
	@echo "  make test       - Run tests"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make uninstall  - Uninstall the plugin"
	@echo "  make dev        - Build and install debug version"
	@echo "  make check-deps - Check and install dependencies"
	@echo "  make help       - Show this help message"
	@echo ""
	@echo "Default target (make): build and install"
