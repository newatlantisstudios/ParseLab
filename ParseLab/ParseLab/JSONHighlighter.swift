//
//  JSONHighlighter.swift
//  ParseLab
//
//  Created by x on 4/16/25.
//

import UIKit

class JSONHighlighter {
    // Method to highlight JSON syntax
    func highlightJSON(_ jsonString: String, font: UIFont? = nil) -> NSAttributedString {
        let defaultFont = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let attributedString = NSMutableAttributedString(
            string: jsonString,
            attributes: [.foregroundColor: SyntaxColors.plainText, .font: font ?? defaultFont]
        )
        
        // Define regular expressions for JSON elements
        let patterns: [(pattern: String, color: UIColor)] = [
            // Match string keys (with quotes and colon)
            ("\"[^\"]+\"(?=\\s*:)", SyntaxColors.key),
            // Match string values
            (":\\s*\"[^\"]*\"", SyntaxColors.string),
            // Match numbers
            (":\\s*-?\\d+(\\.\\d+)?([eE][+-]?\\d+)?", SyntaxColors.number),
            // Match booleans
            (":\\s*(true|false)", SyntaxColors.boolean),
            // Match null
            (":\\s*null", SyntaxColors.null),
            // Match structural characters
            ("[\\{\\}\\[\\],]", SyntaxColors.structural)
        ]
        
        // Apply each pattern
        for (pattern, color) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: jsonString, options: [], range: NSRange(location: 0, length: jsonString.utf16.count))
                
                for match in matches {
                    let range = match.range
                    if pattern.contains(":") {
                        // For patterns with colons, only color after the colon
                        if let colonRange = jsonString.range(of: ":", options: [], range: Range(range, in: jsonString)) {
                            let colonLocation = jsonString.distance(from: jsonString.startIndex, to: colonRange.lowerBound)
                            let valueStart = colonLocation + 1
                            let valueLength = range.location + range.length - valueStart
                            if valueLength > 0 {
                                attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: valueStart, length: valueLength))
                            }
                        }
                    } else {
                        attributedString.addAttribute(.foregroundColor, value: color, range: range)
                    }
                }
            } catch {
                print("Error with regex pattern: \(pattern), error: \(error)")
            }
        }
        
        return attributedString
    }
    
    // Define syntax colors for JSON highlighting
    // Using system colors that automatically adapt to light/dark mode
    struct SyntaxColors {
        // These system colors automatically adapt to the current interface style
        static let key = UIColor.systemBlue
        static let string = UIColor.systemGreen
        static let number = UIColor.systemOrange
        static let boolean = UIColor.systemPurple
        static let null = UIColor.systemRed
        static let structural = UIColor.systemGray
        static let error = UIColor.systemRed
        static let plainText = UIColor.label // This adapts between black/white based on mode
    }
}
