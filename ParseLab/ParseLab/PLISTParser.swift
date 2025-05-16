//
//  PLISTParser.swift
//  ParseLab
//
//  Created on 5/16/25.
//

import Foundation

/// Property List (PLIST) Parser for handling .plist files
/// This implementation uses the built-in PropertyListSerialization
/// to parse PLIST files and convert them to JSON for consistency
class PLISTParser {
    
    /// Error types specific to PLIST parsing
    enum PLISTParserError: Error {
        case invalidPLIST
        case conversionFailed
        case emptyContent
        case unsupportedFormat
    }
    
    /// Determines if a string is likely PLIST based on extension and content inspection
    /// - Parameters:
    ///   - content: The content string to inspect
    ///   - fileExtension: The file extension (optional)
    /// - Returns: Boolean indicating if the content is likely PLIST
    static func isPLIST(content: String, fileExtension: String? = nil) -> Bool {
        // Check extension first
        if let ext = fileExtension?.lowercased() {
            if ext == "plist" {
                return true
            }
        }
        
        // Simple content-based heuristics for PLIST detection
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for common PLIST patterns
        let containsXMLPlistHeader = trimmedContent.contains("<?xml") && trimmedContent.contains("<plist")
        let containsBinaryPlistHeader = content.data(using: .utf8)?.prefix(8) == "bplist00".data(using: .utf8)
        
        return containsXMLPlistHeader || containsBinaryPlistHeader
    }
    
    /// Parse PLIST content and convert to a JSON object
    /// - Parameter plistData: The PLIST content as Data
    /// - Returns: Any object (typically Dictionary or Array) representing the parsed PLIST
    /// - Throws: PLISTParserError if parsing fails
    static func parse(_ plistData: Data) throws -> Any {
        guard !plistData.isEmpty else {
            throw PLISTParserError.emptyContent
        }
        
        do {
            var format = PropertyListSerialization.PropertyListFormat.xml
            let parsedPlist = try PropertyListSerialization.propertyList(from: plistData, 
                                                                       options: [],
                                                                       format: &format)
            return parsedPlist
        } catch {
            print("PLIST parsing error: \(error)")
            throw PLISTParserError.invalidPLIST
        }
    }
    
    /// Parse PLIST content from string and convert to a JSON object
    /// - Parameter plistString: The PLIST content as a string
    /// - Returns: Any object (typically Dictionary or Array) representing the parsed PLIST
    /// - Throws: PLISTParserError if parsing fails
    static func parse(_ plistString: String) throws -> Any {
        guard let data = plistString.data(using: .utf8) else {
            throw PLISTParserError.conversionFailed
        }
        return try parse(data)
    }
    
    /// Convert PLIST to pretty-printed JSON
    /// - Parameter plistData: The PLIST content as Data
    /// - Returns: Pretty-printed JSON string
    /// - Throws: PLISTParserError if conversion fails
    static func convertToPrettyJSON(_ plistData: Data) throws -> String {
        let parsedObject = try parse(plistData)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parsedObject, 
                                                    options: [.prettyPrinted, .sortedKeys])
            
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw PLISTParserError.conversionFailed
            }
            
            return jsonString
        } catch {
            print("JSON conversion error: \(error)")
            throw PLISTParserError.conversionFailed
        }
    }
    
    /// Convert PLIST string to pretty-printed JSON
    /// - Parameter plistString: The PLIST content as a string
    /// - Returns: Pretty-printed JSON string
    /// - Throws: PLISTParserError if conversion fails
    static func convertToPrettyJSON(_ plistString: String) throws -> String {
        guard let data = plistString.data(using: .utf8) else {
            throw PLISTParserError.conversionFailed
        }
        return try convertToPrettyJSON(data)
    }
}