//
//  ViewController+JsonNavigation.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension to handle JSON navigation functionality
extension ViewController {
    
    // Navigate to a specific JSON path
    func navigateToJsonPath(_ path: String) {
        // Update the current path
        self.currentPath = path.components(separatedBy: ".").filter { !$0.isEmpty }
        
        // If the path starts with $ (root), prepend it if not already there
        if !self.currentPath.contains("$") && path.hasPrefix("$") {
            self.currentPath.insert("$", at: 0)
        }
        
        // Update the path navigator display
        jsonPathNavigator.updatePath(self.currentPath)
        
        // Handle scrolling to the content location if in text view mode
        if isTextModeActive() {
            scrollToPathInTextView(path)
        } else {
            // In tree view mode, expand and scroll to the node
            treeViewController.navigateToPath(path)
        }
    }
    
    // Navigate to a specific path by array
    func navigateToPath(_ path: [String]) {
        if !path.isEmpty {
            // Convert array path to string format
            let pathString = buildPathString(path)
            navigateToJsonPath(pathString)
        }
    }
    
    // Build a path string from an array of path components
    private func buildPathString(_ pathComponents: [String]) -> String {
        if pathComponents.isEmpty {
            return "$"
        }
        
        // Start with root if not already included
        var result = ""
        if pathComponents[0] == "$" {
            result = "$"
        } else {
            result = "$." + pathComponents[0]
        }
        
        // Append remaining components
        for component in pathComponents.dropFirst() {
            // Check if it's an array index
            if component.hasPrefix("[") && component.hasSuffix("]") {
                result += component
            } else {
                // It's an object property
                result += "." + component
            }
        }
        
        return result
    }
    
    // Scroll to a specific path in the text view
    private func scrollToPathInTextView(_ path: String) {
        // Only proceed if we have JSON content
        guard let jsonObject = self.currentJsonObject,
              let text = fileContentView.text else {
            return
        }
        
        // Find all keys in our path
        var pathKeys = [String]()
        
        // Parse the path string to extract keys and indices
        let pathComponents = path.components(separatedBy: ".")
        for component in pathComponents.dropFirst() { // Skip the root $
            if component.contains("[") && component.contains("]") {
                // Handle array indices like "items[0]"
                let parts = component.components(separatedBy: CharacterSet(charactersIn: "[]"))
                if parts.count >= 2 {
                    pathKeys.append(parts[0]) // The key name
                    if let indexStr = parts.dropFirst().first, !indexStr.isEmpty {
                        pathKeys.append(indexStr) // The index
                    }
                }
            } else {
                // Regular property key
                pathKeys.append(component)
            }
        }
        
        // Edge case: empty path or just root
        if pathKeys.isEmpty {
            fileContentView.scrollRangeToVisible(NSRange(location: 0, length: 1))
            return
        }
        
        // Try to find each key in the text
        var searchRange = NSRange(location: 0, length: text.count)
        var targetRange: NSRange?
        
        for key in pathKeys {
            // Wrap in quotes for JSON property search
            let searchKey = "\"\(key)\""
            
            if let range = text.range(of: searchKey, options: [], range: Range(searchRange, in: text)) {
                let nsRange = NSRange(range, in: text)
                targetRange = nsRange
                
                // Update search range to continue from this match
                searchRange.location = nsRange.location + nsRange.length
                searchRange.length = text.count - searchRange.location
            }
        }
        
        // Scroll to the target if found
        if let range = targetRange {
            fileContentView.scrollRangeToVisible(range)
            
            // Highlight the range for better visibility
            fileContentView.selectedRange = range
            
            // Clear selection after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.fileContentView.selectedRange = NSRange(location: range.location, length: 0)
            }
        }
    }
    
    // MARK: - Minimap Interaction
    
    // Update the viewport indicator on the minimap
    func updateMinimapViewport() {
        // Only update if we have content and the minimap is visible
        guard jsonMinimap.isHidden == false, fileContentView.contentSize.height > 0 else {
            return
        }
        
        // Get the visible portion of the text view
        let visibleRect = CGRect(
            x: fileContentView.contentOffset.x,
            y: fileContentView.contentOffset.y,
            width: fileContentView.bounds.width,
            height: fileContentView.bounds.height
        )
        
        // Update the minimap with current viewport
        jsonMinimap.updateVisibleRect(visibleRect, contentSize: fileContentView.contentSize)
    }
}
