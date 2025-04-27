//  SimpleTwoButtonToolbar.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

/// A simple toolbar that displays two buttons side by side
class SimpleTwoButtonToolbar: ModernToolbar {
    
    // The left button (Open)
    var leftButton: UIButton!
    
    // The right button (Sample)
    var rightButton: UIButton!
    
    // MARK: - Initialization
    
    init(leftTitle: String, leftImage: UIImage?, rightTitle: String, rightImage: UIImage?) {
        // Initialize with ModernToolbar's initializer
        super.init()
        
        // Set accessibility identifier for constraint fixing
        self.accessibilityIdentifier = "mainToolbar"
        
        // Ensure translatesAutoresizingMaskIntoConstraints is set correctly
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the left button (Open) using a simpler approach to avoid constraint issues
        leftButton = UIButton(type: .system)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.setTitle(leftTitle, for: .normal)
        leftButton.setImage(leftImage, for: .normal)
        leftButton.backgroundColor = DesignSystem.Colors.primary
        leftButton.setTitleColor(.white, for: .normal)
        leftButton.tintColor = .white // Ensure icon is visible against primary color
        leftButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        leftButton.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.medium)
        // Add spacing between icon and text with simpler insets
        leftButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0) 
        leftButton.contentEdgeInsets = UIEdgeInsets(
            top: 8,
            left: 12,
            bottom: 8,
            right: 12
        )
        // Ensure text visibility with simplified settings
        leftButton.titleLabel?.lineBreakMode = .byClipping
        leftButton.semanticContentAttribute = .forceLeftToRight
        
        // Create the right button (Sample) with same simple approach
        rightButton = UIButton(type: .system)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.setTitle(rightTitle, for: .normal)
        rightButton.setImage(rightImage, for: .normal)
        rightButton.backgroundColor = DesignSystem.Colors.backgroundTertiary
        rightButton.setTitleColor(DesignSystem.Colors.text, for: .normal)
        rightButton.tintColor = DesignSystem.Colors.primary 
        rightButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        rightButton.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.medium)
        // Add spacing between icon and text with simpler insets
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        rightButton.contentEdgeInsets = UIEdgeInsets(
            top: 8,
            left: 12, 
            bottom: 8,
            right: 12
        )
        // Ensure text visibility with simplified settings
        rightButton.titleLabel?.lineBreakMode = .byClipping
        rightButton.semanticContentAttribute = .forceLeftToRight
        
        // Use a different approach - add buttons directly to toolbar with better spacing
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        // Add buttons directly to this view instead of using ModernToolbar's methods
        self.addSubview(leftButton)
        self.addSubview(spacerView)
        self.addSubview(rightButton)
        
        // Set fixed width and height constraints with lower priority
        let leftWidth = leftButton.widthAnchor.constraint(equalToConstant: 120)
        leftWidth.priority = .defaultHigh
        leftWidth.isActive = true
        
        let rightWidth = rightButton.widthAnchor.constraint(equalToConstant: 120)
        rightWidth.priority = .defaultHigh
        rightWidth.isActive = true
        
        let leftHeight = leftButton.heightAnchor.constraint(equalToConstant: 40)
        leftHeight.priority = .defaultHigh
        leftHeight.isActive = true
        
        let rightHeight = rightButton.heightAnchor.constraint(equalToConstant: 40)
        rightHeight.priority = .defaultHigh
        rightHeight.isActive = true
        
        // Use simpler layout constraints less prone to conflicts
        NSLayoutConstraint.activate([
            leftButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            leftButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            spacerView.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: 8),
            spacerView.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor, constant: -8),
            spacerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: 40),
            
            rightButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            rightButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        // Log that toolbar was created
        print("SimpleTwoButtonToolbar created with both buttons")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Setup will be called in superclass init
    }
    
    /// Reset all button constraints to resolve layout issues
    func resetButtonConstraints() {
        // Remove any fixed height/width constraints on buttons
        for button in [leftButton, rightButton] {
            guard let button = button else { continue }
            
            // Find and remove any fixed height constraints
            for constraint in button.constraints {
                if (constraint.firstAttribute == .height || constraint.firstAttribute == .width) && 
                   constraint.secondItem == nil {
                    button.removeConstraint(constraint)
                }
            }
            
            // Apply flexible height with medium priority
            let flexibleHeight = button.heightAnchor.constraint(equalToConstant: 32)
            flexibleHeight.priority = UILayoutPriority(750) // Medium priority
            flexibleHeight.isActive = true
            
            // Reset content edge insets to ensure title is visible
            button.contentEdgeInsets = UIEdgeInsets(
                top: DesignSystem.Spacing.tiny,
                left: DesignSystem.Spacing.small,
                bottom: DesignSystem.Spacing.tiny,
                right: DesignSystem.Spacing.small
            )
            
            // Reset title directly
            if button == leftButton {
                button.setTitle("Open", for: .normal)
            } else if button == rightButton {
                button.setTitle("Sample", for: .normal)
            }
            
            // Ensure buttons are properly visible
            button.isHidden = false
            
            // Force button to use required content compression resistance
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.setContentHuggingPriority(.required, for: .horizontal)
        }
        
        // Fix any translatesAutoresizingMaskIntoConstraints issues
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Force layout update
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        // Additional preservation mechanism for button text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            
            // Force fixed width constraints with high priority
            for case let button? in [self.leftButton, self.rightButton] {
                // Add fixed width constraint
                let widthConstraint = button.widthAnchor.constraint(equalToConstant: 120)
                widthConstraint.priority = .required
                widthConstraint.isActive = true
                
                // Force text to be visible
                button.titleLabel?.alpha = 1.0
            }
            
            // Force explicit known values
            self.leftButton.setTitle("Open", for: .normal)
            self.rightButton.setTitle("Sample", for: .normal)
            
            // Force layout again
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    /// Ensures button text always remains visible
    func preserveButtonTexts() {
        // Explicitly set text and make visible
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Force explicit known values for buttons
            self.leftButton.setTitle("Open", for: .normal)
            self.rightButton.setTitle("Sample", for: .normal)
            
            // Force title labels to be visible
            self.leftButton.titleLabel?.alpha = 1.0
            self.rightButton.titleLabel?.alpha = 1.0
            
            // Use fixed width for buttons to prevent text truncation
            for case let button? in [self.leftButton, self.rightButton] {
                // Remove any existing width constraints
                for constraint in button.constraints {
                    if constraint.firstAttribute == .width {
                        button.removeConstraint(constraint)
                    }
                }
                
                // Add fixed width constraint
                let widthConstraint = button.widthAnchor.constraint(equalToConstant: 120)
                widthConstraint.priority = .defaultHigh
                widthConstraint.isActive = true
                
                // Ensure button has proper configuration
                button.titleLabel?.minimumScaleFactor = 0.7
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.titleLabel?.lineBreakMode = .byClipping
                button.titleLabel?.numberOfLines = 1
                button.isHidden = false
            }
            
            // Force update
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    /// Start monitoring button text visibility
    func startPreservingButtonTexts() {
        // Preserve text immediately
        preserveButtonTexts()
        
        // Check again after a delay to catch any UI updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.preserveButtonTexts()
            
            // And check one more time to be really sure
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.preserveButtonTexts()
            }
        }
    }
}

extension ViewController {
    /// Fixes layout issues in a toolbar
    func fixButtonLayoutInToolbar(_ toolbar: SimpleTwoButtonToolbar) {
        // Set proper priorities
        toolbar.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        toolbar.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        // Ensure the buttons are visible with proper text
        toolbar.leftButton.isHidden = false
        toolbar.rightButton.isHidden = false
        toolbar.leftButton.setTitle("Open", for: .normal)
        toolbar.rightButton.setTitle("Sample", for: .normal)
        
        // Force layout immediately
        toolbar.setNeedsLayout()
        toolbar.layoutIfNeeded()
        
        // Add extra visibility check with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Double check visibility
            toolbar.leftButton.isHidden = false
            toolbar.rightButton.isHidden = false
            toolbar.leftButton.alpha = 1.0
            toolbar.rightButton.alpha = 1.0
            
            // Apply simplified styling to ensure visibility
            toolbar.leftButton.backgroundColor = DesignSystem.Colors.primary
            toolbar.leftButton.setTitleColor(.white, for: .normal)
            toolbar.rightButton.backgroundColor = DesignSystem.Colors.backgroundTertiary
            toolbar.rightButton.setTitleColor(DesignSystem.Colors.text, for: .normal)
            
            // Force layout again
            toolbar.setNeedsLayout()
            toolbar.layoutIfNeeded()
        }
    }
    
    /// Replaces the current toolbar with a simpler two-button version
    func replaceWithSimpleTwoButtonToolbar() {
        // Remove existing toolbars from view first
        for subview in view.subviews {
            if subview.accessibilityIdentifier == "mainToolbar" {
                subview.removeFromSuperview()
            }
        }
        
        // Fix any existing constraint issues in the view hierarchy
        view.fixAllConstraintIssues()
        
        // Create a completely new toolbar with Open and Sample buttons - use simplified design
        let containerView = UIView()
        containerView.accessibilityIdentifier = "mainToolbar"
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = DesignSystem.Colors.backgroundSecondary
        containerView.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        
        // Create custom buttons directly for maximum stability
        let openButton = UIButton(type: .system)
        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.setTitle("Open", for: .normal)
        openButton.setImage(UIImage(systemName: "folder"), for: .normal)
        openButton.backgroundColor = DesignSystem.Colors.primary
        openButton.setTitleColor(.white, for: .normal)
        openButton.tintColor = .white
        openButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        
        let sampleButton = UIButton(type: .system)
        sampleButton.translatesAutoresizingMaskIntoConstraints = false
        sampleButton.setTitle("Sample", for: .normal)
        sampleButton.setImage(UIImage(systemName: "doc.text"), for: .normal)
        sampleButton.backgroundColor = DesignSystem.Colors.backgroundTertiary
        sampleButton.setTitleColor(DesignSystem.Colors.text, for: .normal)
        sampleButton.tintColor = DesignSystem.Colors.primary
        sampleButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        
        // Add to container
        containerView.addSubview(openButton)
        containerView.addSubview(sampleButton)
        
        // Add container to main view
        view.addSubview(containerView)
        
        // Setup actions
        openButton.addTarget(self, action: #selector(openFileButtonTapped), for: .touchUpInside)
        sampleButton.addTarget(self, action: #selector(loadSampleButtonTapped), for: .touchUpInside)
        
        // Use simple, fixed layout with explicit values
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 60),
            
            openButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            openButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            openButton.widthAnchor.constraint(equalToConstant: 120),
            openButton.heightAnchor.constraint(equalToConstant: 40),
            
            sampleButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            sampleButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            sampleButton.widthAnchor.constraint(equalToConstant: 120),
            sampleButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Store references to the buttons and toolbar
        self.openButton = openButton
        self.loadSampleButton = sampleButton
        self.mainToolbar = containerView
        
        // Force layout to ensure everything is positioned correctly
        view.layoutIfNeeded()
        
        // Log for debugging
        print("SimpleTwoButtonToolbar replaced - Open button visible: \(!openButton.isHidden), Sample button visible: \(!sampleButton.isHidden)")
        print("Recreated toolbar with proper buttons")
        
        // Set visibility after a brief delay to ensure they appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            openButton.alpha = 1.0
            sampleButton.alpha = 1.0
            openButton.isHidden = false
            sampleButton.isHidden = false
            print("SimpleTwoButtonToolbar buttons made visible")
        }
    }
}
