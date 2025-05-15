# ParseLab Development Plan

This document outlines the current development status and future plans for ParseLab, a utility for working with structured data formats.

## Implemented Features

- JSON parsing, display, and editing
- JSON syntax highlighting
- JSON path navigation
- JSON schema validation
- YAML parsing and syntax highlighting
- YAML to JSON conversion
- TOML parsing and syntax highlighting 
- TOML to JSON conversion
- TOML schema validation
- Tree view for structured data
- File metadata display
- Recent files management
- Sample files for testing

## Current Architecture

The application is structured around several key components:

1. **Core Parsers**
   - `JSONParser`: Uses native `JSONSerialization` for JSON parsing
   - `YAMLParser`: Handles YAML parsing and conversion to JSON
   - `TOMLParser`: Manual TOML parser with JSON conversion capability

2. **UI Components**
   - View controllers for different view modes (text, tree)
   - Custom UI components for enhanced file viewing and editing
   - Syntax highlighters for different file formats

3. **Schema Validation**
   - JSON schema validation against JSON Schema
   - TOML schema validation against JSON Schema
   - Error reporting and display

## TOML Implementation Details

TOML (Tom's Obvious Minimal Language) support has been implemented with:

1. **TOMLParser**
   - Manual parser implementation without external dependencies
   - Support for basic TOML syntax (key-value pairs, tables, arrays)
   - Conversion to JSON for compatibility with existing tools

2. **TOMLHighlighter**
   - Syntax highlighting for TOML elements
   - Color scheme appropriate for TOML syntax

3. **Schema Validation**
   - Validation of TOML against JSON Schemas
   - Custom error handling for TOML validation

## Future Enhancements

- Improved TOML parser with support for more complex TOML features
- Integration with external TOML library when available
- Enhanced validation capabilities
- Support for more file formats (XML, CSV, etc.)
- Performance optimizations for large files
- Cloud storage integration
- Additional schema validation features
- Customizable syntax highlighting themes