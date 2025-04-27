//
//  FixedPositionToolbar.swift
//  ParseLab
//
//  Created on 4/27/25.
//

import UIKit

/// A toolbar that maintains its position even through view hierarchy changes
class FixedPositionToolbar: UIView {
    
    // Left button (usually Open)
    var leftButton: UIButton!
    
    // Right button (usually Sample)
    var rightButton: UIButton!
    
    // Store our position for recovery
    private var originalFrame: CGRect?
    private var originalSuperview: UIView?
    private var positionConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Initialization
    
    init(leftTitle: String, leftImage: UIImage?, rightTitle: String, rightImage: UIImage?) {
        super.init(frame: .zero)
        
        // Set unique identifier for finding this view
        self.accessibilityIdentifier = "mainToolbar"
        
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
        
        // Create the left button with simple styling
        leftButton = UIButton(type: .system)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.setTitle(leftTitle, for: .normal)
        leftButton.setImage(leftImage, for: .normal)
        leftButton.backgroundColor = DesignSystem.Colors.primary
        leftButton.setTitleColor(.white, for: .normal)
        leftButton.tintColor = .white
        leftButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        leftButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        // Create the right button with simple styling
        rightButton = UIButton(type: .system)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.setTitle(rightTitle, for: .normal)
        rightButton.setImage(rightImage, for: .normal)
        rightButton.backgroundColor = DesignSystem.Colors.backgroundTertiary
        rightButton.setTitleColor(DesignSystem.Colors.text, for: .normal)
        rightButton.tintColor = DesignSystem.Colors.primary
        rightButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        rightButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        // Add buttons directly to view
        self.addSubview(leftButton)
        self.addSubview(rightButton)
        
        // Create simple but flexible constraints
        // Use low-priority fixed size constraints to avoid conflicts
        let leftWidthConstraint = leftButton.widthAnchor.constraint(equalToConstant: 100)
        leftWidthConstraint.priority = .defaultHigh - 1
        leftWidthConstraint.isActive = true
        
        let rightWidthConstraint = rightButton.widthAnchor.constraint(equalToConstant: 100)
        rightWidthConstraint.priority = .defaultHigh - 1
        rightWidthConstraint.isActive = true
        
        // Use required positioning constraints with minimum spacing
        NSLayoutConstraint.activate([
            // Left button positioning
            leftButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            leftButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            leftButton.heightAnchor.constraint(equalToConstant: 36).withPriority(.defaultHigh),
            
            // Right button positioning
            rightButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            rightButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rightButton.heightAnchor.constraint(equalToConstant: 36).withPriority(.defaultHigh)
        ])
        
        // Create KVO observers to monitor position changes
        setupPositionObservers()
        
        print("Created fixed-position toolbar")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
    }
    
    // MARK: - Position Recovery
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        print("Toolbar didMoveToSuperview called")
        
        // If we've moved to a new superview, attempt to restore position
        if let originalSuperview = originalSuperview, 
           superview != nil && superview != originalSuperview {
            print("Toolbar moved to incorrect superview - restoring")
            
            // Move back to original superview
            originalSuperview.addSubview(self)
            
            // Restore our original position
            restoreOriginalPosition()
            
            // This is critical: ensure the entire UI structure is maintained
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let parentViewController = self.findViewController() else { return }
                
                if let viewController = parentViewController as? ViewController {
                    print("Ensuring complete UI hierarchy after toolbar restoration")
                    
                    // Check for navigation path container visibility
                    viewController.pathContainer.isHidden = false
                    viewController.view.bringSubviewToFront(viewController.pathContainer)
                    
                    // Ensure path container is at the top of the view
                    if let topConstraint = viewController.pathContainer.constraints.first(where: { $0.firstAttribute == .top }) {
                        // If top constraint exists but is incorrect, remove it
                        if topConstraint.secondItem as? UIView != self {
                            topConstraint.isActive = false
                            
                            // Add correct constraint
                            NSLayoutConstraint.activate([
                                viewController.pathContainer.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 8)
                            ])
                        }
                    } else {
                        // If no top constraint exists, add one
                        NSLayoutConstraint.activate([
                            viewController.pathContainer.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 8)
                        ])
                    }
                    
                    // Fix second toolbar visibility
                    viewController.actionsBar.isHidden = false
                    viewController.view.bringSubviewToFront(viewController.actionsBar)
                    
                    // Make sure JSON content is visible
                    viewController.fileContentView.isHidden = false
                    viewController.view.bringSubviewToFront(viewController.fileContentView)
                    
                    // Update UI state
                    viewController.updateUIVisibilityForJsonLoaded(true)
                    
                    // Force layout
                    viewController.view.setNeedsLayout()
                    viewController.view.layoutIfNeeded()
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
            
            let topConstraint = self.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16)
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
        
        // Ensure buttons are visible
        leftButton.isHidden = false
        rightButton.isHidden = false
        
        // Ensure we're visible
        self.isHidden = false
        self.alpha = 1.0
    }
}

// Extension to install the fixed position toolbar
extension ViewController {
    /// Replaces the current toolbar with a fixed position version that maintains its position
    func installFixedPositionToolbar() {
        // Remove existing toolbars from view
        for subview in view.subviews {
            if subview.accessibilityIdentifier == "mainToolbar" {
                subview.removeFromSuperview()
            }
        }
        
        // Create new toolbar with Open and Sample buttons
        let toolbar = FixedPositionToolbar(
            leftTitle: "Open",
            leftImage: UIImage(systemName: "folder"),
            rightTitle: "Sample",
            rightImage: UIImage(systemName: "doc.text")
        )
        
        // Add to view at the top
        view.addSubview(toolbar)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toolbar.heightAnchor.constraint(equalToConstant: 56).withPriority(.defaultHigh)
        ])
        
        // Set button actions
        toolbar.leftButton.addTarget(self, action: #selector(openFileButtonTapped), for: .touchUpInside)
        toolbar.rightButton.addTarget(self, action: #selector(loadSampleButtonTapped), for: .touchUpInside)
        
        // Store references
        self.openButton = toolbar.leftButton
        self.loadSampleButton = toolbar.rightButton
        self.mainToolbar = toolbar
        
        // Set permanent flag to prevent any recreation
        objc_setAssociatedObject(self, "toolbarIsFixed", true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Capture original position
        toolbar.captureOriginalPosition()
        
        // Force layout
        view.layoutIfNeeded()
        
        print("Installed fixed-position toolbar that maintains its position")
        
        // After a short delay, make sure the rest of the UI gets updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.updateUIVisibilityForJsonLoaded(self.currentJsonObject != nil)
        }
    }
}
