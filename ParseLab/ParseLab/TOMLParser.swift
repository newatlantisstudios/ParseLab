//
//  TOMLParser.swift
//  ParseLab
//
//  Created on 5/14/25.
//

import Foundation

/// TOML Parser for handling TOML files
/// This implementation uses a simple manual parser for TOML
/// and leverages Swift's built-in JSON handling for consistency
class TOMLParser {
    
    /// Error types specific to TOML parsing
    enum TOMLParserError: Error {
        case invalidTOML
        case conversionFailed
        case emptyContent
    }
    
    /// Determines if a string is likely TOML based on extension and content inspection
    /// - Parameters:
    ///   - content: The content string to inspect
    ///   - fileExtension: The file extension (optional)
    /// - Returns: Boolean indicating if the content is likely TOML
    static func isTOML(content: String, fileExtension: String? = nil) -> Bool {
        // Check extension first
        if let ext = fileExtension?.lowercased() {
            if ext == "toml" {
                return true
            }
        }
        
        // Simple content-based heuristics for TOML detection
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for common TOML patterns
        let containsKeyValuePairs = trimmedContent.contains(" = ")
        let containsTableHeaders = trimmedContent.contains("[") && trimmedContent.contains("]")
        let containsComments = trimmedContent.contains("#")
        let doesNotStartWithBraces = !trimmedContent.hasPrefix("{") && !trimmedContent.hasPrefix("[{")
        
        // Combine heuristics - we'll consider it TOML if it has at least
        // some TOML-like characteristics and doesn't look like JSON
        return (containsKeyValuePairs || containsTableHeaders) && doesNotStartWithBraces
    }
    
    /// Parse TOML content and convert to a JSON object
    /// - Parameter tomlString: The TOML content as a string
    /// - Returns: Any object (typically Dictionary) representing the parsed TOML
    /// - Throws: TOMLParserError if parsing fails
    static func parse(_ tomlString: String) throws -> Any {
        guard !tomlString.isEmpty else {
            throw TOMLParserError.emptyContent
        }
        
        do {
            // Placeholder parsing implementation until TOMLDeserializer is integrated
            // This will convert basic TOML to a dictionary
            let parsedTOML = try parseTOMLManually(tomlString)
            return parsedTOML
        } catch {
            print("TOML parsing error: \(error)")
            throw TOMLParserError.invalidTOML
        }
    }
    
    /// Convert TOML to pretty-printed JSON
    /// - Parameter tomlString: The TOML content as a string
    /// - Returns: Pretty-printed JSON string
    /// - Throws: TOMLParserError if conversion fails
    static func convertToPrettyJSON(_ tomlString: String) throws -> String {
        let parsedObject = try parse(tomlString)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parsedObject, options: [.prettyPrinted, .sortedKeys])
            
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw TOMLParserError.conversionFailed
            }
            
            return jsonString
        } catch {
            print("JSON conversion error: \(error)")
            throw TOMLParserError.conversionFailed
        }
    }
    
    /// Basic manual TOML parser implementation
    /// Handles simple key-value pairs and tables
    /// - Parameter tomlString: The TOML content to parse
    /// - Returns: A dictionary representation of the TOML content
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
            
            // Check for table headers: [table] or [[table]]
            if trimmedLine.hasPrefix("[") && trimmedLine.hasSuffix("]") {
                let tableHeader = trimmedLine
                if tableHeader.hasPrefix("[[") && tableHeader.hasSuffix("]]") {
                    // Array of tables: [[table]]
                    let tableName = String(tableHeader.dropFirst(2).dropLast(2))
                    currentTable = tableName
                    
                    // Create array for this table if it doesn't exist
                    if result[tableName] == nil {
                        result[tableName] = [[String: Any]]()
                    }
                    
                    // Add a new dictionary to the array
                    if var tableArray = result[tableName] as? [[String: Any]] {
                        tableArray.append([:])
                        result[tableName] = tableArray
                    }
                } else {
                    // Regular table: [table]
                    let tableName = String(tableHeader.dropFirst(1).dropLast(1))
                    currentTable = tableName
                    
                    // Create dictionary for this table if it doesn't exist
                    if result[tableName] == nil {
                        result[tableName] = [String: Any]()
                    }
                }
                continue
            }
            
            // Parse key-value pairs: key = value
            if let equalsIndex = trimmedLine.firstIndex(of: "=") {
                let key = trimmedLine[..<equalsIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                let value = trimmedLine[trimmedLine.index(after: equalsIndex)...].trimmingCharacters(in: .whitespacesAndNewlines)
                
                let parsedValue = parseValue(value)
                
                if let currentTable = currentTable {
                    // Add to current table
                    if trimmedLine.hasPrefix("[[") {
                        // Array of tables
                        if var tableArray = result[currentTable] as? [[String: Any]], !tableArray.isEmpty {
                            tableArray[tableArray.count - 1][String(key)] = parsedValue
                            result[currentTable] = tableArray
                        }
                    } else {
                        // Regular table
                        if var table = result[currentTable] as? [String: Any] {
                            table[String(key)] = parsedValue
                            result[currentTable] = table
                        }
                    }
                } else {
                    // Add to root
                    result[String(key)] = parsedValue
                }
            }
        }
        
        return result
    }
    
    /// Parse a TOML value string into an appropriate Swift type
    /// - Parameter value: The string value to parse
    /// - Returns: The parsed value as a Swift type
    private static func parseValue(_ value: String) -> Any {
        // Try to parse as a number (integer or double)
        if let intValue = Int(value) {
            return intValue
        }
        if let doubleValue = Double(value) {
            return doubleValue
        }
        
        // Try to parse as boolean
        if value == "true" {
            return true
        }
        if value == "false" {
            return false
        }
        
        // Parse as string (removing quotes if present)
        if value.hasPrefix("\"") && value.hasSuffix("\"") {
            return String(value.dropFirst().dropLast())
        }
        if value.hasPrefix("'") && value.hasSuffix("'") {
            return String(value.dropFirst().dropLast())
        }
        
        // Try to parse as array if it uses square brackets
        if value.hasPrefix("[") && value.hasSuffix("]") {
            let arrayContent = String(value.dropFirst().dropLast())
            let elements = arrayContent.split(separator: ",")
            return elements.map { parseValue(String($0.trimmingCharacters(in: .whitespacesAndNewlines))) }
        }
        
        // Default to string
        return value
    }
}