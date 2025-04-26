//
//  ViewController+JsonTreeText.swift
//  ParseLab
//
//  Created by x on 4/26/25.
//

import UIKit

// MARK: - JSON Tree Text Visualization

extension ViewController {
    
    // Generate a text-based tree representation of JSON data
    func generateJsonTreeView(_ node: Any, path: String, depth: Int = 0, isLast: Bool = true) -> String {
        let indent = String(repeating: "    ", count: depth)
        let prefix = depth > 0 ? (isLast ? "└── " : "├── ") : ""
        var result = ""
        
        // Handle different types of JSON nodes
        if let dict = node as? [String: Any] {
            result += "\(indent)\(prefix)Object {\(dict.count) keys}\n"
            
            let sortedKeys = dict.keys.sorted()
            for (index, key) in sortedKeys.enumerated() {
                let isLastItem = (index == sortedKeys.count - 1)
                let value = dict[key]!
                let childPath = path.hasSuffix("$") ? "\(path).\(key)" : "\(path)/\(key)"
                
                // Key representation with type indicator
                let keyText = "\(indent)    \(isLastItem ? "└── " : "├── ")\(key): "
                
                // For simple values, show them inline
                if let stringVal = value as? String {
                    result += "\(keyText)String: \"\(stringVal.prefix(50))\"\(stringVal.count > 50 ? "..." : "")\n"
                } else if let numVal = value as? NSNumber {
                    if CFGetTypeID(value as CFTypeRef) == CFBooleanGetTypeID() {
                        result += "\(keyText)Boolean: \(numVal.boolValue ? "true" : "false")\n"
                    } else {
                        result += "\(keyText)Number: \(numVal)\n"
                    }
                } else if value is NSNull {
                    result += "\(keyText)Null\n"
                } else {
                    // For complex values (objects and arrays), add a line break and recursively build tree
                    result += "\(keyText)\n"
                    result += generateJsonTreeView(value, path: childPath, depth: depth + 2, isLast: isLastItem)
                }
            }
        } else if let array = node as? [Any] {
            result += "\(indent)\(prefix)Array [\(array.count) items]\n"
            
            for (index, value) in array.enumerated() {
                let isLastItem = (index == array.count - 1)
                let childPath = "\(path)["+"\(index)"+"]"
                
                // Index representation with type indicator
                let indexText = "\(indent)    \(isLastItem ? "└── " : "├── ")[\(index)]: "
                
                // For simple values, show them inline
                if let stringVal = value as? String {
                    result += "\(indexText)String: \"\(stringVal.prefix(50))\"\(stringVal.count > 50 ? "..." : "")\n"
                } else if let numVal = value as? NSNumber {
                    if CFGetTypeID(value as CFTypeRef) == CFBooleanGetTypeID() {
                        result += "\(indexText)Boolean: \(numVal.boolValue ? "true" : "false")\n"
                    } else {
                        result += "\(indexText)Number: \(numVal)\n"
                    }
                } else if value is NSNull {
                    result += "\(indexText)Null\n"
                } else {
                    // For complex values (objects and arrays), add a line break and recursively build tree
                    result += "\(indexText)\n"
                    result += generateJsonTreeView(value, path: childPath, depth: depth + 2, isLast: isLastItem)
                }
            }
        } else if let stringVal = node as? String {
            result += "\(indent)\(prefix)String: \"\(stringVal.prefix(100))\"\(stringVal.count > 100 ? "..." : "")\n"
        } else if let numVal = node as? NSNumber {
            if CFGetTypeID(node as CFTypeRef) == CFBooleanGetTypeID() {
                result += "\(indent)\(prefix)Boolean: \(numVal.boolValue ? "true" : "false")\n"
            } else {
                result += "\(indent)\(prefix)Number: \(numVal)\n"
            }
        } else if node is NSNull {
            result += "\(indent)\(prefix)Null\n"
        } else {
            result += "\(indent)\(prefix)Unknown Type\n"
        }
        
        return result
    }
}
