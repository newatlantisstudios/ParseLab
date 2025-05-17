# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ParseLab is an iOS utility app for working with structured data formats, including:

- JSON (native support with full editing and JSON Schema validation)
- YAML (parsing, display, and syntax highlighting)
- TOML (parsing, display, validation, and JSON Schema validation)
- INI (parsing and display)
- XML (parsing, display, and syntax highlighting)
- PLIST (parsing, display, and support for both XML and binary formats)
- CSV (parsing with table view and text view)

The app offers multiple viewing modes (text view, tree view, and table view for CSV), syntax highlighting, JSON schema validation for JSON and TOML files, and path navigation for hierarchical data structures.

## Architecture

### Core Components

1. **Parsers**
   - `JSONParser` - Uses native `JSONSerialization` for JSON parsing
   - `YAMLParser` - Handles YAML parsing and conversion to JSON
   - `TOMLParser` - Manual TOML parser with JSON conversion
   - `INIParser` - Parses INI files to JSON structure
   - `XMLParser` - Parses XML files to JSON structure
   - `PLISTParser` - Handles PLIST files (both XML and binary) with JSON conversion
   - `CSVParser` - Handles CSV parsing and tabular data

2. **UI Components**
   - `ViewController` - Main view controller handling file display/editing
   - `JsonTreeViewController` - Tree view for structured data
   - `CSVTableViewController` - Table view for CSV data

3. **Syntax Highlighting**
   - `JSONHighlighter`, `YAMLHighlighter`, `TOMLHighlighter`, `INIHighlighter`, `XMLHighlighter`, `PLISTHighlighter`, `CSVHighlighter`

4. **Schema Validation**
   - `JSONSchemaValidator` - Validates JSON against JSON Schemas
   - `TOMLSchemaValidator` - Validates TOML against JSON Schemas

5. **File Management**
   - `RecentFilesManager` - Manages list of recently opened files
   - `FileMetadataManager` - Provides metadata for files

### Data Flow

1. File is loaded via open dialog, sample file, or external app
2. File type is detected based on extension and content
3. File is parsed into appropriate data structure
4. Content is displayed with syntax highlighting in text view
5. Alternative views (tree view, table view) are available based on file type
6. Navigation and editing functions operate on the parsed data structure

## Feature Notes

### TOML Support

The TOML parser is a custom implementation without external dependencies, handling:
- Basic key-value pairs
- Tables and nested tables
- Basic arrays
- Comments
- Basic date and time formats

### CSV Support

CSV files can be viewed and edited in both text and table modes:
- `CSVDocument` - Core class storing headers and rows
- `CSVTableViewController` - Provides Excel-like editing experience
- Table view allows for direct cell editing, adding/removing rows and columns

### XML Support

XML files are parsed and displayed with syntax highlighting:
- Converts XML to JSON structure for tree view navigation
- Full syntax highlighting with proper tag and attribute coloring
- Tree view support for hierarchical XML structure

### PLIST Support

PLIST files support both XML and binary formats:
- Automatic detection of binary vs XML PLIST format
- Binary PLISTs are converted to readable JSON for display
- XML PLISTs display with proper syntax highlighting
- Tree view support for navigating PLIST structure

## Development Workflow

### Build and Run

The app is built with Swift and UIKit:
1. Open `ParseLab.xcodeproj` in Xcode
2. Select a simulator or iOS device
3. Use Xcode's standard run command (⌘R)

#### Build Scripts

The project includes automated build scripts in the `Scripts` directory that use `xcbeautify` for clean output formatting and quiet mode builds:

- `all-scripts.sh` - Main script runner providing access to all other scripts
- `build.sh` - Build the project with options for debug/release and device/simulator
- `test.sh` - Run unit tests, UI tests, or all tests
- `run.sh` - Build and run on a specific simulator device
- `clean.sh` - Clean build artifacts with optional deep clean
- `archive.sh` - Create archives and export IPAs

Prerequisites:
```bash
brew install xcbeautify
```

Quick usage:
```bash
# First-time setup
./Scripts/all-scripts.sh setup

# Build for debug
./Scripts/all-scripts.sh build

# Build for release
./Scripts/all-scripts.sh build -r

# Run on specific device
./Scripts/all-scripts.sh run "iPhone 15"

# Run unit tests only
./Scripts/all-scripts.sh test -u

# Deep clean
./Scripts/all-scripts.sh clean -d

# Create release archive
./Scripts/all-scripts.sh archive
```

All scripts provide help with the `-h` flag. See `Scripts/README.md` for detailed documentation.

### Testing

- Use the sample files in the `SampleFiles` directory for testing
- Run unit tests with Xcode's test navigator or with ⌘U
- Use `./Scripts/test.sh` for command-line test execution with xcbeautify formatting

### Feature Priority Areas

Current high priority development areas:
1. Improved TOML parser with support for more complex TOML features
2. Performance optimizations for large files
3. Enhanced search capabilities and path navigation

## Known Issues and Limitations

1. TOML parser has limited support for complex nested structures
2. Manual parsing may not handle all edge cases for TOML and INI
3. CSV implementation currently only supports comma as delimiter
4. Large files can cause performance issues with syntax highlighting

## UI Design Notes

The app uses a modern iOS UI with dynamic light/dark mode support:
- Custom UI components extend standard UIKit classes
- `DesignSystem` namespace provides consistent styling
- Responsive design adapts to various device sizes
- View transitions maintain state when switching between text/tree/table views