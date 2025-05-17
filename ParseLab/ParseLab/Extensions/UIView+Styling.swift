//
//  UIView+Styling.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension to provide a more modern styling for UI elements
extension UIView {
    // Apply a modern card-like styling
    func applyCardStyling(cornerRadius: CGFloat = 12) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 3
        self.clipsToBounds = false
        
        // Adapt to dark/light mode
        if #available(iOS 13.0, *) {
            self.backgroundColor = UIColor.secondarySystemBackground
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.separator.cgColor
        } else {
            self.backgroundColor = UIColor.white
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    // Apply a floating action button style
    func applyFloatingButtonStyle(backgroundColor: UIColor? = nil) {
        self.layer.cornerRadius = self.bounds.height / 2
        self.clipsToBounds = true
        
        // Apply background color based on parameter or default theme color
        if let bgColor = backgroundColor {
            self.backgroundColor = bgColor
        } else if #available(iOS 13.0, *) {
            self.backgroundColor = UIColor(named: "AppTheme")
        } else {
            self.backgroundColor = UIColor(red: 0.259, green: 0.463, blue: 0.968, alpha: 1.0)
        }
        
        // Apply shadow for elevation effect
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 4
        self.clipsToBounds = false
    }
}

// Extension for UIButton with modern styling
extension UIButton {
    // Apply a modern button style
    func applyModernStyle(isPrimary: Bool = false, textColor: UIColor? = nil) {
        self.layer.cornerRadius = 10
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        if isPrimary {
            // Primary button styling
            if #available(iOS 13.0, *) {
                self.backgroundColor = UIColor(named: "AppTheme")
                self.setTitleColor(textColor ?? .white, for: .normal)
            } else {
                self.backgroundColor = UIColor(red: 0.259, green: 0.463, blue: 0.968, alpha: 1.0)
                self.setTitleColor(textColor ?? .white, for: .normal)
            }
        } else {
            // Secondary button styling
            if #available(iOS 13.0, *) {
                self.backgroundColor = UIColor.secondarySystemBackground
                self.setTitleColor(textColor ?? UIColor.label, for: .normal)
                self.layer.borderWidth = 0.5
                self.layer.borderColor = UIColor.separator.cgColor
            } else {
                self.backgroundColor = UIColor.white
                self.setTitleColor(textColor ?? DesignSystem.Colors.text, for: .normal)
                self.layer.borderWidth = 0.5
                self.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
        
        // Add subtle shadow
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 2
        self.clipsToBounds = false
    }
    
    // Apply a modern icon button style (just icon, no text)
    func applyIconButtonStyle(tintColor: UIColor? = nil) {
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        if #available(iOS 13.0, *) {
            self.tintColor = tintColor ?? UIColor.label
            self.backgroundColor = UIColor.secondarySystemBackground
        } else {
            self.tintColor = tintColor ?? UIColor.black
            self.backgroundColor = UIColor.white
        }
        
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }
    
    // Apply a tab button style for segmented-control-like functionality
    func applyTabButtonStyle(isSelected: Bool = false) {
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        self.layer.cornerRadius = 8
        
        if isSelected {
            if #available(iOS 13.0, *) {
                self.backgroundColor = UIColor(named: "AppTheme")
                self.setTitleColor(.white, for: .normal)
            } else {
                self.backgroundColor = UIColor(red: 0.259, green: 0.463, blue: 0.968, alpha: 1.0)
                self.setTitleColor(.white, for: .normal)
            }
        } else {
            if #available(iOS 13.0, *) {
                self.backgroundColor = UIColor.secondarySystemBackground
                self.setTitleColor(UIColor.label, for: .normal)
            } else {
                self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                self.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }
}

// Extension for UITextField with modern styling
extension UITextField {
    // This extension has been moved to UIView+DesignSystem.swift
}

// Extension for UITextView with modern styling
extension UITextView {
    // Note: applyModernStyle has been moved to UIView+DesignSystem.swift
    
    // Apply code view style for JSON display
    func applyCodeViewStyle() {
        self.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        self.layer.cornerRadius = 10
        
        // Set colors appropriate for code
        if #available(iOS 13.0, *) {
            self.backgroundColor = UIColor.tertiarySystemBackground
            self.textColor = UIColor.label
        } else {
            self.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            self.textColor = UIColor.black
        }
        
        // Add bold visible border
        self.layer.borderWidth = 1.0
        if #available(iOS 13.0, *) {
            self.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            self.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        // Add subtle shadow
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 2
        
        // Force text to wrap strictly within the container bounds
        self.textContainer.lineBreakMode = .byCharWrapping
        self.textContainer.widthTracksTextView = true
        self.textContainer.heightTracksTextView = false
        self.textContainerInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        
        // Set explicit line width limit to prevent overflow
        self.textContainer.maximumNumberOfLines = 0
        self.textContainer.lineFragmentPadding = 0
        
        // Explicitly set the content inset to ensure proper padding
        self.contentInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        
        // Set text container size to be smaller than the frame to ensure content fits
        let fixedWidth = self.frame.width - 48 // Increased inset for safety
        if fixedWidth > 0 {
            self.textContainer.size = CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        }
        
        // Clip bounds to prevent any overflow
        self.clipsToBounds = true
    }
}
