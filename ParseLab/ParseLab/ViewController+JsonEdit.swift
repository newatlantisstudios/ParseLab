//
//  ViewController+JsonEdit.swift
//  ParseLab
//
//  Created by x on 4/26/25.
//

import UIKit

// MARK: - JSON Editing functionality
extension ViewController {
    
    // Setup editing controls
    internal func setupEditControls() {
        // Create edit toggle button
        editToggleButton = UIButton(type: .system)
        editToggleButton.setTitle("Edit", for: .normal)
        editToggleButton.translatesAutoresizingMaskIntoConstraints = false
        editToggleButton.addTarget(self, action: #selector(toggleEditMode), for: .touchUpInside)
        editToggleButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        editToggleButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Create save button
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveJsonChanges), for: .touchUpInside)
        saveButton.isHidden = true // Initially hidden
        saveButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        saveButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Create cancel button
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelEditing), for: .touchUpInside)
        cancelButton.isHidden = true // Initially hidden
        cancelButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        cancelButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Add to JSON actions stack view
        jsonActionsStackView.addArrangedSubview(editToggleButton)
        jsonActionsStackView.addArrangedSubview(saveButton)
        jsonActionsStackView.addArrangedSubview(cancelButton)
    }
    
    // Toggle edit mode
    @objc internal func toggleEditMode() {
        guard currentJsonObject != nil, isTextModeActive() else {
            return // Only works in text mode with valid JSON
        }
        
        // Toggle edit mode
        isEditMode.toggle()
        
        // Update UI based on edit mode
        updateUIForEditMode()
    }
    
    // Update UI for current edit mode
    internal func updateUIForEditMode() {
        // Update button states
        editToggleButton.setTitle(isEditMode ? "Edit Mode" : "Edit", for: .normal)
        saveButton.isHidden = !isEditMode
        cancelButton.isHidden = !isEditMode
        
        // Hide non-usable controls when in edit mode instead of just disabling them
        rawViewToggleButton.isHidden = isEditMode
        validateButton.isHidden = isEditMode
        searchToggleButton.isHidden = isEditMode
        viewModeSegmentedControl.isHidden = isEditMode
        
        // Make text view editable
        fileContentView.isEditable = isEditMode
        
        // Change text view appearance based on edit mode
        if isEditMode {
            // Store original content for cancel operation
            originalJsonContent = fileContentView.text
            
            // Change background to indicate edit mode
            fileContentView.backgroundColor = .systemBackground
            fileContentView.layer.borderColor = UIColor.systemBlue.cgColor
            fileContentView.layer.borderWidth = 2
        } else {
            // Reset appearance
            fileContentView.backgroundColor = .systemGray6
            fileContentView.layer.borderColor = UIColor.systemGray4.cgColor
            fileContentView.layer.borderWidth = 1
        }
    }
    
    // Save changes made to JSON
    @objc internal func saveJsonChanges() {
        guard isEditMode, let currentUrl = currentFileUrl else {
            return
        }
        
        // Get the edited text
        guard let editedText = fileContentView.text, !editedText.isEmpty else {
            displayError("Error: Empty content cannot be saved")
            return
        }
        
        // Validate JSON
        do {
            // Check if the JSON is valid
            let jsonData = editedText.data(using: .utf8)!
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
            
            // Format the JSON to pretty-print
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            if let prettyText = String(data: prettyData, encoding: .utf8) {
                // First update the UI with pretty-printed version
                let attributedString = jsonHighlighter.highlightJSON(prettyText, font: fileContentView.font)
                fileContentView.attributedText = attributedString
            }
            
            // Update the stored JSON object
            self.currentJsonObject = jsonObject
            
            // Save to file
            saveJsonToFile(jsonObject: jsonObject, url: currentUrl)
            
            // Exit edit mode
            isEditMode = false
            updateUIForEditMode()
            
            // Show success message
            showToast(message: "JSON saved successfully")
        } catch {
            // Show error if JSON is invalid
            displayError("Invalid JSON: \(error.localizedDescription)")
        }
    }
    
    // Save JSON to file
    internal func saveJsonToFile(jsonObject: Any, url: URL) {
        do {
            // Convert to data
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            
            // Access security-scoped resource
            let shouldStopAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if shouldStopAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            // Write to file
            try jsonData.write(to: url)
        } catch {
            displayError("Error saving file: \(error.localizedDescription)")
        }
    }
    
    // Cancel editing and revert changes
    @objc internal func cancelEditing() {
        // Exit edit mode
        isEditMode = false
        updateUIForEditMode()
        
        // Restore original content if available
        if let originalContent = originalJsonContent {
            fileContentView.text = originalContent
            
            // Re-highlight the original content
            if let attributedString = parseAndHighlightJson(originalContent) {
                fileContentView.attributedText = attributedString
            }
        }
    }
    
    // Parse and highlight JSON text
    internal func parseAndHighlightJson(_ jsonText: String) -> NSAttributedString? {
        do {
            // Parse JSON to ensure it's valid
            let jsonData = jsonText.data(using: .utf8)!
            _ = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
            
            // Highlight JSON
            return jsonHighlighter.highlightJSON(jsonText, font: fileContentView.font)
        } catch {
            return nil
        }
    }
    
    // Show toast message
    internal func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        toastLabel.textColor = .label
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.layer.borderWidth = 1
        toastLabel.layer.borderColor = UIColor.systemGray3.cgColor
        toastLabel.clipsToBounds = true
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40),
            toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}
