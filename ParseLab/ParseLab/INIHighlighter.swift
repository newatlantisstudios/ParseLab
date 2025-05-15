//
//  INIHighlighter.swift
//  ParseLab
//
//  Created on 5/15/25.
//

import UIKit

class INIHighlighter {
    // Method to highlight INI syntax
    func highlightINI(_ iniString: String, font: UIFont? = nil) -> NSAttributedString {
        let defaultFont = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let attributedString = NSMutableAttributedString(
            string: iniString,
            attributes: [.foregroundColor: SyntaxColors.plainText, .font: font ?? defaultFont]
        )
        
        // Set paragraph style for proper wrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.headIndent = 8
        paragraphStyle.firstLineHeadIndent = 8
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: iniString.count))
        
        // Process the string line by line for more precise highlighting
        let lines = iniString.components(separatedBy: .newlines)
        var currentPosition = 0
        
        for line in lines {
            let lineLength = line.count
            
            if lineLength > 0 {
                let lineRange = NSRange(location: currentPosition, length: lineLength)
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                
                // Highlight comments (starting with ; or #)
                if line.hasPrefix(";") || line.hasPrefix("#") {
                    attributedString.addAttribute(.foregroundColor, value: SyntaxColors.comment, range: lineRange)
                }
                // Highlight section headers [SectionName]
                else if trimmedLine.hasPrefix("[") && trimmedLine.hasSuffix("]") {
                    attributedString.addAttribute(.foregroundColor, value: SyntaxColors.section, range: lineRange)
                }
                // Highlight key-value pairs
                else {
                    // Look for "=" or ":" separator
                    for separator in ["=", ":"] {
                        if let separatorRange = line.range(of: separator) {
                            // Calculate ranges in the original string
                            let keyRange = NSRange(
                                location: currentPosition,
                                length: line.distance(from: line.startIndex, to: separatorRange.lowerBound)
                            )
                            
                            // Highlight key
                            attributedString.addAttribute(.foregroundColor, value: SyntaxColors.key, range: keyRange)
                            
                            // Highlight separator
                            let separatorNSRange = NSRange(
                                location: currentPosition + keyRange.length,
                                length: separator.count
                            )
                            attributedString.addAttribute(.foregroundColor, value: SyntaxColors.separator, range: separatorNSRange)
                            
                            // Highlight value
                            if separatorRange.upperBound < line.endIndex {
                                let valueStartIndex = separatorRange.upperBound
                                let valueRange = NSRange(
                                    location: currentPosition + line.distance(from: line.startIndex, to: valueStartIndex),
                                    length: line.distance(from: valueStartIndex, to: line.endIndex)
                                )
                                
                                // Get the value text for type detection
                                let valueSubstring = line[valueStartIndex...]
                                let valueText = String(valueSubstring)
                                let trimmedValue = valueText.trimmingCharacters(in: .whitespaces)
                                
                                // Determine value type and apply appropriate color
                                if Int(trimmedValue) != nil || Double(trimmedValue) != nil {
                                    // Number value
                                    attributedString.addAttribute(.foregroundColor, value: SyntaxColors.number, range: valueRange)
                                }
                                else if ["true", "false", "yes", "no", "on", "off"].contains(trimmedValue.lowercased()) {
                                    // Boolean value
                                    attributedString.addAttribute(.foregroundColor, value: SyntaxColors.boolean, range: valueRange)
                                }
                                else if (trimmedValue.hasPrefix("\"") && trimmedValue.hasSuffix("\"")) || 
                                        (trimmedValue.hasPrefix("'") && trimmedValue.hasSuffix("'")) {
                                    // Quoted string
                                    attributedString.addAttribute(.foregroundColor, value: SyntaxColors.string, range: valueRange)
                                }
                                else {
                                    // Regular string or other value
                                    attributedString.addAttribute(.foregroundColor, value: SyntaxColors.value, range: valueRange)
                                }
                            }
                            
                            break // Found a separator, no need to check for the other one
                        }
                    }
                }
            }
            
            // Move to next line (including newline character)
            currentPosition += lineLength + 1
        }
        
        return attributedString
    }
    
    // Define syntax colors for INI highlighting
    // Using system colors that automatically adapt to light/dark mode
    struct SyntaxColors {
        static let section = UIColor.systemPurple
        static let key = UIColor.systemBlue
        static let value = UIColor.systemGreen
        static let string = UIColor.systemGreen
        static let number = UIColor.systemOrange
        static let boolean = UIColor.systemRed
        static let comment = UIColor.systemGray
        static let separator = UIColor.systemGray
        static let plainText = UIColor.label // This adapts between black/white based on mode
    }
}