//
//  PLISTHighlighter.swift
//  ParseLab
//
//  Created on 5/16/25.
//

import UIKit

class PLISTHighlighter {
    // Define syntax colors for PLIST highlighting
    struct SyntaxColors {
        // Using system colors that automatically adapt to light/dark mode
        static let xmlTag = UIColor.systemBlue
        static let xmlAttribute = UIColor.systemPurple
        static let string = UIColor.systemGreen
        static let number = UIColor.systemOrange
        static let boolean = UIColor.systemRed
        static let comment = UIColor.systemGray
        static let keyTag = UIColor.systemTeal
        static let plainText = UIColor.label // Adapts between black/white based on mode
    }
    
    // Method to highlight PLIST syntax (XML format)
    func highlightPLIST(_ plistString: String, font: UIFont? = nil) -> NSAttributedString {
        let defaultFont = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let attributedString = NSMutableAttributedString(
            string: plistString,
            attributes: [.foregroundColor: SyntaxColors.plainText, .font: font ?? defaultFont]
        )
        
        // Set paragraph style for proper wrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.headIndent = 8
        paragraphStyle.firstLineHeadIndent = 8
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: plistString.count))
        
        // Define regular expressions for PLIST elements
        let patterns: [(pattern: String, color: UIColor)] = [
            // Match XML comments
            ("<!--.*?-->", SyntaxColors.comment),
            
            // Match XML/PLIST tags
            ("</?\\w+[^>]*>", SyntaxColors.xmlTag),
            
            // Match key tags specifically
            ("<key>.*?</key>", SyntaxColors.keyTag),
            
            // Match string content between tags
            ("<string>(.*?)</string>", SyntaxColors.string),
            
            // Match integer content
            ("<integer>(.*?)</integer>", SyntaxColors.number),
            
            // Match real (float) content
            ("<real>(.*?)</real>", SyntaxColors.number),
            
            // Match boolean tags
            ("<(true|false)/>", SyntaxColors.boolean),
            
            // Match XML attributes
            ("\\w+=\"[^\"]*\"", SyntaxColors.xmlAttribute),
            
            // Match data content (base64)
            ("<data>.*?</data>", SyntaxColors.string),
            
            // Match date content
            ("<date>.*?</date>", SyntaxColors.string)
        ]
        
        // Apply each pattern
        for (pattern, color) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
                let matches = regex.matches(in: plistString, options: [], range: NSRange(location: 0, length: plistString.utf16.count))
                
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