//
//  JSONStringFormatter.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

class JSONStringFormatter {
    
    /// Force wraps long string values in JSON to prevent overflow
    static func formatJSONString(_ jsonString: String, maxLineLength: Int = 80) -> String {
        var result = ""
        var currentLineLength = 0
        var inString = false
        var escaped = false
        
        for char in jsonString {
            // Track if we're inside a string
            if char == "\"" && !escaped {
                inString = !inString
            }
            
            // Track escaped characters
            if char == "\\" && !escaped {
                escaped = true
            } else {
                escaped = false
            }
            
            // Handle line wrapping for string values
            if inString && char != "\"" && currentLineLength >= maxLineLength {
                // Add line break and indentation
                result += "\n               "  // Match JSON indentation
                currentLineLength = 15  // Reset with indentation length
            }
            
            // Add character to result
            result.append(char)
            
            // Update line length or reset at newline
            if char == "\n" {
                currentLineLength = 0
            } else {
                currentLineLength += 1
            }
        }
        
        return result
    }
}
