use dprint_core::configuration::{
    ConfigKeyMap, GlobalConfiguration,
    get_value, get_unknown_property_diagnostics
};
use dprint_core::plugins::{
    PluginInfo, SyncPluginHandler, PluginResolveConfigurationResult,
    SyncFormatRequest, SyncHostFormatRequest, FormatResult,
    CheckConfigUpdatesMessage, ConfigChange, FileMatchingInfo
};
#[cfg(target_arch = "wasm32")]
use dprint_core::generate_plugin_code;
use serde::{Deserialize, Serialize};
use regex::{Regex, Captures};
use anyhow::Result;

#[derive(Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct Configuration {
    /// Maximum line length before wrapping in parentheses
    #[serde(default = "default_line_width")]
    line_width: u32,
    
    /// Whether to wrap long assignments in parentheses
    #[serde(default = "default_wrap_in_parens")]
    wrap_long_assignments: bool,
    
    /// Indent width for wrapped expressions
    #[serde(default = "default_indent_width")]
    indent_width: u32,
}

fn default_line_width() -> u32 { 80 }
fn default_wrap_in_parens() -> bool { true }
fn default_indent_width() -> u32 { 2 }

impl Default for Configuration {
    fn default() -> Self {
        Self {
            line_width: default_line_width(),
            wrap_long_assignments: default_wrap_in_parens(),
            indent_width: default_indent_width(),
        }
    }
}

pub struct AssignmentFixerPlugin;

impl AssignmentFixerPlugin {
    #[allow(dead_code)]
    const fn new() -> Self {
        AssignmentFixerPlugin
    }
}

impl SyncPluginHandler<Configuration> for AssignmentFixerPlugin {
    fn plugin_info(&mut self) -> PluginInfo {
        PluginInfo {
            name: "dprint-plugin-assignment-fixer".to_string(),
            version: env!("CARGO_PKG_VERSION").to_string(),
            config_key: "assignmentFixer".to_string(),
            help_url: "https://github.com/yourusername/dprint-plugin-assignment-fixer".to_string(),
            config_schema_url: "".to_string(),
            update_url: None,
        }
    }

    fn resolve_config(
        &mut self,
        mut config: ConfigKeyMap,
        global_config: &GlobalConfiguration,
    ) -> PluginResolveConfigurationResult<Configuration> {
        let mut diagnostics = Vec::new();
        
        let line_width = get_value(
            &mut config,
            "lineWidth",
            global_config.line_width.unwrap_or(default_line_width()),
            &mut diagnostics
        );
        
        let indent_width = get_value(
            &mut config,
            "indentWidth",
            global_config.indent_width.unwrap_or(default_indent_width() as u8) as u32,
            &mut diagnostics
        );
        
        let wrap_long_assignments = get_value(
            &mut config,
            "wrapLongAssignments",
            default_wrap_in_parens(),
            &mut diagnostics
        );
        
        diagnostics.extend(get_unknown_property_diagnostics(config));
        
        PluginResolveConfigurationResult {
            config: Configuration {
                line_width,
                wrap_long_assignments,
                indent_width,
            },
            diagnostics,
            file_matching: FileMatchingInfo {
                file_extensions: vec!["ts", "tsx", "js", "jsx", "mjs", "cjs"]
                    .into_iter()
                    .map(String::from)
                    .collect(),
                file_names: vec![],
            },
        }
    }

    fn format(
        &mut self,
        request: SyncFormatRequest<Configuration>,
        _format_with_host: impl FnMut(SyncHostFormatRequest) -> FormatResult,
    ) -> Result<Option<Vec<u8>>> {
        let file_text = String::from_utf8(request.file_bytes.to_vec())
            .map_err(|e| anyhow::anyhow!("Invalid UTF-8 in file: {}", e))?;
        
        let result = fix_assignments(&file_text, request.config);
        
        // Only return Some if we actually made changes
        if result == file_text {
            Ok(None)
        } else {
            Ok(Some(result.into_bytes()))
        }
    }
    
    fn license_text(&mut self) -> String {
        std::include_str!("../LICENSE").to_string()
    }
    
    fn check_config_updates(&self, _message: CheckConfigUpdatesMessage) -> Result<Vec<ConfigChange>> {
        // No config updates to check
        Ok(vec![])
    }
}

fn fix_assignments(text: &str, config: &Configuration) -> String {
    let mut result = text.to_string();
    
    // Fix assignments that were broken across lines
    result = fix_broken_assignments(&result, config);
    
    // Fix method chaining with assignments
    result = fix_method_chain_assignments(&result, config);
    
    // Fix destructuring assignments
    result = fix_destructuring_assignments(&result, config);
    
    result
}

fn fix_broken_assignments(text: &str, config: &Configuration) -> String {
    // Pattern to match assignments broken across lines
    // Captures: (indent)(left_side)(operator_line)(right_side)
    let assignment_regex = Regex::new(
        r"(?m)^(\s*)([^=\n]+?)\s*\n\s*(=)\s*\n?\s*([^\n]+)"
    ).unwrap();
    
    assignment_regex.replace_all(text, |caps: &Captures| {
        let indent = &caps[1];
        let left_side = caps[2].trim();
        let right_side = caps[4].trim();
        
        // Check if this is an object property (but not destructuring)
        if is_object_property(left_side) && !is_destructuring(left_side) {
            // Keep the original formatting for object properties
            return caps[0].to_string();
        }
        
        // Check if it's a variable declaration
        let _is_declaration = left_side.starts_with("const ") || 
                           left_side.starts_with("let ") || 
                           left_side.starts_with("var ");
        
        // Calculate the combined line length
        let combined_length = indent.len() + left_side.len() + 3 + right_side.len(); // +3 for " = "
        
        if combined_length <= config.line_width as usize {
            // Put on same line
            format!("{}{} = {}", indent, left_side, right_side)
        } else if config.wrap_long_assignments && !right_side.starts_with('(') {
            // Wrap in parentheses
            let inner_indent = " ".repeat(indent.len() + config.indent_width as usize);
            format!("{}{} = (\n{}{}\n{})", 
                indent, 
                left_side, 
                inner_indent, 
                right_side,
                indent
            )
        } else {
            // Keep original formatting
            caps[0].to_string()
        }
    }).to_string()
}

fn fix_method_chain_assignments(text: &str, config: &Configuration) -> String {
    // Pattern for method chains after assignment
    let method_chain_regex = Regex::new(
        r"(?m)^(\s*)(\w+)\s*=\s*\n\s*([a-zA-Z_$][\w$]*(?:\.[a-zA-Z_$][\w$]*(?:\([^)]*\))?)+)"
    ).unwrap();
    
    method_chain_regex.replace_all(text, |caps: &Captures| {
        let indent = &caps[1];
        let variable = &caps[2];
        let method_chain = &caps[3];
        
        let combined_length = indent.len() + variable.len() + 3 + method_chain.len();
        
        if combined_length <= config.line_width as usize {
            format!("{}{} = {}", indent, variable, method_chain)
        } else {
            // Keep method chain on next line but consider parentheses
            if config.wrap_long_assignments {
                let inner_indent = " ".repeat(indent.len() + config.indent_width as usize);
                format!("{}{} = (\n{}{}\n{})", 
                    indent, 
                    variable, 
                    inner_indent, 
                    method_chain,
                    indent
                )
            } else {
                caps[0].to_string()
            }
        }
    }).to_string()
}

fn fix_destructuring_assignments(text: &str, _config: &Configuration) -> String {
    // Pattern for destructuring assignments (including those broken across lines)
    // This handles both same-line and multi-line destructuring assignments
    let destructuring_regex = Regex::new(
        r"(?m)^(\s*)((?:const|let|var)\s+)?(\{[^}]+\}|\[[^\]]+\])\s*\n?\s*=\s*\n?\s*(.+)$"
    ).unwrap();
    
    destructuring_regex.replace_all(text, |caps: &Captures| {
        let indent = &caps[1];
        let decl_keyword = caps.get(2).map(|m| m.as_str()).unwrap_or("");
        let pattern = &caps[3];
        let value = &caps[4];
        
        // Always wrap destructuring variable declarations in parentheses
        if !decl_keyword.is_empty() {
            format!("{}({}{} = {})", indent, decl_keyword, pattern, value.trim())
        } else {
            // For non-declarations, check if we need parentheses
            format!("{}({} = {})", indent, pattern, value.trim())
        }
    }).to_string()
}

fn is_destructuring(text: &str) -> bool {
    let trimmed = text.trim();
    // Remove variable declaration keywords
    let without_decl = if trimmed.starts_with("const ") {
        trimmed.strip_prefix("const ").unwrap().trim()
    } else if trimmed.starts_with("let ") {
        trimmed.strip_prefix("let ").unwrap().trim()
    } else if trimmed.starts_with("var ") {
        trimmed.strip_prefix("var ").unwrap().trim()
    } else {
        trimmed
    };
    
    (without_decl.starts_with('{') && without_decl.ends_with('}')) ||
    (without_decl.starts_with('[') && without_decl.ends_with(']'))
}

fn is_object_property(text: &str) -> bool {
    // Simple check if this looks like an object property (contains a colon)
    text.contains(':') && !text.contains("?")
}

// Generate the plugin code
#[cfg(target_arch = "wasm32")]
generate_plugin_code!(AssignmentFixerPlugin, AssignmentFixerPlugin::new());

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_simple_assignment_fix() {
        let config = Configuration::default();
        let input = "const x\n=\n42";
        let expected = "const x = 42";
        assert_eq!(fix_assignments(input, &config), expected);
    }

    #[test]
    fn test_long_assignment_wrap() {
        let config = Configuration {
            line_width: 20,
            wrap_long_assignments: true,
            indent_width: 2,
        };
        let input = "const veryLongVariable\n=\nsomeVeryLongExpression";
        let expected = "const veryLongVariable = (\n  someVeryLongExpression\n)";
        assert_eq!(fix_assignments(input, &config), expected);
    }

    #[test]
    fn test_destructuring_preserved() {
        let config = Configuration::default();
        let input = "const { a, b }\n=\nobject";
        let expected = "(const { a, b } = object)";
        assert_eq!(fix_assignments(input, &config), expected);
    }

    #[test]
    fn test_method_chain() {
        let config = Configuration::default();
        let input = "  const result\n  =\n  object.method().chain()";
        let expected = "  const result = object.method().chain()";
        assert_eq!(fix_assignments(input, &config), expected);
    }
}
