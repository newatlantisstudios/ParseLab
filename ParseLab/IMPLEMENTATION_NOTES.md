# ParseLab Implementation Notes

This document contains technical notes regarding the implementation details of key features in ParseLab.

## Recent Feature Updates

### 1. Modular Toolbar System Implementation

#### Major Refactoring: Dynamic Toolbar Based on File Type
- **Problem**: When switching between different file types (e.g., CSV to JSON), the toolbar would not properly update, resulting in incorrect buttons being displayed.
- **Root Cause**: Multiple separate toolbar managers and hardcoded configurations led to inconsistent state when switching file types.
- **Solution**: 
  1. Created `ModularToolbarManager` class that dynamically configures the toolbar based on file type.
  2. Unified all file types under a single toolbar management system.
  3. Toolbar automatically configures itself with appropriate buttons:
     - JSON/YAML/TOML/INI files: validation, edit, text/tree mode selector, search
     - CSV files: validation, edit, search, table view
  4. Added extensive debug logging to track toolbar state changes.
  5. Removed the old `CSVToolbarManager` in favor of the unified modular approach.
  
#### Technical Implementation:
- `ModularToolbarManager` manages a single `ModernToolbar` instance
- Buttons are created once and reused across different configurations
- `configureForFileType(_:)` method handles all file type specific setups
- Proper cleanup ensures toolbar state doesn't persist between file types

### 2. Previous CSV Toolbar Issue (Now Fixed)
- **Problem**: Tree button would disappear when switching from CSV to JSON file.
- **Solution**: Resolved by implementing the modular toolbar system above.
  
### 2. CSV File Support

CSV files are now supported with both text and table view modes. The implementation includes:

- **CSVDocument**: Core class that stores CSV data with headers and rows
- **CSVTableViewController**: Provides Excel-like editing experience
- **CSVHighlighter**: Syntax highlighting for CSV in text view
- **CSVToolbarManager**: Dedicated toolbar management for CSV files
- Table view allows adding/removing rows and columns, direct cell editing

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

## CSV Support

### CSV Data Model

The CSV feature in ParseLab uses a simple but effective data model that consists of:

- `CSVDocument`: Core class that stores headers and rows with various utility methods for data manipulation
- `CSVParser`: Handles parsing CSV text into the structured document

The parser handles:
- Basic CSV parsing with commas as separators
- Quoted strings with escaped quotes
- Header rows
- Data validation

```swift
class CSVDocument {
    var headers: [String]
    var rows: [[String]]
    var filePath: URL?
    
    // Methods for data manipulation
    func getValue(row: Int, column: Int) -> String?
    func setValue(row: Int, column: Int, value: String) -> Bool
    func addRow(values: [String])
    func deleteRow(at index: Int) -> Bool
    func addColumn(header: String, defaultValue: String = "")
    func deleteColumn(at index: Int) -> Bool
    func toCSVString(delimiter: String = ",") -> String
}
```

### Table View Integration

A key feature of the CSV implementation is the dedicated table view for structured data editing:

- `CSVTableViewController`: Provides an Excel-like editing experience
- `CSVHeaderCell`: Custom cell for displaying column headers
- `CSVDataCell`: Interactive cell for editing CSV data values with proper validation

The table view allows for:
- Direct cell editing
- Adding/removing rows and columns
- Sorting by any column (ascending or descending)
- Exporting the data

### Text View Integration

CSV files can also be viewed and edited in text format with:

- Syntax highlighting via `CSVHighlighter`
- Preservation of CSV structure during text editing
- One-click conversion between text and table view modes

### Integration with the App

CSV files are identified through:

1. File extension detection (`.csv`)
2. Content-based heuristics when needed

The app provides:
- CSV-specific file handling in `ViewController+FileOperations.swift`
- Dedicated `ViewController+CSV.swift` extension for CSV-specific functionality
- UI updates to reflect CSV operations and table view integration
- Sample CSV files for testing (`sample-data.csv`)

### Limitations and Future Work

Current limitations of the CSV implementation:

1. Limited support for custom delimiters (currently comma-only)
2. No character set detection for international text
3. Limited cell formatting options

Future work includes:

1. Supporting different CSV dialects (TSV, semicolon-separated, etc.)
2. Adding advanced filtering and search capabilities
3. Supporting custom column width and row height
4. Implementing schema validation for CSV data
5. Adding conditional formatting for cells based on content