//
//  TOMLHighlighter.swift
//  ParseLab
//
//  Created on 5/14/25.
//

import UIKit

/// Syntax highlighter for TOML content
class TOMLHighlighter {
    
    /// Define syntax colors for TOML elements
    struct TOMLSyntaxColors {
        static let section = UIColor.systemPurple  // Table headers
        static let key = UIColor.systemBlue        // Keys
        static let string = UIColor.systemGreen    // String values
        static let number = UIColor.systemOrange   // Numeric values
        static let boolean = UIColor.systemPink    // Boolean values
        static let date = UIColor.systemTeal       // Date/time values
        static let comment = UIColor.systemGray    // Comments
        static let array = UIColor.systemIndigo    // Array markers
        static let plainText = UIColor.label       // Default text
    }
    
    /// Highlight TOML text with appropriate colors
    /// - Parameters:
    ///   - text: TOML text to highlight
    ///   - font: Font to use for the text
    /// - Returns: NSAttributedString with syntax highlighting
    func highlightTOML(_ text: String, font: UIFont? = nil) -> NSAttributedString {
        // Handle empty text case to prevent crashes
        if text.isEmpty {
            // Return at least a minimal string with default style rather than empty string
            let defaultFont = font ?? UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
            let emptyString = NSMutableAttributedString(string: "")
            let attributes: [NSAttributedString.Key: Any] = [.font: defaultFont, .foregroundColor: TOMLSyntaxColors.plainText]
            emptyString.addAttributes(attributes, range: NSRange(location: 0, length: 0))
            return emptyString
        }
        
        // Create a safe copy of the text to prevent any potential threading issues
        let safeText = String(text)
        
        let defaultFont = font ?? UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let attributedString = NSMutableAttributedString(string: safeText)
        
        // Default text attributes
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: defaultFont,
            .foregroundColor: TOMLSyntaxColors.plainText
        ]
        
        // Apply default attributes to entire string
        attributedString.addAttributes(defaultAttributes, range: NSRange(location: 0, length: attributedString.length))
        
        // Apply paragraph style for proper code formatting
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.headIndent = 8
        paragraphStyle.firstLineHeadIndent = 8
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        // Make sure text is not too long to avoid performance issues
        let textLength = min(text.utf16.count, 50000) // Limit to 50K characters
        let textRange = NSRange(location: 0, length: textLength)
        
        // Patterns to match TOML syntax elements
        let patterns: [(pattern: String, color: UIColor)] = [
            // Comments - entire line after #
            ("#.*$", TOMLSyntaxColors.comment),
            
            // Section headers - [section] and [[array]]
            ("\\[\\[.*?\\]\\]", TOMLSyntaxColors.array),
            ("\\[.*?\\]", TOMLSyntaxColors.section),
            
            // Key names (before equal sign) - these need to be matched before values
            ("^\\s*[a-zA-Z0-9_.-]+(?=\\s*=)", TOMLSyntaxColors.key),
            ("(?<=\\.[\\s])[a-zA-Z0-9_.-]+(?=\\s*=)", TOMLSyntaxColors.key),
            ("[a-zA-Z0-9_.-]+(?=\\s*=)", TOMLSyntaxColors.key),
            
            // String values - multiline
            ("=\\s*\"\"\"[\\s\\S]*?\"\"\"", TOMLSyntaxColors.string),
            ("=\\s*'''[\\s\\S]*?'''", TOMLSyntaxColors.string),
            
            // String values - single line
            ("=\\s*\".*?\"", TOMLSyntaxColors.string),
            ("=\\s*'.*?'", TOMLSyntaxColors.string),
            
            // Arrays
            ("=\\s*\\[.*?\\]", TOMLSyntaxColors.array),
            
            // Booleans
            ("=\\s*(true|false)\\b", TOMLSyntaxColors.boolean),
            
            // Numbers (decimal, hex, octal, binary)
            ("=\\s*-?\\d+(\\.\\d+)?([eE][+-]?\\d+)?\\b", TOMLSyntaxColors.number),
            ("=\\s*0x[0-9a-fA-F]+\\b", TOMLSyntaxColors.number),
            ("=\\s*0o[0-7]+\\b", TOMLSyntaxColors.number),
            ("=\\s*0b[01]+\\b", TOMLSyntaxColors.number),
            
            // Date and time formats
            ("=\\s*\\d{4}-\\d{2}-\\d{2}([T ]\\d{2}:\\d{2}:\\d{2})?(\\.\\d+)?(Z|[+-]\\d{2}:\\d{2})?\\b", TOMLSyntaxColors.date),
            ("=\\s*\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?\\b", TOMLSyntaxColors.date)
        ]
        
        // Apply patterns
        for (pattern, color) in patterns {
            do {
                // Include dotMatchesLineSeparators to handle multi-line strings
                let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines, .dotMatchesLineSeparators])
                // Prevent excessive memory usage by limiting search range
                let matches = regex.matches(in: text, options: [], range: textRange)
                
                for match in matches {
                    // Safeguard against out-of-bounds ranges
                    if match.range.location + match.range.length <= textLength {
                        if pattern.contains("=\\s*") && match.range.location > 0 {
                            // For key-value pairs, only color the value (after the =)
                            if let matchRange = Range(match.range, in: text),
                               let equalRange = text.range(of: "=", options: [], range: matchRange) {
                                // Calculate position of equal sign
                                let equalLocation = text.distance(from: text.startIndex, to: equalRange.lowerBound)
                                
                                // Get location after equal sign
                                let valueStartLocation = equalLocation + 1
                                // Ensure value length doesn't exceed string bounds
                                let matchEndLocation = match.range.location + match.range.length
                                let valueLength = max(0, min(matchEndLocation - valueStartLocation, textLength - valueStartLocation))
                                
                                if valueLength > 0 && valueStartLocation < textLength {
                                    // Create range for value part only
                                    let valueRange = NSRange(location: valueStartLocation, length: valueLength)
                                    attributedString.addAttribute(.foregroundColor, value: color, range: valueRange)
                                }
                            }
                        } else {
                            // For other elements (sections, comments), color the entire match
                            attributedString.addAttribute(.foregroundColor, value: color, range: match.range)
                        }
                    }
                }
            } catch {
                print("Error applying TOML regex pattern: \(pattern) - \(error)")
            }
        }
        
        return attributedString
    }
}