//
//  ViewController+RawView.swift
//  ParseLab
//
//  Created by x on 4/26/25.
//

import UIKit

// MARK: - Raw JSON View Toggle

extension ViewController {
    
    // Setup raw view toggle
    internal func setupRawViewToggle() {
        // Create a new toggle button for raw/formatted JSON
        rawViewToggleButton = UIButton(type: .system)
        rawViewToggleButton.setTitle("Raw", for: .normal)
        rawViewToggleButton.translatesAutoresizingMaskIntoConstraints = false
        rawViewToggleButton.addTarget(self, action: #selector(toggleRawView), for: .touchUpInside)
        
        // Add to JSON actions stack view
        addRawViewToggleButtonToActions(rawViewToggleButton)
    }
    
    // Toggle between raw and formatted JSON text
    @objc internal func toggleRawView() {
        guard currentJsonObject != nil, isTextModeActive() else {
            return // Only works in text mode with valid JSON
        }
        
        // Toggle the raw view state
        isRawViewMode.toggle()
        
        // Update the toggle button text
        rawViewToggleButton.setTitle(isRawViewMode ? "Formatted" : "Raw", for: .normal)
        
        // Display the JSON in the appropriate format
        displayJsonInCurrentFormat()
    }
    
    // Display JSON in current format (raw or pretty-printed)
    internal func displayJsonInCurrentFormat() {
        guard let jsonObject = currentJsonObject else { return }
        
        do {
            // Choose options based on current format mode
            let options: JSONSerialization.WritingOptions = isRawViewMode ? [] : [.prettyPrinted, .sortedKeys]
            
            // Convert JSON object to data
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: options)
            
            // Convert data to string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                // Apply appropriate highlighting based on mode
                if isRawViewMode {
                    // For raw mode, minimal styling - just set the string with monospaced font
                    let baseFont = fileContentView.font ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
                    let attributedString = NSAttributedString(
                        string: jsonString,
                        attributes: [.foregroundColor: UIColor.label, .font: baseFont]
                    )
                    fileContentView.attributedText = attributedString
                } else {
                    // For formatted mode, use full syntax highlighting
                    let attributedString = jsonHighlighter.highlightJSON(jsonString, font: fileContentView.font)
                    fileContentView.attributedText = attributedString
                }
            }
        } catch {
            displayError("Error formatting JSON: \(error.localizedDescription)")
        }
    }
}
