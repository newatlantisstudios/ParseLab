//
//  ViewController+TraitChange.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension to handle trait collection changes
extension ViewController {
    // Update layout when trait collection changes (e.g., rotation, size class changes, or dark/light mode)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update for size class changes
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            updateSearchUILayout(for: traitCollection.horizontalSizeClass)
        }
        
        // Update for dark/light mode changes
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            updateInterfaceForCurrentStyle()
        }
        
        // Update text container width after layout change to fix JSON overflow issues
        DispatchQueue.main.async { [weak self] in
            self?.updateTextContainerWidth()
        }
        
        // Update adaptive button display for compact width
        updateButtonForSizeClass()
    }
    
    // Update text container width to prevent text overflow
    func updateTextContainerWidth() {
        // Calculate the available width for the text container
        let availableWidth = fileContentView.bounds.width - 24 // Account for insets
        
        // Only update if we have a valid width
        if availableWidth > 0 {
            // Force text container to use available width
            fileContentView.textContainer.size = CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
            fileContentView.textContainer.lineFragmentPadding = 0
            fileContentView.textContainer.lineBreakMode = .byCharWrapping
            
            // Re-apply the current content if needed to trigger re-rendering
            if fileContentView.attributedText != nil && currentJsonObject != nil {
                // This will re-wrap the text with the new container width
                updateJsonDisplayFormat()
            }
        }
    }
    
    // Method to update UI for current interface style (light/dark mode)
    func updateInterfaceForCurrentStyle() {
        // Update container borders and backgrounds
        searchContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        searchResultsTableView.layer.borderColor = UIColor.systemGray4.cgColor
        navigationContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        fileContentView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // If we have a JSON file open, reapply syntax highlighting - safely check if all required components exist
        if let jsonContent = fileContentView.text, 
           !jsonContent.isEmpty, 
           !jsonActionsStackView.isHidden, 
           let jsonObject = currentJsonObject {
            // We have JSON content, rehighlight it
            if !isRawViewMode {
                do {
                    let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
                    if let prettyText = String(data: data, encoding: .utf8) {
                        // jsonHighlighter is non-optional
                        let attributedString = jsonHighlighter.highlightJSON(prettyText, font: fileContentView.font)
                        fileContentView.attributedText = attributedString
                    }
                } catch {
                    // If there's an error, just keep the current text
                }
            }
        }
        
        // If file metadata view exists and is visible, update its colors
        if let metadataView = fileMetadataView, !metadataView.isHidden {
            metadataView.updateColorsForCurrentStyle()
        }
    }
}