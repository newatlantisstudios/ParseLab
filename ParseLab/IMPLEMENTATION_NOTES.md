# ParseLab Implementation Notes

This document contains technical notes regarding the implementation details of key features in ParseLab.

## TOML Support

### Manual TOML Parser

The TOML parser in ParseLab is implemented as a custom manual parser that doesn't rely on external dependencies. This approach was chosen because:

1. It provides better control over the parsing process
2. It ensures compatibility with the existing codebase
3. It avoids adding external dependencies that might not be maintained

The current implementation in `TOMLParser.swift` handles:

- Basic key-value pairs with various value types (string, number, boolean)
- Tables and nested tables
- Basic arrays
- Comments
- Simple date and time formats

```swift
private static func parseTOMLManually(_ tomlString: String) throws -> [String: Any] {
    var result: [String: Any] = [:]
    var currentTable: String? = nil
    
    // Process line by line
    let lines = tomlString.split(separator: "\n")
    for line in lines {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Skip comments and empty lines
        if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
            continue
        }
        
        // Check for table headers and key-value pairs
        // ... implementation details ...
    }
    
    return result
}
```

### TOML Syntax Highlighting

The syntax highlighter for TOML uses regular expressions to identify and color different elements:

- Table headers (`[section]`)
- Array headers (`[[array]]`)
- Key names
- String values
- Number values
- Boolean values
- Date and time values
- Comments

Each element type is assigned a specific color for visual distinction.

### Schema Validation

TOML schema validation works by:

1. Parsing the TOML content into a dictionary structure
2. Validating this structure against a JSON Schema
3. Using type mapping between TOML and JSON types:
   - TOML string → JSON string
   - TOML integer → JSON number
   - TOML float → JSON number
   - TOML boolean → JSON boolean
   - TOML datetime → JSON string with format validation
   - TOML array → JSON array
   - TOML table → JSON object

## Integration with the App

TOML files are identified through:

1. File extension detection (`.toml`)
2. Content-based heuristics for files without a clear extension

The app provides:

- TOML-specific file handling in `ViewController+FileOperations.swift`
- UI updates to reflect TOML-specific operations
- Sample TOML files for testing (`sample-config.toml`, `sample-person.toml`)
- Schema validation comparable to JSON validation

## Limitations and Future Work

Current limitations of the TOML implementation:

1. Limited support for complex nested structures
2. Incomplete support for all TOML data types and formats
3. Manual parsing may not handle all edge cases

Future work includes:

1. Potentially integrating with a maintained TOML library
2. Improving the parser to handle more complex TOML features
3. Adding more robust error handling and reporting
4. Enhancing the syntax highlighter for better visual distinction