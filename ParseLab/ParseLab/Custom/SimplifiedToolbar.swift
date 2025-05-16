//
//  SimplifiedToolbar.swift
//  ParseLab
//
//  Created on 4/27/25.
//

import UIKit

// Using local DesignSystem components
private extension UIColor {
    static var designSystemPrimary: UIColor {
        return UIColor(named: "AppTheme") ?? .systemBlue
    }
    
    static var designSystemBackgroundSecondary: UIColor {
        if #available(iOS 13.0, *) {
            return .secondarySystemBackground
        } else {
            return UIColor(white: 0.95, alpha: 1.0)
        }
    }
}

// Add applyCardStyle extension if not found elsewhere
extension UIView {
    @objc func applyCardStyle() {
        // Default implementation if not available elsewhere
        self.layer.cornerRadius = 12
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
}

/// A lightweight, constraint-conflict-free toolbar implementation
class SimplifiedToolbar: UIView {
    
    // Left button (usually Open)
    var leftButton: UIButton!
    
    // Right button (usually Sample)
    var rightButton: UIButton!
    
    // MARK: - Initialization
    
    init(leftTitle: String, leftImage: UIImage?, rightTitle: String, rightImage: UIImage?) {
        super.init(frame: .zero)
        
        // Set accessibility identifier for tracing
        self.accessibilityIdentifier = "mainToolbar"
        
        // Ensure translatesAutoresizingMaskIntoConstraints is set correctly
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure appearance
        self.backgroundColor = UIColor.designSystemBackgroundSecondary
        self.layer.cornerRadius = 12
        
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
        leftButton.backgroundColor = UIColor.designSystemPrimary
        leftButton.setTitleColor(.white, for: .normal)
        leftButton.tintColor = .white
        leftButton.layer.cornerRadius = 8
        leftButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        // Create the right button with simple styling
        rightButton = UIButton(type: .system)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.setTitle(rightTitle, for: .normal)
        rightButton.setImage(rightImage, for: .normal)
        if #available(iOS 13.0, *) {
            rightButton.backgroundColor = .tertiarySystemBackground
            rightButton.setTitleColor(.label, for: .normal)
        } else {
            rightButton.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
            rightButton.setTitleColor(.black, for: .normal)
        }
        rightButton.tintColor = UIColor.designSystemPrimary
        rightButton.layer.cornerRadius = 8
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
        
        // Log creation
        print("Created simplified toolbar without constraint conflicts")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// Extension to add priority to constraints
extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

// Extension to add simplified toolbar to ViewController
extension ViewController {
    /// Replaces the current toolbar with a simplified version free of constraint conflicts
    func replaceWithSimplifiedToolbar() {
        print("[LOG] replaceWithSimplifiedToolbar: START")
        // FIRST: Remove ALL toolbars and action bars to prevent duplicates
        print("[LOG] replaceWithSimplifiedToolbar: Removing existing toolbars")
        for subview in view.subviews {
            if subview.accessibilityIdentifier == "mainToolbar" || 
               subview.accessibilityIdentifier == "actionsToolbar" ||
               subview is ModernToolbar {
                print("[LOG] replaceWithSimplifiedToolbar: Removing \(subview.accessibilityIdentifier ?? "ModernToolbar")")
                subview.removeFromSuperview()
            }
        }
        
        // Create new toolbar with Open and Sample buttons
        print("[LOG] replaceWithSimplifiedToolbar: Creating new main toolbar")
        let toolbar = SimplifiedToolbar(
            leftTitle: "Open",
            leftImage: UIImage(systemName: "folder"),
            rightTitle: "Sample",
            rightImage: UIImage(systemName: "doc.text")
        )
        
        // Add to view at the top
        print("[LOG] replaceWithSimplifiedToolbar: Adding main toolbar to view")
        view.addSubview(toolbar)
        
        // Setup constraints for main toolbar
        print("[LOG] replaceWithSimplifiedToolbar: Setting main toolbar constraints")
        // Deactivate any existing constraints first
        for constraint in view.constraints {
            if let firstItem = constraint.firstItem as? UIView, 
               let secondItem = constraint.secondItem as? UIView,
               (firstItem.accessibilityIdentifier == "mainToolbar" || secondItem.accessibilityIdentifier == "mainToolbar") {
                constraint.isActive = false
            }
        }
        
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
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
        
        // --- Restore secondary toolbar (actionsBar) below main toolbar ---
        if let actionsBar = self.actionsBar as? UIView {
            print("[LOG] replaceWithSimplifiedToolbar: Restoring actionsBar")
            
            // First deactivate ALL constraints related to actionsBar
            for view in [self.view, actionsBar.superview].compactMap({ $0 }) {
                for constraint in view.constraints {
                    if let firstItem = constraint.firstItem as? NSObject, let secondItem = constraint.secondItem as? NSObject,
                       (firstItem === actionsBar || secondItem === actionsBar) {
                        constraint.isActive = false
                    }
                }
            }
            
            actionsBar.removeFromSuperview() // Remove if already in view
            actionsBar.translatesAutoresizingMaskIntoConstraints = false
            actionsBar.accessibilityIdentifier = "actionsToolbar"
            view.addSubview(actionsBar)
            
            print("[LOG] replaceWithSimplifiedToolbar: Setting actionsBar constraints")
            // Simplify by not adding the actionsBar at all during this rebuild 
            // We'll just hide it to avoid constraint conflicts
            actionsBar.isHidden = true
        } else {
            print("[LOG] replaceWithSimplifiedToolbar: actionsBar is nil, cannot restore")
        }
        
        // CRITICAL: Ensure JSON path container is positioned properly
        print("[LOG] replaceWithSimplifiedToolbar: Positioning pathContainer")
        let pathContainerView = self.pathContainer
        
        // Deactivate ALL constraints involving pathContainer (not just from its superview)
        for view in [self.view, pathContainerView.superview].compactMap({ $0 }) {
            print("[LOG] replaceWithSimplifiedToolbar: Deactivating existing pathContainer constraints")
            for constraint in view.constraints {
                if let firstItem = constraint.firstItem as? NSObject, let secondItem = constraint.secondItem as? NSObject,
                   (firstItem === pathContainerView || secondItem === pathContainerView) {
                    constraint.isActive = false
                }
            }
        }
        
        print("[LOG] replaceWithSimplifiedToolbar: Removing/Re-adding pathContainer")
        pathContainerView.removeFromSuperview()
        pathContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pathContainerView)
        pathContainerView.isHidden = false
        self.view.bringSubviewToFront(pathContainerView)
        
        print("[LOG] replaceWithSimplifiedToolbar: Setting new pathContainer constraints")
        // Only reference the toolbar directly, not the actionsBar which may have conflicting constraints
        NSLayoutConstraint.activate([
            pathContainerView.topAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: 16),
            pathContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
            pathContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            pathContainerView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // CRITICAL: Ensure file content view is reset and positioned below pathContainer
        print("[LOG] replaceWithSimplifiedToolbar: Positioning fileContentView")
        let contentView = self.fileContentView
        
        // Deactivate ALL constraints involving contentView from any related view
        for view in [self.view, contentView.superview].compactMap({ $0 }) {
            print("[LOG] replaceWithSimplifiedToolbar: Deactivating existing fileContentView constraints")
            for constraint in view.constraints {
                if let firstItem = constraint.firstItem as? NSObject, let secondItem = constraint.secondItem as? NSObject,
                   (firstItem === contentView || secondItem === contentView) {
                    constraint.isActive = false
                }
            }
        }
        
        // Remove contentView's own constraints
        for constraint in contentView.constraints {
            constraint.isActive = false
        }
        
        print("[LOG] replaceWithSimplifiedToolbar: Removing/Re-adding fileContentView")
        contentView.removeFromSuperview() // Remove completely
        self.view.addSubview(contentView) // Re-add
        contentView.translatesAutoresizingMaskIntoConstraints = false // Ensure this is false
        contentView.isHidden = false
        self.view.bringSubviewToFront(contentView) // Ensure it's above path container visually

        print("[LOG] replaceWithSimplifiedToolbar: Setting new fileContentView constraints")
        let contentViewConstraints = [
            contentView.topAnchor.constraint(equalTo: pathContainerView.bottomAnchor, constant: 8),
            contentView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            contentView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            contentView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ]
        
        // Store the constraints for later deactivation if needed
        self.fileContentViewConstraints = contentViewConstraints
        
        NSLayoutConstraint.activate(contentViewConstraints)

        // If we have JSON content, make sure it's displayed *after* layout is set
        if self.currentJsonObject != nil {
            print("[LOG] replaceWithSimplifiedToolbar: Scheduling refreshJsonView and layoutIfNeeded")
            DispatchQueue.main.async { [weak self] in
                print("[LOG] replaceWithSimplifiedToolbar: Dispatch START - refreshJsonView")
                guard let self = self else { return }
                self.refreshJsonView()
                // Ensure content view is scrolled to top
                self.fileContentView.contentOffset = .zero 
                // Force layout AFTER content refresh
                print("[LOG] replaceWithSimplifiedToolbar: Dispatch - layoutIfNeeded")
                self.view.layoutIfNeeded()
                print("[LOG] replaceWithSimplifiedToolbar: Dispatch END - refreshJsonView")
            }
        } else {
            print("[LOG] replaceWithSimplifiedToolbar: Scheduling layoutIfNeeded (no JSON)")
            // Force layout even if no JSON object, to ensure view positioning
            DispatchQueue.main.async { [weak self] in
                print("[LOG] replaceWithSimplifiedToolbar: Dispatch START - layoutIfNeeded (no JSON)")
                self?.view.layoutIfNeeded()
                print("[LOG] replaceWithSimplifiedToolbar: Dispatch END - layoutIfNeeded (no JSON)")
            }
        }
        
        print("[LOG] replaceWithSimplifiedToolbar: END - Final layoutIfNeeded scheduled")
    }
}
