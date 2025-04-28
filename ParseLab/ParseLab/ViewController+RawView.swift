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
        print("[DEBUG] toggleRawView: called, isTreeViewVisible=\(isTreeViewVisible), isRawViewMode=\(isRawViewMode)")
        guard currentJsonObject != nil else {
            print("[DEBUG] toggleRawView: No JSON loaded, exiting")
            return
        }
        // If tree view is active, switch back to text view before toggling raw mode
        if isTreeViewVisible {
            print("[DEBUG] toggleRawView: Tree view active—switching to text view")
            switchToTextView(animated: false)
        }
        
        // Toggle the raw view state
        isRawViewMode.toggle()
        print("[DEBUG] toggleRawView: isRawViewMode now=\(isRawViewMode)")
        
        // Update the toggle button text
        rawViewToggleButton.setTitle(isRawViewMode ? "Formatted" : "Raw", for: .normal)
        
        // Configure text container to ensure proper wrapping
        configureTextViewForJSONDisplay()
        
        // Display the JSON in the appropriate format
        updateJsonDisplayFormat()
        
        // Ensure the JSON text view and raw toggle button are visible
        self.fileContentView.isHidden = false
        self.contentStackView.isHidden = false
        self.rawViewToggleButton.isHidden = false
        self.view.bringSubviewToFront(self.contentStackView)
        print("[DEBUG] toggleRawView: fileContentView.text length=\(self.fileContentView.text.count)")
        // Scroll to top of content
        self.fileContentView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        print("[DEBUG] toggleRawView: Frame BEFORE asyncAfter layout: \(self.fileContentView.frame), Hidden: \(self.fileContentView.isHidden)") // Log Frame
        
        // Force layout update after a short delay to ensure wrapping takes effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.updateTextContainerWidth()
            print("[DEBUG] toggleRawView: Frame AFTER asyncAfter layout: \(self.fileContentView.frame), Hidden: \(self.fileContentView.isHidden)") // Log Frame
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
                // Since fileContentView is now guaranteed to be BoundedTextView after replacement,
                // directly use it and its specialized method.
                if let boundedTextView = self.fileContentView as? BoundedTextView {
                     print("[DEBUG] updateJsonDisplayFormat: Using BoundedTextView instance.")
                    boundedTextView.applyCustomCodeStyle()
                    if !isRawViewMode {
                        // Formatted view with syntax highlighting
                        boundedTextView.setJSONText(jsonText, highlighter: jsonHighlighter)
                    } else {
                        // Raw view: display plain JSON text
                        boundedTextView.text = jsonText
                    }
                } else {
                    print("[DEBUG] updateJsonDisplayFormat: Fallback - fileContentView is not BoundedTextView.")
                    if !isRawViewMode {
                        let attributedString = jsonHighlighter.highlightJSON(jsonText, font: fileContentView.font)
                        fileContentView.attributedText = attributedString
                    } else {
                        fileContentView.text = jsonText
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
