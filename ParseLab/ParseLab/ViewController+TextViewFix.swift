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
        
        // Restore the content
        if let attributedText = currentAttributedText {
            boundedTextView.attributedText = attributedText
        } else if let text = currentText {
            boundedTextView.text = text
        }
        
        // Apply custom styling with visible border
        boundedTextView.applyCustomCodeStyle()
        
        // Store a reference to the bounded text view for future use
        objc_setAssociatedObject(self, &AssociatedKeys.boundedTextViewKey, boundedTextView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Update the current JSON content if available
        if let jsonObject = currentJsonObject {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
                if let jsonText = String(data: jsonData, encoding: .utf8) {
                    boundedTextView.setJSONText(jsonText, highlighter: jsonHighlighter)
                }
            } catch {
                print("Error formatting JSON: \(error.localizedDescription)")
            }
        }
    }
    
    /// Get our custom bounded text view if it exists
    var boundedTextView: BoundedTextView? {
        return objc_getAssociatedObject(self, &AssociatedKeys.boundedTextViewKey) as? BoundedTextView
    }
}

// Keys for associated objects
private struct AssociatedKeys {
    static var boundedTextViewKey = "boundedTextViewKey"
}
