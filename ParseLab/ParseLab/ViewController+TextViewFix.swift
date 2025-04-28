//
//  ViewController+TextViewFix.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension to replace the standard UITextView with our custom BoundedTextView
extension ViewController {
    
    /// Replaces the standard text view with our custom bounded text view
    func replaceWithBoundedTextView() {
        // Get the current text content and attributes
        let currentText = fileContentView.text
        let currentAttributedText = fileContentView.attributedText
        let currentFont = fileContentView.font
        let currentTextColor = fileContentView.textColor
        let currentDelegate = fileContentView.delegate
        let currentIsEditable = fileContentView.isEditable
        let currentIsSelectable = fileContentView.isSelectable
        
        // Remember the current frame and constraints
        let currentFrame = fileContentView.frame
        let currentSuperview = fileContentView.superview
        
        // Create our custom bounded text view
        let boundedTextView = BoundedTextView(frame: currentFrame)
        boundedTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Copy all the relevant properties
        boundedTextView.delegate = currentDelegate
        boundedTextView.isEditable = currentIsEditable
        boundedTextView.isSelectable = currentIsSelectable
        boundedTextView.font = currentFont
        boundedTextView.textColor = currentTextColor
        
        // Replace in view hierarchy
        if let stackView = currentSuperview as? UIStackView {
            // Find the index of the fileContentView in the stack view
            if let index = stackView.arrangedSubviews.firstIndex(of: fileContentView) {
                // Remove the old view
                fileContentView.removeFromSuperview()
                
                // Insert the new view at the same index
                stackView.insertArrangedSubview(boundedTextView, at: index)
            }
        } else {
            // Standard view replacement
            currentSuperview?.addSubview(boundedTextView)
            
            // Copy constraints
            fileContentView.constraints.forEach { constraint in
                let firstItem = constraint.firstItem === fileContentView ? boundedTextView : constraint.firstItem
                let secondItem = constraint.secondItem === fileContentView ? boundedTextView : constraint.secondItem
                
                let newConstraint = NSLayoutConstraint(
                    item: firstItem as Any,
                    attribute: constraint.firstAttribute,
                    relatedBy: constraint.relation,
                    toItem: secondItem,
                    attribute: constraint.secondAttribute,
                    multiplier: constraint.multiplier,
                    constant: constraint.constant
                )
                
                newConstraint.priority = constraint.priority
                newConstraint.isActive = true
            }
            
            // Remove old view
            fileContentView.removeFromSuperview()
        }
        
        // Apply custom styling with visible border
        boundedTextView.applyCustomCodeStyle()
        
        // Restore the content AFTER replacement and styling
        print("[DEBUG] replaceWithBoundedTextView: Attempting to restore content.")
        if let attributedText = currentAttributedText, attributedText.length > 0 {
            boundedTextView.attributedText = attributedText
            print("[DEBUG] replaceWithBoundedTextView: Restored attributed text (length: \(attributedText.length)).")
        } else if let text = currentText, !text.isEmpty {
            boundedTextView.text = text
            print("[DEBUG] replaceWithBoundedTextView: Restored plain text (length: \(text.count)).")
        } else {
            print("[DEBUG] replaceWithBoundedTextView: No text content found to restore (attributed length: \(currentAttributedText?.length ?? 0), plain length: \(currentText?.count ?? 0)).")
        }
        
        // Force layout after setting content
        print("[DEBUG] replaceWithBoundedTextView: Forcing layout after restoring content.")
        boundedTextView.setNeedsLayout()
        boundedTextView.layoutIfNeeded()
        
        // --- UPDATE THE VIEW CONTROLLER'S REFERENCE --- 
        print("[DEBUG] replaceWithBoundedTextView: Updating self.fileContentView reference.")
        self.fileContentView = boundedTextView // Update the main property
    }
}
