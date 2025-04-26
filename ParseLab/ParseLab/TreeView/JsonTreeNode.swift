
//
//  JsonTreeNode.swift
//  ParseLab
//
//  Created by x on 4/26/25.
//

import Foundation

// Node types for JSON tree view
enum JsonNodeType {
    case object
    case array
    case string
    case number
    case boolean
    case null
}

// Representation of a node in the JSON tree
class JsonTreeNode {
    // Node properties
    let key: String
    let value: Any
    let type: JsonNodeType
    let path: String
    
    // Tree structure
    var parent: JsonTreeNode?
    var children: [JsonTreeNode] = []
    
    // UI state
    var isExpanded: Bool = false
    var level: Int = 0
    
    // Preview of the value (for display)
    var preview: String = ""
    
    // Node constructors
    init(key: String, value: Any, type: JsonNodeType, path: String) {
        self.key = key
        self.value = value
        self.type = type
        self.path = path
        generatePreview()
    }
    
    // Generate a preview string for this node
    private func generatePreview() {
        switch type {
        case .object:
            if let dict = value as? [String: Any] {
                preview = "{ \(dict.count) properties }"
            } else {
                preview = "{ }"
            }
        case .array:
            if let array = value as? [Any] {
                preview = "[ \(array.count) items ]"
            } else {
                preview = "[ ]"
            }
        case .string:
            if let string = value as? String {
                let truncated = string.count > 50 ? string.prefix(50) + "..." : string
                preview = "\"\(truncated)\""
            }
        case .number:
            preview = "\(value)"
        case .boolean:
            if let bool = value as? Bool {
                preview = bool ? "true" : "false"
            }
        case .null:
            preview = "null"
        }
    }
    
    // Get the display name for this node
    func displayName() -> String {
        if key.isEmpty {
            return ""
        }
        
        // Handle array indices (keys with numeric values and square brackets)
        if key.first == "[" && key.last == "]", let _ = Int(key.dropFirst().dropLast()) {
            return key
        }
        
        return key
    }
    
    // Add a child node and set its parent and level
    func addChild(_ node: JsonTreeNode) {
        children.append(node)
        node.parent = self
        node.level = self.level + 1
    }
    
    // Toggle expanded state
    func toggleExpanded() {
        isExpanded = !isExpanded
    }
    
    // Get all visible nodes (for table view)
    func getVisibleNodes() -> [JsonTreeNode] {
        var nodes: [JsonTreeNode] = [self]
        
        if isExpanded {
            for child in children {
                nodes.append(contentsOf: child.getVisibleNodes())
            }
        }
        
        return nodes
    }
    
    // Check if this node has children
    var hasChildren: Bool {
        return !children.isEmpty
    }
    
    // Check if this node can be expanded (objects and arrays)
    var isExpandable: Bool {
        return type == .object || type == .array
    }
}

// Extension to build a tree from JSON
extension JsonTreeNode {
    // Build a tree from JSON data
    static func buildTree(from json: Any, rootKey: String = "Root", path: String = "$") -> JsonTreeNode {
        // Determine the node type
        let nodeType: JsonNodeType
        
        if let _ = json as? [String: Any] {
            nodeType = .object
        } else if let _ = json as? [Any] {
            nodeType = .array
        } else if let _ = json as? String {
            nodeType = .string
        } else if let value = json as? NSNumber {
            // Check if this is a boolean
            if CFGetTypeID(value) == CFBooleanGetTypeID() {
                nodeType = .boolean
            } else {
                nodeType = .number
            }
        } else if json is NSNull {
            nodeType = .null
        } else {
            // Default to treating as string
            nodeType = .string
        }
        
        // Create the node
        let node = JsonTreeNode(key: rootKey, value: json, type: nodeType, path: path)
        
        // Add children if this is an object or array
        if let dict = json as? [String: Any] {
            // Sort keys alphabetically
            let sortedKeys = dict.keys.sorted()
            
            for key in sortedKeys {
                let childPath = path.isEmpty ? key : "\(path).\(key)"
                let childNode = buildTree(from: dict[key]!, rootKey: key, path: childPath)
                node.addChild(childNode)
            }
        } else if let array = json as? [Any] {
            for (index, item) in array.enumerated() {
                let childPath = "\(path)[\(index)]"
                let childNode = buildTree(from: item, rootKey: "[\(index)]", path: childPath)
                node.addChild(childNode)
            }
        }
        
        return node
    }
}
