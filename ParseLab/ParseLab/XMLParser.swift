//
//  XMLParser.swift
//  ParseLab
//
//  Created on 5/16/25.
//

import Foundation

/// XML Parser for handling XML files
/// This implementation uses Foundation's XMLParser and converts XML to a hierarchical structure
/// that can be displayed in the tree view and also preserves original formatting for text view
class XMLParser {
    
    /// Error types specific to XML parsing
    enum XMLParserError: Error {
        case invalidXML
        case conversionFailed
        case emptyContent
        case parsingFailed(String)
    }
    
    /// Determines if a string is likely XML based on extension and content inspection
    /// - Parameters:
    ///   - content: The content string to inspect
    ///   - fileExtension: The file extension (optional)
    /// - Returns: Boolean indicating if the content is likely XML
    static func isXML(content: String, fileExtension: String? = nil) -> Bool {
        // Check extension first
        if let ext = fileExtension?.lowercased() {
            if ext == "xml" {
                return true
            }
        }
        
        // Simple content-based heuristics for XML detection
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for common XML patterns
        let hasXMLDeclaration = trimmedContent.hasPrefix("<?xml")
        let hasOpeningTag = trimmedContent.contains("<") && trimmedContent.contains(">")
        let hasClosingTag = trimmedContent.contains("</") || trimmedContent.contains("/>")
        let hasRootElement = (trimmedContent.range(of: "<[^/\\?>]+>", options: .regularExpression) != nil)
        
        // Combine heuristics
        return hasXMLDeclaration || (hasOpeningTag && hasClosingTag && hasRootElement)
    }
    
    /// Parse XML content and convert to a hierarchical structure
    /// - Parameter xmlString: The XML content as a string
    /// - Returns: Any object (typically Dictionary) representing the parsed XML
    /// - Throws: XMLParserError if parsing fails
    static func parse(_ xmlString: String) throws -> Any {
        guard !xmlString.isEmpty else {
            throw XMLParserError.emptyContent
        }
        
        let data = xmlString.data(using: .utf8) ?? Data()
        let parser = Foundation.XMLParser(data: data)
        let delegate = XMLParserDelegate()
        parser.delegate = delegate
        
        if parser.parse() {
            return delegate.root ?? [:]
        } else {
            let error = parser.parserError?.localizedDescription ?? "Unknown error"
            throw XMLParserError.parsingFailed(error)
        }
    }
    
    /// Convert XML to pretty-printed JSON
    /// - Parameter xmlString: The XML content as a string
    /// - Returns: Pretty-printed JSON string
    /// - Throws: XMLParserError if conversion fails
    static func convertToPrettyJSON(_ xmlString: String) throws -> String {
        let parsedObject = try parse(xmlString)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parsedObject, options: [.prettyPrinted, .sortedKeys])
            
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw XMLParserError.conversionFailed
            }
            
            return jsonString
        } catch {
            print("JSON conversion error: \(error)")
            throw XMLParserError.conversionFailed
        }
    }
}

/// Custom XMLParserDelegate for handling XML parsing
private class XMLParserDelegate: NSObject, Foundation.XMLParserDelegate {
    var root: Any?
    private var elementStack: [[String: Any]] = []
    private var currentElement: [String: Any] = [:]
    private var currentElementName: String = ""
    private var currentTextValue: String = ""
    
    func parser(_ parser: Foundation.XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = [:]
        currentElementName = elementName
        currentTextValue = ""
        
        // Add attributes with @ prefix to distinguish them
        for (key, value) in attributeDict {
            currentElement["@\(key)"] = value
        }
        
        elementStack.append(currentElement)
    }
    
    func parser(_ parser: Foundation.XMLParser, foundCharacters string: String) {
        currentTextValue += string
    }
    
    func parser(_ parser: Foundation.XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard !elementStack.isEmpty else { return }
        
        var element = elementStack.removeLast()
        let textValue = currentTextValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If element has text content, add it
        if !textValue.isEmpty {
            if element.isEmpty {
                // If element has no attributes, just store the text value
                element = ["_text": textValue]
            } else {
                // If element has attributes, add text as a special key
                element["_text"] = textValue
            }
        }
        
        // Add to parent or set as root
        if elementStack.isEmpty {
            // This is the root element
            root = [elementName: element.isEmpty ? textValue as Any : element as Any]
        } else {
            // Add to parent element
            var parent = elementStack.removeLast()
            
            // Handle arrays for repeated elements
            if let existing = parent[elementName] {
                if var array = existing as? [[String: Any]] {
                    array.append(element)
                    parent[elementName] = array
                } else {
                    parent[elementName] = [existing, element]
                }
            } else {
                parent[elementName] = element.isEmpty ? textValue : element
            }
            
            elementStack.append(parent)
        }
        
        // Reset current values
        currentTextValue = ""
        currentElementName = ""
    }
}