//
//  INIParser.swift
//  ParseLab
//
//  Created on 5/15/25.
//

import Foundation

enum INIParserError: Error {
    case invalidFormat(String)
    case invalidSection(String)
    case invalidKeyValue(String)
    case conversionError(String)
}

class INIParser {
    
    // Determine if content is likely an INI file based on content analysis
    static func isINI(content: String, fileExtension: String? = nil) -> Bool {
        // Check file extension first
        if let ext = fileExtension?.lowercased(), ext == "ini" {
            return true
        }
        
        // Simple content-based heuristics
        let lines = content.components(separatedBy: .newlines)
        var hasSection = false
        var hasKeyValue = false
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines and comments
            if trimmedLine.isEmpty || trimmedLine.hasPrefix(";") || trimmedLine.hasPrefix("#") {
                continue
            }
            
            // Check for section headers: [SectionName]
            if trimmedLine.hasPrefix("[") && trimmedLine.hasSuffix("]") {
                hasSection = true
            }
            
            // Check for key-value pairs: key=value or key:value
            if trimmedLine.contains("=") || trimmedLine.contains(":") {
                hasKeyValue = true
            }
        }
        
        // If we found at least a section or key-value pairs, it's likely an INI file
        return hasSection || hasKeyValue
    }
    
    // Primary method to convert INI to JSON
    static func convertToPrettyJSON(_ iniContent: String) throws -> String {
        let iniDict = try parse(iniContent)
        
        let jsonData = try JSONSerialization.data(withJSONObject: iniDict, options: [.prettyPrinted, .sortedKeys])
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw INIParserError.conversionError("Failed to convert INI to JSON string")
        }
        
        return jsonString
    }
    
    // Parse INI content to dictionary
    static func parse(_ iniContent: String) throws -> [String: Any] {
        var result: [String: Any] = [:]
        var currentSection: String = ""
        
        let lines = iniContent.components(separatedBy: .newlines)
        
        for (lineIndex, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines and comments
            if trimmedLine.isEmpty || trimmedLine.hasPrefix(";") || trimmedLine.hasPrefix("#") {
                continue
            }
            
            // Handle section headers: [SectionName]
            if trimmedLine.hasPrefix("[") && trimmedLine.hasSuffix("]") {
                let sectionName = String(trimmedLine.dropFirst().dropLast()).trimmingCharacters(in: .whitespaces)
                
                if sectionName.isEmpty {
                    throw INIParserError.invalidSection("Empty section name at line \(lineIndex + 1)")
                }
                
                currentSection = sectionName
                
                // Initialize the section if it doesn't exist
                if result[currentSection] == nil {
                    result[currentSection] = [String: Any]()
                }
                
                continue
            }
            
            // Handle key-value pairs: key=value or key:value
            if let separatorRange = trimmedLine.range(of: "=") ?? trimmedLine.range(of: ":") {
                let key = String(trimmedLine[..<separatorRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                let value = String(trimmedLine[separatorRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                
                if key.isEmpty {
                    throw INIParserError.invalidKeyValue("Empty key at line \(lineIndex + 1)")
                }
                
                // Convert value to appropriate type
                let parsedValue = parseValue(value)
                
                // If we're in a section, add to that section's dictionary
                if !currentSection.isEmpty {
                    var sectionDict = result[currentSection] as? [String: Any] ?? [:]
                    sectionDict[key] = parsedValue
                    result[currentSection] = sectionDict
                } else {
                    // No section defined yet, add to root
                    result[key] = parsedValue
                }
                
                continue
            }
            
            // If we get here, the line is not valid INI format
            throw INIParserError.invalidFormat("Invalid INI format at line \(lineIndex + 1): \(trimmedLine)")
        }
        
        return result
    }
    
    // Helper to parse INI values into appropriate types
    private static func parseValue(_ value: String) -> Any {
        // Try to parse as number (integer or double)
        if let intValue = Int(value) {
            return intValue
        }
        
        if let doubleValue = Double(value) {
            return doubleValue
        }
        
        // Try to parse as boolean
        let lowercasedValue = value.lowercased()
        if lowercasedValue == "true" || lowercasedValue == "yes" || lowercasedValue == "on" || lowercasedValue == "1" {
            return true
        }
        
        if lowercasedValue == "false" || lowercasedValue == "no" || lowercasedValue == "off" || lowercasedValue == "0" {
            return false
        }
        
        // Handle quoted strings
        if (value.hasPrefix("\"") && value.hasSuffix("\"")) || (value.hasPrefix("'") && value.hasSuffix("'")) {
            return String(value.dropFirst().dropLast())
        }
        
        // Default to string
        return value
    }
}