//
//  ViewController+JsonEditing.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// MARK: - Text View Touch Handler

/// A protocol to handle direct touches on text views
@objc public protocol TextViewTouchHandling: AnyObject {
    func textViewWasTapped(_ textView: UITextView)
}

// Extension to handle JSON editing functionality
extension ViewController: TextViewTouchHandling, SimpleModalEditorDelegate {
    
    // Handle text view taps
    func textViewWasTapped(_ textView: UITextView) {
        print("Text view was tapped, current edit mode: \(isEditMode)")
        
        // If we're in edit mode, this ensures the text view becomes editable
        if isEditMode && textView === fileContentView {
            print("Ensuring text view is directly editable")
            makeTextViewDirectlyEditable()
            textView.becomeFirstResponder()
        }
    }
    
    // MARK: - SimpleModalEditorDelegate
    
    func modalEditorDidSave(_ editor: SimpleModalEditor, editedText: String) {
        // Process the edited JSON
        processEditedText(editedText)
    }
    
    func modalEditorDidCancel(_ editor: SimpleModalEditor) {
        print("[LOG] modalEditorDidCancel: START")
        // Restore text and JSON object
        if let originalContent = originalJsonContent {
            print("[LOG] modalEditorDidCancel: Restoring original content")
            fileContentView.text = originalContent
            if let data = originalContent.data(using: .utf8) {
                currentJsonObject = try? JSONSerialization.jsonObject(with: data)
                print("[LOG] modalEditorDidCancel: Restored currentJsonObject")
            }
        }
        
        // Reset edit mode state
        isEditMode = false
        fileContentView.isEditable = false
        fileContentView.resignFirstResponder()
        
        DispatchQueue.main.async { [weak self] in
             print("[LOG] modalEditorDidCancel: DispatchQueue START")
            guard let self = self else { 
                 print("[LOG] modalEditorDidCancel: DispatchQueue - self is nil")
                return 
            }
            // REMOVED: Duplicate toolbar removal logic
            /*
             print("[LOG] modalEditorDidCancel: Removing duplicate toolbars")
            for subview in self.view.subviews {
                if subview.accessibilityIdentifier == "actionsToolbar" ||
                   (subview is ModernToolbar && subview != self.mainToolbar) {
                    print("[LOG] modalEditorDidCancel: Removing \(subview.accessibilityIdentifier ?? "ModernToolbar")")
                    subview.removeFromSuperview()
                }
            }
            */
            print("[LOG] modalEditorDidCancel: Toolbar removal logic disabled.")
            
            // REMOVED: Problematic toolbar replacement call
            // print("[LOG] modalEditorDidCancel: Calling replaceWithSimplifiedToolbar")
            // self.replaceWithSimplifiedToolbar()
            
            // Make sure fileContentView is visible and in front
             print("[LOG] modalEditorDidCancel: Ensuring fileContentView visibility")
            self.fileContentView.isHidden = false
            self.view.bringSubviewToFront(self.fileContentView)
            // Refresh the JSON view
             print("[LOG] modalEditorDidCancel: Calling refreshJsonView")
            self.refreshJsonView()
            // Ensure the path navigator shows the current path
             print("[LOG] modalEditorDidCancel: Resetting path navigator")
            self.jsonPathNavigator.resetPath(self.currentPath)
            // Show a confirmation toast
             print("[LOG] modalEditorDidCancel: Showing toast")
            self.showToast(message: "Edit cancelled", type: .info)
            
            print("[LOG] modalEditorDidCancel: DispatchQueue END - Flag reset scheduled")
        }
         print("[LOG] modalEditorDidCancel: END")
    }
    
    // Save JSON edits
    func saveJsonEdits() {
        guard let jsonText = fileContentView.text else {
            showToast(message: "No content to save", type: .error)
            return
        }
        
        // Try to parse the JSON to validate it
        do {
            let data = jsonText.data(using: .utf8)!
            let _ = try JSONSerialization.jsonObject(with: data)
            
            // If we got here, JSON is valid
            originalJsonContent = jsonText
            
            // Try to save to file if a file URL exists
            if let fileUrl = currentFileUrl {
                do {
                    try jsonText.write(to: fileUrl, atomically: true, encoding: .utf8)
                    showToast(message: "Changes saved successfully", type: .success)
                    
                    // Parse and display the new JSON
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        currentJsonObject = jsonObject
                        refreshJsonView()
                    }
                } catch {
                    showToast(message: "Failed to save file: \(error.localizedDescription)", type: .error)
                }
            } else {
                // No file URL, but JSON is valid
                showToast(message: "JSON is valid", type: .success)
                
                // Parse and display the new JSON
                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    currentJsonObject = jsonObject
                    refreshJsonView()
                }
            }
            
            // Exit edit mode
            isEditMode = false
            fileContentView.isEditable = false
            fileContentView.resignFirstResponder()
            if let button = editFab as? UIButton {
                button.setImage(UIImage(systemName: "pencil"), for: .normal)
            }
            editModeOverlay?.hide()
            
        } catch {
            // JSON is invalid
            showToast(message: "Invalid JSON: \(error.localizedDescription)", type: .error)
        }
    }
    
    // Cancel JSON edits
    func cancelJsonEdits() {
        // Restore original content if it exists
        if let originalContent = originalJsonContent {
            fileContentView.text = originalContent
        }
        
        // Restore original highlighted content if available
        if let originalAttrs = originalAttributedText {
            fileContentView.attributedText = originalAttrs
        }
        
        // Exit edit mode
        isEditMode = false
        fileContentView.isEditable = false
        fileContentView.resignFirstResponder()
        
        // Update edit button appearance
        if let button = editFab as? UIButton {
            button.setImage(UIImage(systemName: "pencil"), for: .normal)
        }
        
        // Hide the edit mode overlay if it exists
        editModeOverlay?.hide()
        
        // Use our ultra-simple toolbar implementation -> REMOVED
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // REMOVED: Call to createSimpleCustomToolbar as it no longer exists
            // self.createSimpleCustomToolbar()
            print("[LOG] cancelJsonEdits: Toolbar recreation logic removed.")
            
            // Ensure standard toolbars are visible and correctly laid out
            self.mainToolbar.isHidden = false
            self.view.bringSubviewToFront(self.mainToolbar)
            self.updateUIVisibilityForJsonLoaded(self.currentJsonObject != nil)
            self.view.layoutIfNeeded()

            // Show toast after layout completes
            self.showToast(message: "Edits discarded", type: .info)
        }
    }
    
    // Format JSON for better readability
    @objc func formatJSON() {
        guard let jsonText = fileContentView.text else {
            return
        }
        
        // Try to parse and reformat the JSON
        do {
            let data = jsonText.data(using: .utf8)!
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            // Format with pretty printing
            let formattedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            if let formattedString = String(data: formattedData, encoding: .utf8) {
                // Update text view with formatted JSON and apply syntax highlighting
                let attributedString = jsonHighlighter.highlightJSON(formattedString, font: fileContentView.font)
                fileContentView.attributedText = attributedString
                
                showToast(message: "JSON formatted", type: .success)
            }
        } catch {
            showToast(message: "Could not format JSON: \(error.localizedDescription)", type: .error)
        }
    }
    
    // Refresh the JSON view after edits
    internal func refreshJsonView() {
        print("[LOG] refreshJsonView: START")
        // Reset path to root
        print("[LOG] refreshJsonView: Resetting path")
        currentPath = ["$"]
        
        // Update UI elements
        print("[LOG] refreshJsonView: Updating path navigator")
        jsonPathNavigator.setPath(currentPath)
        print("[LOG] refreshJsonView: Updating minimap")
        // jsonMinimap.setJson(currentJsonObject)
        
        // Apply syntax highlighting
        print("[LOG] refreshJsonView: Calling displayCurrentJson")
        displayCurrentJson()
        print("[LOG] refreshJsonView: END")
    }
    
    // Display the current JSON with appropriate formatting and highlighting
    internal func displayCurrentJson() {
        guard let jsonObject = currentJsonObject else { return }
        
        // Call our local display method
        displayJsonInCurrentFormat()
    }
    
    // Display JSON in the current format (raw or formatted)
    internal func displayJsonInCurrentFormat() {
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
                // Apply syntax highlighting for formatted view
                if !isRawViewMode {
                    let attributedString = jsonHighlighter.highlightJSON(jsonText, font: fileContentView.font)
                    fileContentView.attributedText = attributedString
                } else {
                    // For raw view, just use plain text
                    fileContentView.text = jsonText
                }
                
                // Store the original content (for edit mode)
                if originalJsonContent == nil {
                    originalJsonContent = jsonText
                }
            }
        } catch {
            showToast(message: "Error formatting JSON: \(error.localizedDescription)", type: .error)
        }
    }
}
