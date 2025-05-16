//
//  XMLHighlighter.swift
//  ParseLab
//
//  Created on 5/16/25.
//

import UIKit

class XMLHighlighter {
    // Define syntax colors for XML highlighting
    struct SyntaxColors {
        // Using system colors that automatically adapt to light/dark mode
        static let plainText = UIColor.label
        static let string = UIColor.systemGreen
        static let structural = UIColor.systemGray
        static let comment = UIColor.systemGray
        
        static var processingInstruction: UIColor {
            if #available(iOS 13.0, *) {
                return UIColor { traitCollection in
                    switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0) // Orange
                    default:
                        return UIColor(red: 0.7, green: 0.5, blue: 0.1, alpha: 1.0) // Darker orange
                    }
                }
            } else {
                return UIColor(red: 0.7, green: 0.5, blue: 0.1, alpha: 1.0)
            }
        }
        
        static var tagName: UIColor {
            if #available(iOS 13.0, *) {
                return UIColor { traitCollection in
                    switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1.0) // Light blue
                    default:
                        return UIColor(red: 0.1, green: 0.3, blue: 0.7, alpha: 1.0) // Dark blue
                    }
                }
            } else {
                return UIColor(red: 0.1, green: 0.3, blue: 0.7, alpha: 1.0)
            }
        }
        
        static var attributeName: UIColor {
            if #available(iOS 13.0, *) {
                return UIColor { traitCollection in
                    switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return UIColor(red: 0.7, green: 0.9, blue: 0.5, alpha: 1.0) // Light green
                    default:
                        return UIColor(red: 0.3, green: 0.7, blue: 0.1, alpha: 1.0) // Dark green
                    }
                }
            } else {
                return UIColor(red: 0.3, green: 0.7, blue: 0.1, alpha: 1.0)
            }
        }
        
        static var cdata: UIColor {
            if #available(iOS 13.0, *) {
                return UIColor { traitCollection in
                    switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return UIColor(red: 0.7, green: 0.7, blue: 0.9, alpha: 1.0) // Light purple
                    default:
                        return UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 1.0) // Dark purple
                    }
                }
            } else {
                return UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 1.0)
            }
        }
    }
    
    // Method to highlight XML syntax
    func highlightXML(_ xmlString: String, font: UIFont? = nil) -> NSAttributedString {
        let defaultFont = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let attributedString = NSMutableAttributedString(
            string: xmlString,
            attributes: [.foregroundColor: SyntaxColors.plainText, .font: font ?? defaultFont]
        )
        
        // Set paragraph style for proper wrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.headIndent = 8
        paragraphStyle.firstLineHeadIndent = 8
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: xmlString.count))
        
        // Define regular expressions for XML elements
        let patterns: [(pattern: String, color: UIColor)] = [
            // Match XML declaration and processing instructions
            ("<\\?[^>]*\\?>", SyntaxColors.processingInstruction),
            // Match comments
            ("<!--[\\s\\S]*?-->", SyntaxColors.comment),
            // Match CDATA sections
            ("<!\\[CDATA\\[[\\s\\S]*?\\]\\]>", SyntaxColors.cdata),
            // Match tag names (opening and closing)
            ("</?\\b([^\\s>]+)\\b", SyntaxColors.tagName),
            // Match attribute names
            ("\\s+([^\\s=<>\"']+)(?=\\s*=)", SyntaxColors.attributeName),
            // Match attribute values
            ("=\\s*\"[^\"]*\"", SyntaxColors.string),
            ("=\\s*'[^']*'", SyntaxColors.string),
            // Match structural characters (< > />)
            ("[<>]|/>", SyntaxColors.structural)
        ]
        
        // Apply each pattern
        for (pattern, color) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: xmlString, options: [], range: NSRange(location: 0, length: xmlString.utf16.count))
                
                for match in matches {
                    let range = match.range
                    
                    // Special handling for different pattern types
                    if pattern.contains("</") {
                        // For tag names, color only the name part
                        if match.numberOfRanges > 1 {
                            let nameRange = match.range(at: 1)
                            attributedString.addAttribute(.foregroundColor, value: color, range: nameRange)
                        } else {
                            attributedString.addAttribute(.foregroundColor, value: color, range: range)
                        }
                    } else if pattern.contains("=") {
                        // For attributes, handle name and value separately
                        if pattern.contains("(?=\\s*=)") {
                            // Attribute name
                            if match.numberOfRanges > 1 {
                                let nameRange = match.range(at: 1)
                                attributedString.addAttribute(.foregroundColor, value: color, range: nameRange)
                            }
                        } else {
                            // Attribute value - only color the value part after =
                            if let equalRange = xmlString.range(of: "=", options: [], range: Range(range, in: xmlString)) {
                                let equalLocation = xmlString.distance(from: xmlString.startIndex, to: equalRange.lowerBound)
                                let valueStart = equalLocation + 1
                                let valueLength = range.location + range.length - valueStart
                                if valueLength > 0 {
                                    attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: valueStart, length: valueLength))
                                }
                            }
                        }
                    } else {
                        // For other patterns, apply color to the whole match
                        attributedString.addAttribute(.foregroundColor, value: color, range: range)
                    }
                }
            } catch {
                print("Regex error: \(error)")
            }
        }
        
        return attributedString
    }
}