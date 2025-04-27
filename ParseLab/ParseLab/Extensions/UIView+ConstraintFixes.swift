//
//  UIView+ConstraintFixes.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

extension UIView {
    
    /// Fixes constraint conflicts by adjusting priorities of fixed size constraints
    /// Call this method when you encounter unsatisfiable constraint errors
    func fixConstraintConflicts() {
        // First make fixed dimensions more flexible
        makeFixedDimensionsFlexible()
        
        // Then recursively fix all subviews
        for subview in subviews {
            subview.fixConstraintConflicts()
            
            // Special handling for stack views
            if let stackView = subview as? UIStackView {
                stackView.makeFlexible()
            }
        }
    }
    
    /// Makes any fixed size constraints more flexible by lowering their priority
    private func makeFixedDimensionsFlexible() {
        // Find any fixed width or height constraints and make them flexible
        for constraint in constraints {
            if (constraint.firstAttribute == .width || constraint.firstAttribute == .height) && 
               constraint.secondItem == nil && 
               constraint.priority == .required {
                
                // Store the constant value
                let constant = constraint.constant
                
                // Remove the required constraint
                removeConstraint(constraint)
                
                // Create a new constraint with lower priority
                let flexibleConstraint: NSLayoutConstraint
                if constraint.firstAttribute == .width {
                    flexibleConstraint = widthAnchor.constraint(equalToConstant: constant)
                } else {
                    flexibleConstraint = heightAnchor.constraint(equalToConstant: constant)
                }
                
                // Use high but breakable priority
                flexibleConstraint.priority = UILayoutPriority(750)
                flexibleConstraint.isActive = true
            }
        }
        
        // For buttons and similar controls, ensure proper content priorities
        if self is UIControl {
            self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            self.setContentHuggingPriority(.defaultHigh, for: .vertical)
            self.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            self.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        }
    }
    
    /// Call this method on the root view controller's view to fix all constraint issues
    func fixAllConstraintIssues() {
        // First fix constraints in this view hierarchy
        fixConstraintConflicts()
        
        // Then perform special handling for vertical stack views with fixed height parents
        findAndFixVerticalStackViewsWithFixedHeightParents(in: self)
        
        // Finally, fix any ModernToolbar constraints specifically
        findAndFixModernToolbars(in: self)
    }
    
    /// Find and fix all ModernToolbar instances in the view hierarchy
    private func findAndFixModernToolbars(in view: UIView) {
        // Check if this is a ModernToolbar
        if let toolbar = view as? ModernToolbar {
        toolbar.fixConstraintIssues()
        } else if view.accessibilityIdentifier == "mainToolbar" {
        // Handle mainToolbar if it's not a ModernToolbar
        for subview in view.subviews {
        if let button = subview as? UIButton {
        // Make buttons more flexible
        for constraint in button.constraints {
        if (constraint.firstAttribute == .height || constraint.firstAttribute == .width) &&
        constraint.secondItem == nil && constraint.priority == .required {
        button.removeConstraint(constraint)
        }
        }
        
        // Set appropriate priorities
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        }
        }
        }
        
        // Recursively check all subviews
        for subview in view.subviews {
            findAndFixModernToolbars(in: subview)
        }
    }
    
    /// Find and fix vertical stack views that have fixed height parent views
    private func findAndFixVerticalStackViewsWithFixedHeightParents(in view: UIView) {
        // Process all subviews
        for subview in view.subviews {
            // Check if this is a vertical stack view
            if let stackView = subview as? UIStackView, stackView.axis == .vertical {
                // Check if parent view has a fixed height constraint
                var parentHasFixedHeight = false
                for constraint in view.constraints {
                    if constraint.firstAttribute == .height && constraint.firstItem === view {
                        parentHasFixedHeight = true
                        break
                    }
                }
                
                // If parent has fixed height, adjust the stack view
                if parentHasFixedHeight {
                    // Remove any fixed height constraints on buttons
                    for arrangedSubview in stackView.arrangedSubviews {
                        if let button = arrangedSubview as? UIButton {
                            for constraint in button.constraints {
                                if constraint.firstAttribute == .height && constraint.secondItem == nil {
                                    button.removeConstraint(constraint)
                                }
                            }
                        }
                    }
                    
                    // Also fix distribution and spacing
                    stackView.distribution = .fillEqually
                    stackView.spacing = 0  // Minimize spacing to avoid conflicts
                }
            }
            
            // Recursively check subviews
            findAndFixVerticalStackViewsWithFixedHeightParents(in: subview)
        }
    }
}
