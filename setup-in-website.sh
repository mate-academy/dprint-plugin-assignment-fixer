#!/bin/bash

# Setup script for adding dprint-plugin-assignment-fixer to mate-academy/website

echo "Setup Instructions for mate-academy/website:"
echo "==========================================="
echo ""
echo "The dprint assignment fixer plugin has been successfully published to:"
echo "https://github.com/mate-academy/dprint-plugin-assignment-fixer"
echo ""
echo "Raw WASM URL for dprint.json:"
echo "https://raw.githubusercontent.com/mate-academy/dprint-plugin-assignment-fixer/main/dist/dprint_plugin_assignment_fixer.wasm"
echo ""
echo "To add this plugin to the website project, run these commands:"
echo ""
echo "1. Navigate to the website directory:"
echo "   cd /Users/yuriiholiuk/mate/website"
echo ""
echo "2. Create a new worktree for testing (optional but recommended):"
echo "   make worktree branch=feat/add-assignment-fixer-plugin folder=assignment-fixer-test"
echo ""
echo "3. Navigate to the worktree (if created):"
echo "   cd ../website-assignment-fixer-test"
echo ""
echo "4. Update dprint.json to add the plugin:"
echo "   Add the following to the 'plugins' array in dprint.json:"
echo '   "https://raw.githubusercontent.com/mate-academy/dprint-plugin-assignment-fixer/main/dist/dprint_plugin_assignment_fixer.wasm"'
echo ""
echo "   And add the configuration section:"
echo '   "assignmentFixer": {'
echo '     "lineWidth": 80,'
echo '     "wrapLongAssignments": true,'
echo '     "indentWidth": 2'
echo '   }'
echo ""
echo "5. Test the plugin:"
echo "   dprint check"
echo "   dprint fmt"
echo ""
echo "Note: The plugin should be placed AFTER the TypeScript plugin in the plugins array."
echo ""
echo "Example dprint.json structure:"
echo '{'
echo '  "plugins": ['
echo '    "https://plugins.dprint.dev/typescript-x.x.x.wasm",'
echo '    "https://raw.githubusercontent.com/mate-academy/dprint-plugin-assignment-fixer/main/dist/dprint_plugin_assignment_fixer.wasm"'
echo '  ],'
echo '  "assignmentFixer": {'
echo '    "lineWidth": 80,'
echo '    "wrapLongAssignments": true,'
echo '    "indentWidth": 2'
echo '  }'
echo '}'