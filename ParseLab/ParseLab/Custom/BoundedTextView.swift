//
//  BoundedTextView.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

/// A specialized text view that ensures text content stays within its bounds
class BoundedTextView: UITextView {
    
    // MARK: - Initialization
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configureTextView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTextView()
    }
    
    // MARK: - Configuration
    
    private func configureTextView() {
        // Configure text container for strict boundaries
        self.textContainer.lineBreakMode = .byCharWrapping
        self.textContainer.widthTracksTextView = true
        self.textContainer.lineFragmentPadding = 0
        
        // Set generous insets to keep text away from edges
        self.textContainerInset = UIEdgeInsets(top: 40, left: 16, bottom: 40, right: 16)
        self.contentInset = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
        
        // Add visible border
        self.layer.borderWidth = 2.0
        if #available(iOS 13.0, *) {
            self.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            self.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        // Add rounded corners
        self.layer.cornerRadius = 10.0
        
        // Enable clipping to prevent overflow
        self.clipsToBounds = true
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update text container width when view size changes
        updateTextContainerWidth()
    }
    
    // MARK: - Touch Handling
    
    // Override to ensure touch events are properly handled
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEditable {
            // Ensure we become first responder on touch when editable
            if !isFirstResponder {
                _ = becomeFirstResponder()
            }
            
            // Handle touch for cursor positioning
            super.touchesBegan(touches, with: event)
        } else {
            super.touchesBegan(touches, with: event)
        }
    }
    
    // Override canBecomeFirstResponder to ensure we can become first responder when editable
    override var canBecomeFirstResponder: Bool {
        return isEditable || super.canBecomeFirstResponder
    }
    
    private func updateTextContainerWidth() {
        // Calculate safe width (accounting for insets)
        let availableWidth = self.bounds.width - self.textContainerInset.left - self.textContainerInset.right - 16
        
        // Only update if we have a valid width
        if availableWidth > 0 {
            self.textContainer.size = CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
        }
    }
    
    // MARK: - Display Text
    
    /// Sets text with proper styling for JSON display
    func setJSONText(_ text: String, highlighter: JSONHighlighter? = nil) {
        // Add extra padding to the beginning and end of the text
        let paddedText = "\n\n" + text + "\n\n"
        
        // Ensure text container is properly configured
        updateTextContainerWidth()
        
        // Force extreme padding to keep text inside
        self.textContainerInset = UIEdgeInsets(top: 40, left: 16, bottom: 40, right: 16)
        self.contentInset = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
        
        // Ensure solid border and clipping
        self.layer.borderWidth = 2.0 // Even thicker
        self.clipsToBounds = true
        
        if let highlighter = highlighter {
            // Apply syntax highlighting
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byCharWrapping
            paragraphStyle.lineSpacing = 2
            
            let attributedString = highlighter.highlightJSON(paddedText, font: self.font)
            let mutableString = NSMutableAttributedString(attributedString: attributedString)
            
            // Apply paragraph style to the entire text
            mutableString.addAttribute(.paragraphStyle, 
                                      value: paragraphStyle, 
                                      range: NSRange(location: 0, length: mutableString.length))
            
            self.attributedText = mutableString
        } else {
            // Create attributed string with proper paragraph styling
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byCharWrapping
            paragraphStyle.lineSpacing = 2
            paragraphStyle.paragraphSpacing = 20 // Add space between paragraphs
            paragraphStyle.paragraphSpacingBefore = 20 // Add space before paragraphs
            
            let attributedString = NSAttributedString(
                string: paddedText,
                attributes: [
                    .font: self.font as Any,
                    .paragraphStyle: paragraphStyle
                ]
            )
            
            self.attributedText = attributedString
        }
        
        // Force layout update
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // Override to catch potential text changes and ensure proper layout
    override var text: String! {
        didSet {
            updateTextContainerWidth()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            updateTextContainerWidth()
        }
    }
    
    // Custom method to apply code style with visible border
    func applyCustomCodeStyle() {
        // First invoke the extension method on UITextView
        self.applyCodeViewStyle()
        
        // Then apply our custom border styling
        self.layer.borderWidth = 2.0 // Thicker border
        self.layer.cornerRadius = 10.0
        
        // Force extreme padding to keep text inside
        self.textContainerInset = UIEdgeInsets(top: 40, left: 16, bottom: 40, right: 16)
        self.contentInset = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
        
        if #available(iOS 13.0, *) {
            self.layer.borderColor = UIColor.systemGray3.cgColor // More visible color
        } else {
            self.layer.borderColor = UIColor.gray.cgColor // Darker for more contrast
        }
        
        // Add a subtle shadow to make the border more visible
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 3.0
        
        // Force clipping to prevent any overflow
        self.clipsToBounds = true
        
        // Make self opaque with background color to make border visible
        self.backgroundColor = UIColor.tertiarySystemBackground
        self.isOpaque = true
    }
}
