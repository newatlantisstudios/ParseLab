//
//  ViewController+KeyboardHandling.swift
//  ParseLab
//
//  Created on 4/27/25.
//

import UIKit

// Extension to handle keyboard events
extension ViewController {
    
    // Setup keyboard notifications
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
    }
    
    // Handle keyboard appearing
    @objc func keyboardWillShow(notification: NSNotification) {
        guard isEditMode else { return }
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // Calculate keyboard height relative to the view
            let keyboardHeight = keyboardSize.height
            
            // Adjust content inset to make room for keyboard
            let contentInsets = UIEdgeInsets(
                top: fileContentView.contentInset.top,
                left: fileContentView.contentInset.left,
                bottom: keyboardHeight,
                right: fileContentView.contentInset.right
            )
            
            // Apply insets to text view
            fileContentView.contentInset = contentInsets
            fileContentView.scrollIndicatorInsets = contentInsets
            
            // Add extra spacing to bottom of container to avoid the keyboard covering the text
            contentStackView.layoutMargins.bottom = keyboardHeight
        }
    }
    
    // Handle keyboard disappearing
    @objc func keyboardWillHide(notification: NSNotification) {
        // Reset content inset
        let contentInsets = UIEdgeInsets(
            top: fileContentView.contentInset.top,
            left: fileContentView.contentInset.left,
            bottom: 0,
            right: fileContentView.contentInset.right
        )
        
        // Apply insets to text view
        fileContentView.contentInset = contentInsets
        fileContentView.scrollIndicatorInsets = contentInsets
        
        // Reset extra spacing
        contentStackView.layoutMargins.bottom = 16
    }
    
    // Handle keyboard fully shown
    @objc func keyboardDidShow(notification: NSNotification) {
        guard isEditMode, fileContentView.isFirstResponder else { return }
        
        // Scroll to active text selection if any
        if let selectedRange = fileContentView.selectedTextRange {
            let cursorRect = fileContentView.caretRect(for: selectedRange.start)
            
            // Add some padding around cursor for better visibility
            let visibleRect = cursorRect.insetBy(dx: -50, dy: -50)
            
            // Scroll to ensure cursor is visible
            fileContentView.scrollRectToVisible(visibleRect, animated: true)
        }
    }
    
    // Call this when entering edit mode
    func prepareForEditing() {
        // Make text view editable
        fileContentView.isEditable = true
        
        // Enable user interaction
        fileContentView.isUserInteractionEnabled = true
        
        // Make text view first responder to show keyboard
        fileContentView.becomeFirstResponder()
        
        // Apply input accessory view for easier editing if needed
        applyInputAccessoryViewIfNeeded()
    }
    
    // Apply input accessory view with useful editing buttons
    private func applyInputAccessoryViewIfNeeded() {
        // Create input accessory view with useful buttons if it doesn't exist already
        if fileContentView.inputAccessoryView == nil {
            // Create toolbar
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            // Create format button
            let formatButton = UIBarButtonItem(title: "Format JSON", style: .plain, target: self, action: #selector(formatJson))
            
            // Create done button
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
            
            // Add flexible space
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            // Configure toolbar
            toolbar.items = [formatButton, flexSpace, doneButton]
            
            // Set as input accessory view
            fileContentView.inputAccessoryView = toolbar
        }
    }
}
