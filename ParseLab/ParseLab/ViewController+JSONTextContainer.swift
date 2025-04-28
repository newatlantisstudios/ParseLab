//
//  ViewController+JSONTextContainer.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension to handle JSON text container configuration
extension ViewController {
    
    // Configure text view specifically for JSON display
    internal func configureTextViewForJSONDisplay() {
        // Check if the current fileContentView is actually our BoundedTextView
        if let boundedTextView = self.fileContentView as? BoundedTextView {
            // Apply custom styling with visible border
            print("[DEBUG] configureTextViewForJSONDisplay: Applying BoundedTextView style.")
            boundedTextView.applyCustomCodeStyle()
            return
        }
        
        // Apply code styling to standard text view
        fileContentView.applyCodeViewStyle()
        
        // Use extreme measures to ensure text stays within bounds
        // Configure text container for strict width tracking
        fileContentView.textContainer.widthTracksTextView = true
        fileContentView.textContainer.lineBreakMode = .byCharWrapping
        fileContentView.textContainer.lineFragmentPadding = 0
        
        // Set generous insets to keep content away from edges
        fileContentView.textContainerInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        fileContentView.contentInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        
        // Add visible border and rounded corners
        fileContentView.layer.borderWidth = 1.0
        fileContentView.layer.cornerRadius = 10.0
        if #available(iOS 13.0, *) {
            fileContentView.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            fileContentView.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        // Force clipping to prevent overflow
        fileContentView.clipsToBounds = true
        
        // Calculate available width with increased safety margin
        let availableWidth = fileContentView.bounds.width - 48 // Increased inset for safety
        if availableWidth > 0 {
            // Force text container to use available width
            fileContentView.textContainer.size = CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
        }
    }
}
