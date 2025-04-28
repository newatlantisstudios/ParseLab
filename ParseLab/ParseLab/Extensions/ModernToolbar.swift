//
//  ModernToolbar.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

/// A modern toolbar component for better UI organization
class ModernToolbar: UIView {
    
    // MARK: - Properties
    
    private let stackView = UIStackView()
    private var leftItems: [UIView] = []
    private var centerItems: [UIView] = []
    private var rightItems: [UIView] = []
    
    // Public properties
    var itemSpacing: CGFloat = DesignSystem.Spacing.small {
        didSet {
            updateStackViews()
        }
    }
    
    var leftStackView = UIStackView()
    var centerStackView = UIStackView()
    var rightStackView = UIStackView()
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        // Configure the toolbar appearance
        self.backgroundColor = DesignSystem.Colors.backgroundSecondary
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        
        // Apply shadow
        let shadow = DesignSystem.Shadow.subtle()
        self.layer.shadowColor = shadow.color
        self.layer.shadowOffset = shadow.offset
        self.layer.shadowOpacity = shadow.opacity
        self.layer.shadowRadius = shadow.radius
        self.clipsToBounds = false
        
        // Apply border
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.separator.cgColor
        
        // Configure main stack view with improved layout
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = DesignSystem.Spacing.large
        stackView.isUserInteractionEnabled = true
        self.addSubview(stackView)
        
        // Configure section stack views with improved settings
        [leftStackView, centerStackView, rightStackView].forEach { sectionStack in
            sectionStack.axis = .horizontal
            sectionStack.alignment = .center
            sectionStack.spacing = itemSpacing
            sectionStack.translatesAutoresizingMaskIntoConstraints = false
            sectionStack.isUserInteractionEnabled = true
        }
        
        // Allow center stack to be compressed, outer stacks resist
        leftStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        centerStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        rightStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Ensure right stack view maintains its size (redundant with above, keeping for safety)
        rightStackView.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Set hugging priorities (less important with .fill)
        leftStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        centerStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rightStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        // Set up constraints with lower priority to avoid conflicts
        let leadingConstraint = stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: DesignSystem.Spacing.small)
        leadingConstraint.priority = UILayoutPriority(999) // High but not required
        
        let trailingConstraint = stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -DesignSystem.Spacing.small)
        trailingConstraint.priority = UILayoutPriority(999) // High but not required
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: DesignSystem.Spacing.tiny),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -DesignSystem.Spacing.tiny),
            leadingConstraint,
            trailingConstraint
        ])
        
        // Add a minimum width constraint for the main stack view
        let minWidthConstraint = stackView.widthAnchor.constraint(greaterThanOrEqualTo: self.widthAnchor, multiplier: 0.9)
        minWidthConstraint.priority = UILayoutPriority(750) // Medium priority
        minWidthConstraint.isActive = true
        
        // Add stack views to main stack
        stackView.addArrangedSubview(leftStackView)
        stackView.addArrangedSubview(centerStackView)
        stackView.addArrangedSubview(rightStackView)
    }
    
    // MARK: - Public Methods
    
    /// Fix constraint issues by applying flexible constraints
    func fixConstraintIssues() {
        // Make all button heights more flexible
        for section in [leftStackView, centerStackView, rightStackView] {
            for arrangedView in section.arrangedSubviews {
                // Handle buttons
                if let button = arrangedView as? UIButton {
                    // Remove any fixed height/width constraints
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
                
                // Handle custom views
                if !(arrangedView is UIButton) && !(arrangedView is UILabel) {
                    // Remove any fixed height/width constraints
                    for constraint in arrangedView.constraints {
                        if (constraint.firstAttribute == .height || constraint.firstAttribute == .width) &&
                           constraint.secondItem == nil && constraint.priority == .required {
                            arrangedView.removeConstraint(constraint)
                        }
                    }
                    
                    // Set appropriate priorities
                    arrangedView.setContentHuggingPriority(.defaultHigh, for: .vertical)
                    arrangedView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
                }
            }
        }
        
        // Fix the stack view's own constraints
        for constraint in constraints {
            if constraint.firstAttribute == .height && constraint.secondItem == nil {
                // Replace fixed height with flexible height
                let height = constraint.constant
                removeConstraint(constraint)
                
                let flexibleHeight = heightAnchor.constraint(equalToConstant: height)
                flexibleHeight.priority = UILayoutPriority(750) // Medium priority
                flexibleHeight.isActive = true
            }
        }
        
        // Update the layout
        updateStackViews()
    }
    
    /// Set left-aligned items in the toolbar
    func setLeftItems(_ items: [UIView]) {
        leftItems = items
        updateStackViews()
    }
    
    /// Set center-aligned items in the toolbar
    func setCenterItems(_ items: [UIView]) {
        centerItems = items
        updateStackViews()
    }
    
    /// Set right-aligned items in the toolbar
    func setRightItems(_ items: [UIView]) {
        rightItems = items
        updateStackViews()
    }
    
    /// Add a single item to the left section
    func addLeftItem(_ item: UIView) {
        leftItems.append(item)
        updateStackViews()
    }
    
    /// Add a single item to the center section
    func addCenterItem(_ item: UIView) {
        centerItems.append(item)
        updateStackViews()
    }
    
    /// Add a single item to the right section
    func addRightItem(_ item: UIView) {
        rightItems.append(item)
        updateStackViews()
    }
    
    /// Get right items accessor for safe access to the private property
    func getRightItems() -> [UIView] {
        return rightItems
    }
    
    /// Get all items in all sections
    func getAllItems() -> [UIView] {
        return leftItems + centerItems + rightItems
    }
    
    // MARK: - Helper Methods
    
    private func updateStackViews() {
        // Clear all stack views
        leftStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        centerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rightStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Set up spacing for the main stack and section stacks
        stackView.spacing = DesignSystem.Spacing.large
        leftStackView.spacing = itemSpacing
        centerStackView.spacing = itemSpacing
        rightStackView.spacing = itemSpacing
        
        // Reduce size of buttons when there are more than 5 total items
        let totalItems = leftItems.count + centerItems.count + rightItems.count
        let buttonSize: CGFloat = totalItems > 5 ? 36 : 40
        
        // Fix fixed size constraints that could cause conflicts
        for stack in [leftStackView, centerStackView, rightStackView] {
            // Remove any height constraints on stack views
            for constraint in stack.constraints where constraint.firstAttribute == .height {
                stack.removeConstraint(constraint)
            }
            
            // Ensure proper content hugging and compression priorities
            stack.setContentHuggingPriority(.defaultLow, for: .horizontal)
            stack.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
        
        // Pre-process all buttons to ensure consistent sizing
        for item in leftItems + centerItems + rightItems {
            // Handle both buttons and custom views
            if let button = item as? UIButton {
                // Use smaller content insets when we have more buttons ONLY if default insets are present
                let defaultInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                let tinyInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
                if button.contentEdgeInsets == defaultInsets || button.contentEdgeInsets == tinyInsets || button.contentEdgeInsets == .zero {
                    // Only override if the insets seem to be the default/unset or previously set by this logic
                    if totalItems > 5 {
                        button.contentEdgeInsets = tinyInsets
                    } else {
                        button.contentEdgeInsets = defaultInsets
                    }
                } // else: Keep custom insets set elsewhere (e.g., in createStyledToolbarButton)
                
                // Remove all existing width/height constraints to prevent conflicts
                for constraint in button.constraints {
                    if constraint.firstAttribute == .height || constraint.firstAttribute == .width {
                        button.removeConstraint(constraint)
                    }
                }
                
                // Add flexible width constraint based on number of items
                let widthConstraint = button.widthAnchor.constraint(equalToConstant: buttonSize)
                widthConstraint.priority = UILayoutPriority(700) // Lowered from 750
                widthConstraint.isActive = true
                
                // Prioritize compression resistance for button content
                button.setContentHuggingPriority(.defaultLow, for: .horizontal)
                button.setContentCompressionResistancePriority(.required, for: .horizontal)
            } else if let customView = item as? UIView {
                // Handle custom views like InfoButtonView
                for constraint in customView.constraints {
                    if constraint.firstAttribute == .height || constraint.firstAttribute == .width {
                        customView.removeConstraint(constraint)
                    }
                }
                
                // Add flexible size constraint
                let widthConstraint = customView.widthAnchor.constraint(equalToConstant: buttonSize)
                widthConstraint.priority = UILayoutPriority(700) // Lowered from 750
                widthConstraint.isActive = true
                
                // Setup proper priorities for custom views
                customView.setContentHuggingPriority(.defaultLow, for: .horizontal)
                customView.setContentCompressionResistancePriority(.required, for: .horizontal)
            }
        }
        
        // Add items to respective stack views
        for item in leftItems {
            leftStackView.addArrangedSubview(item)
        }
        
        for item in centerItems {
            centerStackView.addArrangedSubview(item)
        }
        
        for item in rightItems {
            rightStackView.addArrangedSubview(item)
        }
        
        // Center alignment for all stacks to better align icons
        centerStackView.alignment = .center
        leftStackView.alignment = .center
        rightStackView.alignment = .center
        
        // Adjust spacing between items based on total item count
        let adjustedItemSpacing = totalItems > 5 ? itemSpacing : DesignSystem.Spacing.medium // Increase spacing when fewer items
        if totalItems > 5 {
            leftStackView.spacing = adjustedItemSpacing / 2 // Use adjusted spacing
            centerStackView.spacing = adjustedItemSpacing / 2 // Use adjusted spacing
            rightStackView.spacing = adjustedItemSpacing / 2 // Use adjusted spacing
        } else {
            leftStackView.spacing = adjustedItemSpacing // Use adjusted spacing
            centerStackView.spacing = adjustedItemSpacing // Use adjusted spacing
            rightStackView.spacing = adjustedItemSpacing // Use adjusted spacing
        }
        
        // Give right stack view highest priority for compression resistance
        rightStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Ensure all stack views are visible - even if empty
        leftStackView.isHidden = false
        centerStackView.isHidden = false
        rightStackView.isHidden = false
    }
}

/// A button with icon and text specially styled for the ModernToolbar
class ToolbarButton: UIButton {
    
    // MARK: - Initialization
    
    init(title: String, icon: UIImage? = nil, isPrimary: Bool = false) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: .normal)
        self.setImage(icon, for: .normal)
        
        // Configure appearance
        if isPrimary {
            self.backgroundColor = DesignSystem.Colors.primary
            self.setTitleColor(.white, for: .normal)
            self.tintColor = .white
        } else {
            self.backgroundColor = DesignSystem.Colors.backgroundTertiary
            self.setTitleColor(DesignSystem.Colors.text, for: .normal)
            self.tintColor = DesignSystem.Colors.primary
        }
        
        // Style the button
        self.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        self.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.medium)
        
        // Set content insets with reduced vertical padding
        self.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.tiny,
            left: DesignSystem.Spacing.medium,
            bottom: DesignSystem.Spacing.tiny,
            right: DesignSystem.Spacing.medium
        )
        
        // Set image padding
        if icon != nil && !title.isEmpty {
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        }
        
        // Add shadow for primary buttons
        if isPrimary {
            let shadow = DesignSystem.Shadow.subtle()
            self.layer.shadowColor = shadow.color
            self.layer.shadowOffset = shadow.offset
            self.layer.shadowOpacity = shadow.opacity
            self.layer.shadowRadius = shadow.radius
            self.clipsToBounds = false
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = DesignSystem.Colors.backgroundTertiary
        self.setTitleColor(DesignSystem.Colors.text, for: .normal)
        self.tintColor = DesignSystem.Colors.primary
        self.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        self.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.medium)
        self.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.tiny,
            left: DesignSystem.Spacing.medium,
            bottom: DesignSystem.Spacing.tiny,
            right: DesignSystem.Spacing.medium
        )
    }
}

/// A toolbar item that consists of an icon and a title label
class ToolbarItem: UIView {
    
    // MARK: - Properties
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let containerStackView = UIStackView()
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var icon: UIImage? {
        didSet {
            iconView.image = icon
            iconView.isHidden = icon == nil
        }
    }
    
    // MARK: - Initialization
    
    init(title: String, icon: UIImage? = nil) {
        super.init(frame: .zero)
        self.title = title
        self.icon = icon
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        // Configure appearance
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure icon view
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = DesignSystem.Colors.primary
        iconView.image = icon
        iconView.isHidden = icon == nil
        
        // Configure title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = DesignSystem.Typography.bodyMedium()
        titleLabel.textColor = DesignSystem.Colors.text
        titleLabel.text = title
        
        // Configure stack view
        containerStackView.axis = .horizontal
        containerStackView.alignment = .center
        containerStackView.spacing = DesignSystem.Spacing.small
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add views to hierarchy
        containerStackView.addArrangedSubview(iconView)
        containerStackView.addArrangedSubview(titleLabel)
        self.addSubview(containerStackView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: self.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            iconView.widthAnchor.constraint(equalToConstant: DesignSystem.Sizing.smallIconSize),
            iconView.heightAnchor.constraint(equalToConstant: DesignSystem.Sizing.smallIconSize)
        ])
    }
}
