#!/bin/bash
# uninstall.sh - Uninstall the dprint assignment fixer plugin

echo "🗑️  Uninstalling dprint Assignment Fixer Plugin..."

# Remove the plugin file
if [ -f ~/.dprint/plugins/dprint_plugin_assignment_fixer.wasm ]; then
    rm ~/.dprint/plugins/dprint_plugin_assignment_fixer.wasm
    echo "✅ Plugin file removed"
else
    echo "⚠️  Plugin file not found"
fi

# Check if the plugins directory is empty and remove it
if [ -d ~/.dprint/plugins ] && [ -z "$(ls -A ~/.dprint/plugins)" ]; then
    rmdir ~/.dprint/plugins
    echo "✅ Empty plugins directory removed"
fi

# Check if the .dprint directory is empty and remove it
if [ -d ~/.dprint ] && [ -z "$(ls -A ~/.dprint)" ]; then
    rmdir ~/.dprint
    echo "✅ Empty .dprint directory removed"
fi

echo ""
echo "⚠️  Remember to remove the plugin from your dprint.json configuration file!"
echo ""
echo "🎉 Uninstallation complete!"
