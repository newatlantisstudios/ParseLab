//
//  FixedPositionActionsBar.swift
//  ParseLab
//
//  Created on 4/27/25.
//

import UIKit
// Import the Extensions module to access ModernToolbar
import Foundation

/// A secondary toolbar that maintains its position even through view hierarchy changes
class FixedPositionActionsBar: UIView {
    
    // Store position information
    private var originalFrame: CGRect?
    private var originalSuperview: UIView?
    private var positionConstraints: [NSLayoutConstraint] = []
    
    // Store references to buttons
    private var buttons: [UIButton] = []
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Set unique identifier for finding this view
        self.accessibilityIdentifier = "actionsToolbar"
        
        // Ensure translatesAutoresizingMaskIntoConstraints is set correctly
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure appearance
        self.backgroundColor = DesignSystem.Colors.backgroundSecondary
        self.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        
        // Apply shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 2
        self.clipsToBounds = false
        
        // Apply border
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.separator.cgColor
        
        // Create KVO observers to monitor position changes
        setupPositionObservers()
    }
    
    // MARK: - Position Tracking
    
    private func setupPositionObservers() {
        // Wait until we're added to view hierarchy
        DispatchQueue.main.async { [weak self] in
            self?.captureOriginalPosition()
        }
    }
    
    func captureOriginalPosition() {
        // Store original frame
        originalFrame = self.frame
        
        // Store original superview
        originalSuperview = self.superview
        
        // Store constraints for top position
        positionConstraints = self.constraints.filter { 
            $0.firstAttribute == .top || 
            $0.secondAttribute == .top ||
            $0.firstAttribute == .topMargin || 
            $0.secondAttribute == .topMargin
        }
        
        // Store all buttons
        buttons = self.subviews.compactMap { $0 as? UIButton }
    }
    
    // MARK: - Position Recovery
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // If we've moved to a new superview, attempt to restore position
        if let originalSuperview = originalSuperview, 
           superview != nil && superview != originalSuperview {
            // Move back to original superview
            originalSuperview.addSubview(self)
            
            // Restore position with constraints
            restoreOriginalPosition()
            
            // This is critical: ensure the entire UI structure is maintained
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let parentViewController = self.findViewController() else { return }
                
                if let viewController = parentViewController as? ViewController {
                    // Ensure all navigation elements are visible
                    // Using direct property access instead of optional binding since pathContainer is non-optional
                    let pathContainer = viewController.pathContainer
                    pathContainer.isHidden = false
                    viewController.view.bringSubviewToFront(pathContainer)
                    
                    // Update UI state
                    viewController.updateUIVisibilityForJsonLoaded(true)
                }
            }
        }
    }
    
    private func restoreOriginalPosition() {
        guard let superview = self.superview else { return }
        
        // Restore position with constraints
        if !positionConstraints.isEmpty {
            // Reactivate stored constraints
            NSLayoutConstraint.activate(positionConstraints)
        } else {
            // Use safe area guide for top position
            let safeArea = superview.safeAreaLayoutGuide
            
            let topConstraint = self.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 80) // Position below main toolbar
            let leadingConstraint = self.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16)
            let trailingConstraint = self.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16)
            let heightConstraint = self.heightAnchor.constraint(equalToConstant: 56)
            
            NSLayoutConstraint.activate([
                topConstraint,
                leadingConstraint,
                trailingConstraint,
                heightConstraint
            ])
            
            // Store these new constraints
            positionConstraints = [topConstraint, leadingConstraint, trailingConstraint, heightConstraint]
        }
        
        // Force layout update
        superview.layoutIfNeeded()
    }
    
    // Find the parent view controller
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
    // Ensure visibility if something tries to hide us
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure all buttons are visible
        for button in buttons {
            button.isHidden = false
            button.alpha = 1.0
        }
        
        // Ensure we're visible
        self.isHidden = false
        self.alpha = 1.0
    }
}

// Extension to replace the actions bar with fixed position version
extension ViewController {
        /// Creates a ModernToolbar wrapper for a FixedPositionActionsBar
    private func createModernToolbarWrapper(for fixedBar: FixedPositionActionsBar) -> ModernToolbar {
        // Create a new ModernToolbar to host the fixed position bar's contents
        let wrapper = ModernToolbar()
        
        // Match the frame size
        wrapper.frame = fixedBar.frame
        
        // Add the fixed bar as a subview to the wrapper
        wrapper.addSubview(fixedBar)
        
        // Apply constraints to make fixedBar fill the wrapper
        fixedBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fixedBar.topAnchor.constraint(equalTo: wrapper.topAnchor),
            fixedBar.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            fixedBar.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            fixedBar.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])
        
        return wrapper
    }
    
    /// Makes the actions bar fixed position to maintain its position
    func makeActionsBarFixedPosition() {
        // No need to check if non-optional property is nil
        // Create fixed position actions bar with existing actions bar's frame
        let fixedActionsBar = FixedPositionActionsBar(frame: actionsBar.frame)
        
        // Copy all subviews from the existing actions bar
        for subview in actionsBar.subviews {
            // Remove from original parent
            subview.removeFromSuperview()
            
            // Add to new fixed position actions bar
            fixedActionsBar.addSubview(subview)
            
            // Center the subview in the fixed actions bar
            if subview.translatesAutoresizingMaskIntoConstraints {
                subview.translatesAutoresizingMaskIntoConstraints = false
                subview.frame = CGRect(x: 0, y: 0, width: fixedActionsBar.frame.width, height: fixedActionsBar.frame.height)
            }
            
            // Apply constraints to center the subview
            NSLayoutConstraint.activate([
                subview.centerXAnchor.constraint(equalTo: fixedActionsBar.centerXAnchor),
                subview.centerYAnchor.constraint(equalTo: fixedActionsBar.centerYAnchor),
                subview.widthAnchor.constraint(lessThanOrEqualTo: fixedActionsBar.widthAnchor, constant: -32),
                subview.heightAnchor.constraint(lessThanOrEqualTo: fixedActionsBar.heightAnchor, constant: -16)
            ])
        }
        
        // Add fixed actions bar to view
        view.addSubview(fixedActionsBar)
        
        // Adjust constraint to match original position, just below main toolbar
        NSLayoutConstraint.activate([
            fixedActionsBar.topAnchor.constraint(equalTo: mainToolbar.bottomAnchor, constant: 16),
            fixedActionsBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            fixedActionsBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            fixedActionsBar.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Remove the original actions bar
        actionsBar.removeFromSuperview()
        
        // Update reference - use type casting or appropriate method to assign to possibly different type
        // Instead of direct assignment which might cause type mismatch
        if let modernToolbar = fixedActionsBar as? ModernToolbar {
            self.actionsBar = modernToolbar
        } else {
            // Create a ModernToolbar wrapper or handle the type difference appropriately
            let wrapper = createModernToolbarWrapper(for: fixedActionsBar)
            self.actionsBar = wrapper
        }
        
        // Force layout
        view.layoutIfNeeded()
        
        // Capture original position
        fixedActionsBar.captureOriginalPosition()
        
        print("Made actions bar fixed position")
    }
}