//
//  YAMLParser.swift
//  ParseLab
//
//  Created on 5/14/25.
//

import Foundation
import Yams

/// YAML Parser for handling YAML files
/// This implementation uses the Yams library to parse YAML
/// and leverages Swift's built-in JSON handling for consistency
class YAMLParser {
    
    /// Error types specific to YAML parsing
    enum YAMLParserError: Error {
        case invalidYAML
        case conversionFailed
        case emptyContent
    }
    
    /// Determines if a string is likely YAML based on extension and content inspection
    /// - Parameters:
    ///   - content: The content string to inspect
    ///   - fileExtension: The file extension (optional)
    /// - Returns: Boolean indicating if the content is likely YAML
    static func isYAML(content: String, fileExtension: String? = nil) -> Bool {
        // Check extension first
        if let ext = fileExtension?.lowercased() {
            if ext == "yaml" || ext == "yml" {
                return true
            }
        }
        
        // Simple content-based heuristics for YAML detection
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for common YAML patterns
        let containsKeyValuePairs = trimmedContent.contains(":")
        let containsIndentation = trimmedContent.contains("\n ")
        let containsListItems = trimmedContent.contains("\n- ")
        let doesNotStartWithBraces = !trimmedContent.hasPrefix("{") && !trimmedContent.hasPrefix("[")
        
        // Combine heuristics - we'll consider it YAML if it has at least
        // some YAML-like characteristics and doesn't look like JSON
        return (containsKeyValuePairs || containsListItems || containsIndentation) && doesNotStartWithBraces
    }
    
    /// Parse YAML content and convert to a JSON object
    /// - Parameter yamlString: The YAML content as a string
    /// - Returns: Any object (typically Dictionary or Array) representing the parsed YAML
    /// - Throws: YAMLParserError if parsing fails
    static func parse(_ yamlString: String) throws -> Any {
        guard !yamlString.isEmpty else {
            throw YAMLParserError.emptyContent
        }
        
        do {
            // Use Yams to parse the YAML string
            if let parsedYAML = try Yams.load(yaml: yamlString) {
                return parsedYAML
            } else {
                // Handle empty but valid YAML
                return [String: Any]()
            }
        } catch {
            print("YAML parsing error: \(error)")
            throw YAMLParserError.invalidYAML
        }
    }
    
    /// Convert YAML to pretty-printed JSON
    /// - Parameter yamlString: The YAML content as a string
    /// - Returns: Pretty-printed JSON string
    /// - Throws: YAMLParserError if conversion fails
    static func convertToPrettyJSON(_ yamlString: String) throws -> String {
        let parsedObject = try parse(yamlString)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parsedObject, options: [.prettyPrinted, .sortedKeys])
            
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw YAMLParserError.conversionFailed
            }
            
            return jsonString
        } catch {
            print("JSON conversion error: \(error)")
            throw YAMLParserError.conversionFailed
        }
    }
}