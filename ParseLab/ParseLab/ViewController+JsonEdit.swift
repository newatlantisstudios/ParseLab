//
//  ViewController+JsonEdit.swift
//  ParseLab
//
//  Created by x on 4/26/25.
//

import UIKit

// MARK: - JSON Editing functionality
extension ViewController {
    
    // Process the edited text
    internal func processEditedText(_ text: String) {
        print("Processing edited text")
        
        // Try to parse and validate JSON
        do {
            // Try to parse the JSON
            let jsonData = text.data(using: .utf8)!
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
            
            // Format with pretty printing
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            if let prettyText = String(data: prettyData, encoding: .utf8) {
                // Update text view with pretty-printed JSON and apply syntax highlighting
                let attributedString = jsonHighlighter.highlightJSON(prettyText, font: fileContentView.font)
                fileContentView.attributedText = attributedString
                
                // Update the stored JSON object
                self.currentJsonObject = jsonObject
                
                // Save to file if we have a URL
                if let url = currentFileUrl {
                    do {
                        try prettyText.write(to: url, atomically: true, encoding: .utf8)
                        showToast(message: "Changes saved successfully", type: .success)
                    } catch {
                        showToast(message: "Error saving file: \(error.localizedDescription)", type: .error)
                    }
                } else {
                    showToast(message: "JSON updated", type: .success)
                }
            }
        } catch {
            showToast(message: "Invalid JSON: \(error.localizedDescription)", type: .error)
            
            // Restore original content if available
            if let attributedText = originalAttributedText {
                fileContentView.attributedText = attributedText
            } else if let originalText = originalJsonContent {
                fileContentView.text = originalText
            }
        }
    }
    
    // Setup editing controls
    internal func setupEditControls() {
        // Only update button state, do not create or add buttons here
        editToggleButton.isHidden = false
        editToggleButton.isEnabled = true
        editToggleButton.setTitle("", for: .normal)

        saveButton.isHidden = !isEditMode
        cancelButton.isHidden = !isEditMode
    }
    
    // Toggle edit mode with improved approach
    @objc internal func toggleEditMode() {
        print("toggleEditMode called")
        
        guard isTextModeActive() else {
            showToast(message: "Edit mode only available in text view", type: .warning)
            return
        }
        
        // Important: Check if we already have content to edit
        guard fileContentView.text != nil && !fileContentView.text.isEmpty else {
            showToast(message: "No content to edit", type: .warning)
            return
        }
        
        // Toggle edit mode state
        isEditMode = !isEditMode
        print("Edit mode toggled to: \(isEditMode)")
        
        // Force editable state based on isEditMode flag
        fileContentView.isEditable = isEditMode
        fileContentView.isSelectable = true
        fileContentView.isUserInteractionEnabled = true
        
        if isEditMode {
            // Entering edit mode
            print("Entering edit mode")
            
            // Store original content
            originalJsonContent = fileContentView.text
            originalAttributedText = fileContentView.attributedText
            
            // Convert to plain text for better editing
            fileContentView.attributedText = nil
            fileContentView.text = originalJsonContent
            
            // Make text view editable and ensure user interaction
            fileContentView.isEditable = true
            fileContentView.isSelectable = true
            fileContentView.isUserInteractionEnabled = true
            
            // Set up editing properties
            fileContentView.autocorrectionType = .no
            fileContentView.spellCheckingType = .no
            if #available(iOS 11.0, *) {
                fileContentView.smartDashesType = .no
                fileContentView.smartQuotesType = .no
            }
            
            // Force keyboard focus with delay to ensure UI updates first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.fileContentView.becomeFirstResponder()
                print("Text view editable state: \(self?.fileContentView.isEditable ?? false)")
            }
            
            // Update edit button appearance
            if let editButton = self.editFab as? UIButton {
                editButton.setTitle("Done", for: .normal)
                editButton.backgroundColor = .systemRed
                if #available(iOS 13.0, *) {
                    editButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                }
            }
            
            // Change text view visual appearance
            fileContentView.backgroundColor = .systemBackground
            fileContentView.layer.borderColor = UIColor.systemBlue.cgColor
            fileContentView.layer.borderWidth = 2
            
            // Show toast to confirm edit mode
            showToast(message: "Edit mode enabled. Tap Done when finished.", type: .info)
        } else {
            // Exiting edit mode - handle the edited content
            let editedText = fileContentView.text ?? ""
            
            // Try to validate and format the JSON
            do {
                if let jsonData = editedText.data(using: .utf8) {
                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
                    
                    // Format with pretty printing
                    let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
                    if let prettyText = String(data: prettyData, encoding: .utf8) {
                        // Update text view with highlighted JSON
                        let attributedString = jsonHighlighter.highlightJSON(prettyText, font: fileContentView.font)
                        fileContentView.attributedText = attributedString
                        currentJsonObject = jsonObject
                    }
                }
                
                // Show success message
                showToast(message: "JSON validated successfully")
                
                // Show edit menu with options
                showEditModeUI(true)
            } catch {
                // If validation fails, still show edit menu
                showErrorMessage("Invalid JSON: \(error.localizedDescription)")
                
                // Restore original formatted content
                if let originalAttrs = originalAttributedText {
                    fileContentView.attributedText = originalAttrs
                }
                
                // Show edit menu anyway
                showEditModeUI(true)
            }
            
            // Reset text view properties
            fileContentView.isEditable = false
            fileContentView.resignFirstResponder()
            
            // Reset appearance
            fileContentView.backgroundColor = .systemGray6
            fileContentView.layer.borderColor = UIColor.systemGray4.cgColor
            fileContentView.layer.borderWidth = 1
            
            // Update edit button
            if let editButton = self.editFab as? UIButton {
                editButton.setTitle("", for: .normal)
                editButton.backgroundColor = .systemBlue
            }
        }
    }
    
    // Update UI for current edit mode
    internal func updateUIForEditMode() {
        print("Updating UI for edit mode: \(isEditMode)")
        
        // Force editable state based on isEditMode flag
        fileContentView.isEditable = isEditMode
        fileContentView.isSelectable = true
        fileContentView.isUserInteractionEnabled = true
        
        // Update button states
        editToggleButton.setTitle("", for: .normal)
        
        // Make save and cancel buttons visible when in edit mode
        saveButton.isHidden = !isEditMode
        cancelButton.isHidden = !isEditMode
        
        // Ensure buttons are brought to front
        if let superview = saveButton.superview {
            superview.bringSubviewToFront(saveButton)
            superview.bringSubviewToFront(cancelButton)
        }
        
        // Hide non-usable controls when in edit mode instead of just disabling them
        rawViewToggleButton.isHidden = isEditMode
        validateButton.isHidden = isEditMode
        searchToggleButton.isHidden = isEditMode
        viewModeSegmentedControl.isHidden = isEditMode
        
        // Make text view editable
        fileContentView.isEditable = isEditMode
        
        // Make text view user-interaction enabled
        fileContentView.isUserInteractionEnabled = true
        
        // Ensure text view becomes first responder when edit mode is enabled
        if isEditMode {
            // Ensure we can properly edit the text view
            prepareTextViewForEditing()
            
            // Show keyboard
            fileContentView.becomeFirstResponder()
            
            // Make text view selectable explicitly
            fileContentView.isSelectable = true
        } else {
            // Reset text view properties when exiting edit mode
            fileContentView.isSelectable = true // Keep selectable for copying
            fileContentView.resignFirstResponder()
        }
        
        // Change text view appearance based on edit mode
        if isEditMode {
            // Store original content for cancel operation
            originalJsonContent = fileContentView.text
            
            // Change background to indicate edit mode
            fileContentView.backgroundColor = .systemBackground
            fileContentView.layer.borderColor = UIColor.systemBlue.cgColor
            fileContentView.layer.borderWidth = 2
            
            // Update edit button if it's a standard button
            if let editButton = editFab as? UIButton {
                editButton.setTitle("Done", for: .normal)
                editButton.backgroundColor = .systemRed
                if #available(iOS 13.0, *) {
                    editButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                }
            }
            // Update FAB icon if it's a FloatingActionButton
            else if let fab = editFab as? FloatingActionButton {
                if #available(iOS 13.0, *) {
                    fab.setImage(UIImage(systemName: "xmark"), for: .normal)
                }
            }
            
            // No need to call showEditModeUI here as it's called from ViewController+MainUI.swift
        } else {
            // Reset appearance
            fileContentView.backgroundColor = .systemGray6
            fileContentView.layer.borderColor = UIColor.systemGray4.cgColor
            fileContentView.layer.borderWidth = 1
            
            // Restore the original attributed text if available
            if let attributedText = originalAttributedText {
                fileContentView.attributedText = attributedText
                originalAttributedText = nil
            }
            
            // Update edit button if it's a standard button
            if let editButton = editFab as? UIButton {
                editButton.setTitle("", for: .normal)
                editButton.backgroundColor = .systemBlue
                if #available(iOS 13.0, *) {
                    editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
                }
            }
            // Update FAB icon if it's a FloatingActionButton
            else if let fab = editFab as? FloatingActionButton {
                if #available(iOS 13.0, *) {
                    fab.setImage(UIImage(systemName: "pencil"), for: .normal)
                }
            }
            
            // No need to call showEditModeUI here as it's called from ViewController+MainUI.swift
        }
        
        // Always make sure the edit button is visible
        if let editButton = editFab as? UIButton {
            editButton.isHidden = false
            editButton.alpha = 1.0
            if let superview = editButton.superview {
                superview.bringSubviewToFront(editButton)
            }
        }
    }
    
    // Helper function to ensure text view is properly editable
    internal func makeTextViewDirectlyEditable() {
        print("Making text view directly editable")
        
        // Force editable state
        fileContentView.isEditable = true
        
        // Make the text view properly interactive
        fileContentView.isUserInteractionEnabled = true
        
        // Ensure the text view can be selected and edited
        fileContentView.isSelectable = true
        
        // Store any attributed text as plain text to avoid editing issues
        if let attributedText = fileContentView.attributedText {
            originalAttributedText = attributedText
            fileContentView.attributedText = nil
            fileContentView.text = attributedText.string
        }
        
        // Reset auto-correction to improve typing experience
        fileContentView.autocorrectionType = .no
        fileContentView.spellCheckingType = .no
        if #available(iOS 11.0, *) {
            fileContentView.smartDashesType = .no
            fileContentView.smartQuotesType = .no
        }
        
        // Set text container properties for better editing
        fileContentView.textContainer.lineBreakMode = .byWordWrapping
        
        // Set background to make it visually apparent it's editable
        fileContentView.backgroundColor = .systemBackground
        
        // Ensure foreground/text color is visible
        fileContentView.textColor = .black
        if #available(iOS 13.0, *) {
            fileContentView.textColor = .label
        }
        
        // Store content offset to maintain scroll position
        let currentOffset = fileContentView.contentOffset
        
        // Force layout update
        fileContentView.layoutIfNeeded()
        
        // Restore content offset after layout
        fileContentView.contentOffset = currentOffset
        
        // Try to make it the first responder explicitly
        DispatchQueue.main.async { [weak self] in
            self?.fileContentView.becomeFirstResponder()
        }
    }
    
    // Save changes made to JSON
    @objc internal func saveJsonChanges() {
        guard isEditMode else {
            return
        }
        
        // Get the edited text
        guard let editedText = fileContentView.text, !editedText.isEmpty else {
            showErrorMessage("Error: Empty content cannot be saved")
            return
        }
        
        // Check if this is a sample file (which is read-only)
        let isSampleFile = currentFileUrl?.absoluteString.contains("/sample.json") ?? false
        if isSampleFile {
            // For sample files, we can't save to the original location but we can update the view
            showToast(message: "Sample file is read-only. Changes will be displayed but not saved permanently.", type: .warning)
        } else if currentFileUrl == nil {
            // No file URL, can't save to a file
            showToast(message: "No file location available. Changes will be displayed but not saved permanently.", type: .warning)
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
            
            // Save to file if we have a valid URL and it's not a sample file
            let isSampleFile = currentFileUrl?.absoluteString.contains("/sample.json") ?? false
            if let currentUrl = currentFileUrl, !isSampleFile {
                saveJsonToFile(jsonObject: jsonObject, url: currentUrl)
                showToast(message: "JSON saved successfully")
            } else {
                // For sample files or when no URL is available, just update the UI
                showToast(message: "JSON validated and updated in view")
            }
            
            // Exit edit mode
            isEditMode = false
            updateUIForEditMode()
            
            // Hide keyboard
            fileContentView.resignFirstResponder()
            
            // Also hide edit mode overlay
            showEditModeUI(false)
        } catch {
            // Show error if JSON is invalid
            showErrorMessage("Invalid JSON: \(error.localizedDescription)")
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
            showErrorMessage("Error saving file: \(error.localizedDescription)")
        }
    }
    
    // Cancel editing and revert changes
    @objc internal func cancelEditing() {
         print("[LOG] cancelEditing: START")
        
        // Create a flag to track if we're in the midst of canceling edit
        let isAlreadyCanceling = !isEditMode
         print("[LOG] cancelEditing: isAlreadyCanceling = \(isAlreadyCanceling)")
        
        // Exit edit mode
        isEditMode = false
         print("[LOG] cancelEditing: Calling updateUIForEditMode")
        updateUIForEditMode() // This might hide elements, restore later
        
        // Hide keyboard
         print("[LOG] cancelEditing: Resigning first responder")
        fileContentView.resignFirstResponder()
        
        // Hide edit mode overlay if it exists
         print("[LOG] cancelEditing: Hiding edit mode UI")
        showEditModeUI(false)
        
        // Restore original text and JSON object
        if let originalContent = originalJsonContent {
             print("[LOG] cancelEditing: Restoring original content")
            fileContentView.text = originalContent
            if let data = originalContent.data(using: .utf8) {
                currentJsonObject = try? JSONSerialization.jsonObject(with: data)
                 print("[LOG] cancelEditing: Restored currentJsonObject")
            }
        }
        
        // Only show toast if this isn't a duplicate call
        if !isAlreadyCanceling {
             print("[LOG] cancelEditing: Showing toast")
            showToast(message: "Edits cancelled")
        }
        
        // ENSURE UI REMAINS CORRECTLY POSITIONED
        DispatchQueue.main.async { [weak self] in
             print("[LOG] cancelEditing: DispatchQueue START")
            guard let self = self else { 
                 print("[LOG] cancelEditing: DispatchQueue - self is nil")
                return 
            }
            
             print("[LOG] cancelEditing: DispatchQueue - Ensuring UI position")
            
            // Use simplified toolbar for more reliable positioning (also handles secondary bar)
             print("[LOG] cancelEditing: DispatchQueue - Calling replaceWithSimplifiedToolbar")
            self.replaceWithSimplifiedToolbar()
            
            // Make sure fileContentView is visible and in front
             print("[LOG] cancelEditing: DispatchQueue - Ensuring fileContentView visibility")
            self.fileContentView.isHidden = false
            self.view.bringSubviewToFront(self.fileContentView)
            
            // Refresh the JSON view
             print("[LOG] cancelEditing: DispatchQueue - Calling refreshJsonView")
            self.refreshJsonView()
            
            // Ensure the path navigator shows the current path
             print("[LOG] cancelEditing: DispatchQueue - Resetting path navigator")
            self.jsonPathNavigator.resetPath(self.currentPath)
            
             print("[LOG] cancelEditing: DispatchQueue END - Flag reset scheduled") // Keep log for now
        }
         print("[LOG] cancelEditing: END")
    }
    
    // Format JSON in the text view
    @objc internal func formatJson() {
        guard let jsonText = fileContentView.text, !jsonText.isEmpty else {
            showToast(message: "No content to format", type: .warning)
            return
        }
        
        print("Formatting JSON content, edit mode: \(isEditMode)")
        
        
        do {
            // Parse the current content
            let jsonData = jsonText.data(using: .utf8)!
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
            
            // Format the JSON with pretty-printing
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            if let prettyText = String(data: prettyData, encoding: .utf8) {
                // Update text view with formatted JSON
                let attributedString = jsonHighlighter.highlightJSON(prettyText, font: fileContentView.font)
                fileContentView.attributedText = attributedString
                
                // Show success message
                showToast(message: "JSON formatted successfully")
            }
        } catch {
            // Show error if JSON is invalid
            showErrorMessage("Cannot format invalid JSON: \(error.localizedDescription)")
        }
    }
    
    // Prepare text view for editing - ensure it can properly handle user input
    internal func prepareTextViewForEditing() {
        // Make sure text container properties are suitable for editing
        fileContentView.textContainer.lineBreakMode = .byWordWrapping  // Less strict line breaking while editing
        
        // Convert attributed text to plain text for better editing
        if let attributedText = fileContentView.attributedText {
            // Store original attributed text for restoration later if needed
            originalAttributedText = attributedText
            
            // Set plain text for easier editing
            fileContentView.text = attributedText.string
        }
        
        // Ensure the cursor color is visible and text view is responsive
        if #available(iOS 13.0, *) {
            fileContentView.tintColor = .systemBlue  // Set cursor color to blue
        } else {
            fileContentView.tintColor = .blue
        }
        
        // Make sure keyboard gets proper input events
        fileContentView.autocorrectionType = .no   // Disable autocorrection for JSON
        fileContentView.spellCheckingType = .no    // Disable spell checking for JSON
        fileContentView.smartDashesType = .no      // Disable smart dashes for JSON
        fileContentView.smartQuotesType = .no      // Disable smart quotes for JSON
        
        // Add input accessory view for editing convenience
        if fileContentView.inputAccessoryView == nil {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            // Add format button and done button
            let formatButton = UIBarButtonItem(title: "Format", style: .plain, target: self, action: #selector(formatJson))
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
            
            toolbar.items = [formatButton, flexSpace, doneButton]
            fileContentView.inputAccessoryView = toolbar
        }
    }
    
    // Dismiss keyboard
    @objc internal func dismissKeyboard() {
        fileContentView.resignFirstResponder()
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
        // Use the enhanced toast from ViewController+Setup instead for consistency
        showEnhancedToast(message: message, type: ViewController.ToastType.info)
    }
}
