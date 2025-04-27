//
//  UIStackView+FlexibleLayout.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

extension UIStackView {
    
    /// Helps resolve auto layout conflicts by making button sizes flexible
    /// Call this method after setting up a stack view with buttons that have fixed size constraints
    func makeButtonsFlexible() {
        // Process all arranged subviews
        for view in arrangedSubviews {
            // Handle buttons
            if let button = view as? UIButton {
                // Remove any fixed size constraints from the button
                for constraint in button.constraints {
                    if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                        // Only remove constraints with fixed values (not constraints to other views)
                        if constraint.secondItem == nil {
                            button.removeConstraint(constraint)
                        }
                    }
                }
                
                // Add flexible size constraints with appropriate priorities
                if button.constraints.filter({ $0.firstAttribute == .height }).isEmpty {
                    // Get the button's intrinsic size
                    let intrinsicSize = button.intrinsicContentSize
                    let height = intrinsicSize.height > 0 ? intrinsicSize.height : 32
                    
                    // Create a preferred height constraint with medium priority
                    let heightConstraint = button.heightAnchor.constraint(equalToConstant: height)
                    heightConstraint.priority = UILayoutPriority(750) // Medium priority
                    heightConstraint.isActive = true
                }
                
                // Set appropriate content hugging and compression resistance priorities
                button.setContentHuggingPriority(.defaultHigh, for: .vertical)
                button.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            }
            
            // Handle custom views like InfoButtonView
            if !(view is UIButton) && !(view is UILabel) {
                // Remove any fixed size constraints
                for constraint in view.constraints {
                    if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                        // Only remove constraints with fixed values
                        if constraint.secondItem == nil {
                            view.removeConstraint(constraint)
                        }
                    }
                }
                
                // Set appropriate content priorities
                view.setContentHuggingPriority(.defaultHigh, for: .vertical)
                view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            }
        }
        
        // Handle stack view itself - make it more flexible if it has fixed height constraints
        if self.axis == .vertical {
            var hasFixedHeight = false
            for constraint in self.constraints {
                if constraint.firstAttribute == .height && constraint.secondItem == nil {
                    // Replace fixed height constraint with a lower priority one
                    hasFixedHeight = true
                    let height = constraint.constant
                    self.removeConstraint(constraint)
                    
                    let flexibleHeight = self.heightAnchor.constraint(equalToConstant: height)
                    flexibleHeight.priority = UILayoutPriority(750) // Medium priority
                    flexibleHeight.isActive = true
                }
            }
            
            // If stack view doesn't have a fixed height but its parent does, handle that
            if !hasFixedHeight && self.superview != nil {
                for constraint in self.superview!.constraints {
                    if constraint.firstAttribute == .height && constraint.firstItem === self.superview {
                        // The parent view has a fixed height, so make sure our stack view is flexible
                        self.setContentHuggingPriority(.defaultLow, for: .vertical)
                        self.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
                    }
                }
            }
        }
    }
    
    /// Apply this method to a stack view to make it flexible when layout conflicts occur
    func makeFlexible() {
        // Make arranged views flexible
        makeButtonsFlexible()
        
        // Also adjust the stack view's own constraints
        if let superview = self.superview {
            for constraint in superview.constraints {
                // Find constraints that affect this stack view's size
                if (constraint.firstItem === self || constraint.secondItem === self) &&
                   (constraint.firstAttribute == .height || constraint.secondAttribute == .height) {
                    
                    // If it's a fixed height constraint on the stack view, reduce its priority
                    if constraint.priority == .required {
                        constraint.priority = UILayoutPriority(999) // High but breakable
                    }
                }
            }
        }
        
        // Make sure stack view can expand/compress as needed
        self.alignment = .fill
        self.distribution = .fill
    }
}
