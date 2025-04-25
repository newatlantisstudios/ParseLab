
//
//  JsonMinimap.swift
//  ParseLab
//
//  Created by x on 4/25/25.
//

import UIKit

class JsonMinimap: UIView {
    // Properties
    private var jsonStructure: Any?
    private var visibleRect: CGRect = .zero
    private var contentSize: CGSize = .zero
    
    // Map between node paths and their visual representation
    private var nodeMap: [String: CGRect] = [:]
    
    // Callback when an area on the minimap is selected
    var onMinimapSelection: ((String) -> Void)?
    
    // Appearance
    private let objectColor = UIColor.systemBlue.withAlphaComponent(0.3)
    private let arrayColor = UIColor.systemGreen.withAlphaComponent(0.3)
    private let primitiveColor = UIColor.systemGray.withAlphaComponent(0.2)
    private let viewportColor = UIColor.systemBlue.withAlphaComponent(0.2)
    private let borderColor = UIColor.systemGray5.cgColor
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        layer.borderWidth = 1
        layer.borderColor = borderColor
        layer.cornerRadius = 8
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Public Methods
    
    // Set the JSON structure to visualize
    func setJsonStructure(_ json: Any) {
        jsonStructure = json
        nodeMap.removeAll()
        
        // Process the structure
        processJsonStructure()
        
        // Trigger redraw
        setNeedsDisplay()
    }
    
    // Update the visible portion of the content
    func updateVisibleRect(_ rect: CGRect, contentSize: CGSize) {
        self.visibleRect = rect
        self.contentSize = contentSize
        setNeedsDisplay()
    }
    
    // MARK: - Private Methods
    
    private func processJsonStructure() {
        guard let json = jsonStructure else { return }
        
        // Clear the node map
        nodeMap.removeAll()
        
        // Start recursively mapping the JSON structure
        let bounds = CGRect(x: 4, y: 4, width: frame.width - 8, height: frame.height - 8)
        mapJsonNode(json, path: "$", in: bounds)
    }
    
    private func mapJsonNode(_ node: Any, path: String, in rect: CGRect) {
        // Store the node's rectangle
        nodeMap[path] = rect
        
        // Process the node based on its type
        if let dict = node as? [String: Any] {
            // For objects, divide the space vertically among its keys
            let keyCount = dict.keys.count
            if keyCount > 0 {
                let keys = dict.keys.sorted()
                let itemHeight = rect.height / CGFloat(keyCount)
                
                for (index, key) in keys.enumerated() {
                    let itemRect = CGRect(
                        x: rect.minX,
                        y: rect.minY + CGFloat(index) * itemHeight,
                        width: rect.width,
                        height: itemHeight
                    )
                    
                    let childPath = "\(path).\(key)"
                    if let childNode = dict[key] {
                        mapJsonNode(childNode, path: childPath, in: itemRect)
                    }
                }
            }
        } else if let array = node as? [Any] {
            // For arrays, divide the space vertically among its items
            let itemCount = array.count
            if itemCount > 0 {
                let itemHeight = rect.height / CGFloat(itemCount)
                
                for (index, item) in array.enumerated() {
                    let itemRect = CGRect(
                        x: rect.minX,
                        y: rect.minY + CGFloat(index) * itemHeight,
                        width: rect.width,
                        height: itemHeight
                    )
                    
                    let childPath = "\(path)[\(index)]"
                    mapJsonNode(item, path: childPath, in: itemRect)
                }
            }
        }
        // For primitive values, we don't need to process further
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Draw the JSON structure nodes
        for (path, nodeRect) in nodeMap {
            drawNode(for: path, in: nodeRect, context: context)
        }
        
        // Draw the viewport indicator if we have valid content size
        if contentSize.width > 0 && contentSize.height > 0 {
            drawViewport(context: context)
        }
    }
    
    private func drawNode(for path: String, in rect: CGRect, context: CGContext) {
        guard let json = jsonStructure else { return }
        
        // Find the node at this path
        var node: Any? = json
        let pathComponents = parsePath(path)
        
        for component in pathComponents.dropFirst() { // Skip the root component
            if let key = component as? String {
                if let dictNode = node as? [String: Any] {
                    node = dictNode[key]
                } else {
                    node = nil
                    break
                }
            } else if let index = component as? Int {
                if let arrayNode = node as? [Any], index < arrayNode.count {
                    node = arrayNode[index]
                } else {
                    node = nil
                    break
                }
            }
        }
        
        guard let currentNode = node else { return }
        
        // Determine color based on node type
        let fillColor: UIColor
        if currentNode is [String: Any] {
            fillColor = objectColor
        } else if currentNode is [Any] {
            fillColor = arrayColor
        } else {
            fillColor = primitiveColor
        }
        
        // Draw the rectangle
        context.setFillColor(fillColor.cgColor)
        context.fill(rect)
        
        // Draw border for objects and arrays
        if currentNode is [String: Any] || currentNode is [Any] {
            context.setStrokeColor(UIColor.systemGray4.cgColor)
            context.setLineWidth(0.5)
            context.stroke(rect)
        }
    }
    
    private func drawViewport(context: CGContext) {
        if contentSize.width <= 0 || contentSize.height <= 0 {
            return
        }
        
        // Calculate the viewport rectangle in minimap coordinates
        let xRatio = frame.width / contentSize.width
        let yRatio = frame.height / contentSize.height
        
        let viewportRect = CGRect(
            x: visibleRect.minX * xRatio,
            y: visibleRect.minY * yRatio,
            width: visibleRect.width * xRatio,
            height: visibleRect.height * yRatio
        )
        
        // Draw the viewport rectangle
        context.setFillColor(viewportColor.cgColor)
        context.fill(viewportRect)
        
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(1.0)
        context.stroke(viewportRect)
    }
    
    // MARK: - Interaction
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        // Find the node that contains this point
        for (path, rect) in nodeMap {
            if rect.contains(location) {
                onMinimapSelection?(path)
                break
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func parsePath(_ path: String) -> [Any] {
        var components: [Any] = []
        
        // Add the root component
        if path.hasPrefix("$") {
            components.append("$")
        }
        
        // Parse the rest of the path
        var index = path.index(after: path.startIndex)
        while index < path.endIndex {
            if path[index] == "." {
                // Object property
                index = path.index(after: index)
                var key = ""
                while index < path.endIndex && path[index] != "." && path[index] != "[" {
                    key.append(path[index])
                    index = path.index(after: index)
                }
                if !key.isEmpty {
                    components.append(key)
                }
            } else if path[index] == "[" {
                // Array index
                index = path.index(after: index)
                var indexStr = ""
                while index < path.endIndex && path[index] != "]" {
                    indexStr.append(path[index])
                    index = path.index(after: index)
                }
                if let arrayIndex = Int(indexStr) {
                    components.append(arrayIndex)
                }
                if index < path.endIndex {
                    index = path.index(after: index)
                }
            } else {
                index = path.index(after: index)
            }
        }
        
        return components
    }
}
