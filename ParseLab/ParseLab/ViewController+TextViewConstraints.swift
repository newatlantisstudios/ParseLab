//
//  ViewController+TextViewConstraints.swift
//  ParseLab
//
//  Created on 4/27/25.
//

import UIKit

// Extension to handle text view constraints setup
extension ViewController {
    
    /// Set up the constraints for the text view
    func setupTextViewConstraints() {
        guard let superview = fileContentView.superview else {
            print("Error: fileContentView has no superview")
            return
        }
        
        // Ensure translatesAutoresizingMaskIntoConstraints is set to false
        fileContentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Apply standard content insets
        fileContentView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        
        // If the fileContentView is in a stack view, we don't need to set constraints
        if superview is UIStackView {
            // For stack views, we need to ensure content hugging and compression resistance
            fileContentView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            fileContentView.setContentHuggingPriority(.defaultLow, for: .vertical)
            fileContentView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            fileContentView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            return
        }
        
        // When not in a stack view, we need to set up standard constraints
        NSLayoutConstraint.activate([
            fileContentView.topAnchor.constraint(equalTo: superview.topAnchor),
            fileContentView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            fileContentView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            fileContentView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
        
        // Setup code styling and behavior
        configureTextViewForJSONDisplay()
        
        // Force layout update
        fileContentView.setNeedsLayout()
        fileContentView.layoutIfNeeded()
        
        print("Text view constraints set up successfully")
    }
}
