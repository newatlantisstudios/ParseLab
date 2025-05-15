//
//  YAMLHighlighter.swift
//  ParseLab
//
//  Created on 5/14/25.
//

import UIKit

class YAMLHighlighter {
    // Define syntax colors for YAML highlighting
    struct SyntaxColors {
        // Using system colors that automatically adapt to light/dark mode
        static let key = UIColor.systemBlue
        static let string = UIColor.systemGreen
        static let number = UIColor.systemOrange
        static let boolean = UIColor.systemPurple
        static let null = UIColor.systemRed
        static let comment = UIColor.systemGray
        static let anchor = UIColor.systemIndigo
        static let directive = UIColor.systemTeal
        static let plainText = UIColor.label // Adapts between black/white based on mode
    }
    
    // Method to highlight YAML syntax
    func highlightYAML(_ yamlString: String, font: UIFont? = nil) -> NSAttributedString {
        let defaultFont = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let attributedString = NSMutableAttributedString(
            string: yamlString,
            attributes: [.foregroundColor: SyntaxColors.plainText, .font: font ?? defaultFont]
        )
        
        // Set paragraph style for proper wrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.headIndent = 8
        paragraphStyle.firstLineHeadIndent = 8
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: yamlString.count))
        
        // Define regular expressions for YAML elements
        let patterns: [(pattern: String, color: UIColor)] = [
            // Match comments
            ("#.*$", SyntaxColors.comment),
            
            // Match keys (before a colon)
            ("^\\s*[\\w\\-\\.]+(?=\\s*:)", SyntaxColors.key),
            
            // Match quoted strings
            ("\"[^\"]*\"", SyntaxColors.string),
            ("'[^']*'", SyntaxColors.string),
            
            // Match numbers
            ("\\b-?\\d+(\\.\\d+)?([eE][+-]?\\d+)?\\b", SyntaxColors.number),
            
            // Match booleans
            ("\\b(true|false|yes|no|on|off)\\b", SyntaxColors.boolean),
            
            // Match null/nil values
            ("\\b(null|nil|~)\\b", SyntaxColors.null),
            
            // Match YAML directives
            ("^%\\w+", SyntaxColors.directive),
            
            // Match anchors and aliases
            ("&\\w+|\\*\\w+", SyntaxColors.anchor)
        ]
        
        // Apply each pattern
        for (pattern, color) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
                let matches = regex.matches(in: yamlString, options: [], range: NSRange(location: 0, length: yamlString.utf16.count))
                
                for match in matches {
                    let range = match.range
                    attributedString.addAttribute(.foregroundColor, value: color, range: range)
                }
            } catch {
                print("Error with regex pattern: \(pattern), error: \(error)")
            }
        }
        
        return attributedString
    }
}