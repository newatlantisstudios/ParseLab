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
    
    // Add the raw view toggle button to JSON actions stack view
    internal func addRawViewToggleButtonToActions(_ button: UIButton) {
        // Add to the JSON actions stack view for easy access
        jsonActionsStackView.addArrangedSubview(button)
    }
    
    // This function is already defined in ViewController.swift, so no need to redefine it here
    
    // Toggle between raw and formatted JSON text
    @objc internal func toggleRawView() {
        guard currentJsonObject != nil, isTextModeActive() else {
            return // Only works in text mode with valid JSON
        }
        
        // Toggle the raw view state
        isRawViewMode.toggle()
        
        // Update the toggle button text
        rawViewToggleButton.setTitle(isRawViewMode ? "Formatted" : "Raw", for: .normal)
        
        // Configure text container to ensure proper wrapping
        configureTextViewForJSONDisplay()
        
        // Display the JSON in the appropriate format
        updateJsonDisplayFormat()
        
        // Force layout update after a short delay to ensure wrapping takes effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateTextContainerWidth()
        }
    }
    
    // Display JSON in the current format (raw or formatted) - renamed to avoid conflict
    internal func updateJsonDisplayFormat() {
        guard let jsonObject = currentJsonObject else { return }
        
        do {
            var options: JSONSerialization.WritingOptions = []
            
            // Use pretty printing only for formatted view
            if !isRawViewMode {
                options = [.prettyPrinted, .sortedKeys]
            }
            
            // Convert JSON to text with the appropriate options
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: options)
            
            if let jsonText = String(data: jsonData, encoding: .utf8) {
                // Check if we have our custom bounded text view
                if let boundedTextView = self.boundedTextView {
                    // Apply custom styling with visible border
                    boundedTextView.applyCustomCodeStyle()
                    
                    // Use the specialized method for JSON text display
                    if !isRawViewMode {
                        boundedTextView.setJSONText(jsonText, highlighter: jsonHighlighter)
                    } else {
                        boundedTextView.setJSONText(jsonText)
                    }
                } else {
                    // Fallback to standard text view with improved styling
                    // Configure text container
                    fileContentView.textContainer.widthTracksTextView = true
                    fileContentView.isScrollEnabled = true
                    fileContentView.clipsToBounds = true
                    
                    // Set explicit padding and wrapping
                    fileContentView.textContainerInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
                    fileContentView.contentInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
                    fileContentView.textContainer.lineFragmentPadding = 0
                    fileContentView.textContainer.lineBreakMode = .byCharWrapping
                    
                    // Set proper width
                    let availableWidth = fileContentView.bounds.width - 48 // Increased inset for safety
                    if availableWidth > 0 {
                        fileContentView.textContainer.size = CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
                    }
                    
                    // Create paragraph style
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineBreakMode = .byCharWrapping
                    paragraphStyle.lineSpacing = 2
                    
                    // Apply formatting
                    if !isRawViewMode {
                        let attributedString = jsonHighlighter.highlightJSON(jsonText, font: fileContentView.font)
                        let mutableString = NSMutableAttributedString(attributedString: attributedString)
                        mutableString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: mutableString.length))
                        fileContentView.attributedText = mutableString
                    } else {
                        let attributedString = NSAttributedString(
                            string: jsonText,
                            attributes: [
                                .font: fileContentView.font as Any,
                                .paragraphStyle: paragraphStyle
                            ]
                        )
                        fileContentView.attributedText = attributedString
                    }
                }
                
                // Store the original content (for edit mode)
                if originalJsonContent == nil {
                    originalJsonContent = jsonText
                }
                
                // Force layout update
                fileContentView.setNeedsLayout()
                fileContentView.layoutIfNeeded()
            }
        } catch {
            showToast(message: "Error formatting JSON: \(error.localizedDescription)", type: .error)
        }
    }
}
