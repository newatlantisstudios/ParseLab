//
//  FixedSizeButton.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

/// A button that maintains a fixed size regardless of state changes
class FixedSizeButton: UIButton {
    
    // Set fixed dimensions that won't change
    private let fixedWidth: CGFloat
    private let fixedHeight: CGFloat
    
    // Track if we're active (showing metadata)
    private var isActiveState = false
    
    // Initialize with specific size
    init(width: CGFloat, height: CGFloat) {
        self.fixedWidth = width
        self.fixedHeight = height
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.fixedWidth = 36
        self.fixedHeight = 36
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Basic configuration
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Disable all automatic adjustments
        self.adjustsImageWhenHighlighted = false
        self.adjustsImageWhenDisabled = false
        
        // Set up simpler centering approach
        self.contentHorizontalAlignment = .center
        self.contentVerticalAlignment = .center
        self.contentEdgeInsets = .zero
        self.imageEdgeInsets = .zero
        
        if #available(iOS 13.0, *) {
            // Use simpler icon configuration
            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .light)
            let icon = UIImage(systemName: "info.circle", withConfiguration: config)
            self.setImage(icon, for: .normal)
        } else {
            self.setTitle("i", for: .normal)
        }
        
        // Set blue tint
        self.tintColor = .systemBlue
        
        // Set preferred size using content hugging and compression resistance instead of fixed constraints
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    // Return preferred size, but allow Auto Layout to adjust if needed
    override var intrinsicContentSize: CGSize {
        return CGSize(width: fixedWidth, height: fixedHeight)
    }
    
    // Use lower-priority constraints for size
    override func updateConstraints() {
        super.updateConstraints()
        
        // Remove any existing width/height constraints
        for constraint in constraints {
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                removeConstraint(constraint)
            }
        }
        
        // Add preferred size constraints with lower priority
        let widthConstraint = widthAnchor.constraint(equalToConstant: fixedWidth)
        widthConstraint.priority = UILayoutPriority(750) // Lower priority
        widthConstraint.isActive = true
        
        let heightConstraint = heightAnchor.constraint(equalToConstant: fixedHeight)
        heightConstraint.priority = UILayoutPriority(750) // Lower priority
        heightConstraint.isActive = true
    }
    
    // Active/inactive state without size change
    func setActive(_ active: Bool) {
        isActiveState = active
        tintColor = active ? .systemBlue.withAlphaComponent(0.8) : .systemBlue
        setNeedsLayout()
    }
}
