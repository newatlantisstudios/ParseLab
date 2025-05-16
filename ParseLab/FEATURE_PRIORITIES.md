# ParseLab Feature Priorities

This document outlines the priority of upcoming features and improvements for ParseLab.

## High Priority

1. **Improve TOML Support**
   - Enhance the manual TOML parser to support more complex TOML features
   - Add better error handling for TOML parsing
   - Support inline tables and multi-line strings
   - Support more datetime formats

2. **Performance Optimizations**
   - Optimize syntax highlighting for large files
   - Implement progressive loading for large files
   - Add caching for frequently accessed files

3. **Core Functionality Improvements**
   - Add search capability within tree view
   - Improve path navigation for deep structures
   - Add additional schema validation options

## Medium Priority

1. **Additional File Format Support**
   - XML parsing and display
   - ✅ CSV parsing and display (implemented)
   - ✅ INI file support (implemented)
   - Property list (plist) support

2. **UI/UX Improvements**
   - Dark mode refinements
   - Customizable syntax highlighting themes
   - Split-view editing
   - Improved minimap functionality

3. **Export and Conversion**
   - Add export options for different formats
   - Conversion between formats (JSON→YAML, TOML→YAML, etc.)
   - Copy formatted output to clipboard

## Low Priority

1. **Integration Features**
   - Cloud storage support (iCloud, Dropbox, etc.)
   - URL scheme for opening files from other apps
   - Share extensions
   - Spotlight integration

2. **Advanced Features**
   - Diff tools for comparing files
   - Merge capabilities
   - Scripting support for batch operations
   - Custom validation rules

3. **Developer Tools**
   - JSON Pointer support
   - JSONPath query language
   - Schema generation from examples
   - API testing capabilities

## Maintenance Tasks

1. **Testing and Quality**
   - Expand unit test coverage
   - Add UI tests for core user flows
   - Performance benchmarking
   - Stress testing with large files

2. **Documentation**
   - Complete inline code documentation
   - User guide
   - Examples for common tasks
   - API documentation for extension

## Feedback Incorporation

The priority of these features may change based on user feedback. We'll regularly review usage patterns and user requests to adjust our development focus.

## Next Planned Release

For the next release, we're focusing on:

1. Complete TOML support improvements
2. Performance optimizations for large files
3. Search improvements within tree view
4. Basic XML support
5. Bug fixes and UI refinements
6. Add table view support for CSV files