
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
    private let objectColor = UIColor.systemBlue.withAlphaComponent(0.4)
    private let arrayColor = UIColor.systemGreen.withAlphaComponent(0.4)
    private let primitiveColor = UIColor.systemGray.withAlphaComponent(0.3)
    private let viewportColor = UIColor.systemBlue.withAlphaComponent(0.3)
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
        
        // Debug output to verify mapping
        print("Mapped \(nodeMap.count) nodes in JSON structure")
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
                let itemHeight = max(2.0, rect.height / CGFloat(keyCount)) // Ensure minimum height
                
                for (index, key) in keys.enumerated() {
                    let itemRect = CGRect(
                        x: rect.minX + 4, // Indent child items
                        y: rect.minY + CGFloat(index) * itemHeight,
                        width: rect.width - 8, // Make child items narrower
                        height: itemHeight - 1 // Add small gap between items
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
                let itemHeight = max(2.0, rect.height / CGFloat(itemCount)) // Ensure minimum height
                
                for (index, item) in array.enumerated() {
                    let itemRect = CGRect(
                        x: rect.minX + 4, // Indent child items
                        y: rect.minY + CGFloat(index) * itemHeight,
                        width: rect.width - 8, // Make child items narrower
                        height: itemHeight - 1 // Add small gap between items
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
        
        // Skip drawing if rectangle is too small
        if rect.width < 1 || rect.height < 1 {
            return
        }
        
        // Determine color based on node type
        let fillColor: UIColor
        if currentNode is [String: Any] {
            fillColor = objectColor
        } else if currentNode is [Any] {
            fillColor = arrayColor
        } else {
            fillColor = primitiveColor
        }
        
        // Draw the rectangle with rounded corners for better visual distinction
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 2)
        context.addPath(path.cgPath)
        context.setFillColor(fillColor.cgColor)
        context.fillPath()
        
        // Draw border for objects and arrays with more noticeable borders
        if currentNode is [String: Any] || currentNode is [Any] {
            context.addPath(path.cgPath)
            context.setStrokeColor(UIColor.systemGray3.cgColor)
            context.setLineWidth(0.5)
            context.strokePath()
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
            width: max(20, visibleRect.width * xRatio), // Ensure minimum width for visibility
            height: max(20, visibleRect.height * yRatio) // Ensure minimum height for visibility
        )
        
        // Draw the viewport rectangle with a more visible style
        let path = UIBezierPath(roundedRect: viewportRect, cornerRadius: 3)
        context.addPath(path.cgPath)
        context.setFillColor(viewportColor.cgColor)
        context.fillPath()
        
        context.addPath(path.cgPath)
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(1.5)
        context.strokePath()
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
