//
//  FloatingActionButton.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

/// A modern floating action button (FAB) component
class FloatingActionButton: UIButton {
    
    // MARK: - Properties
    
    var action: (() -> Void)?
    
    // MARK: - Initialization
    
    init(icon: UIImage? = nil, backgroundColor: UIColor = DesignSystem.Colors.primary) {
        super.init(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        setupButton(icon: icon, backgroundColor: backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    // MARK: - Setup
    
    private func setupButton(icon: UIImage? = nil, backgroundColor: UIColor = DesignSystem.Colors.primary) {
        // Configure appearance
        self.backgroundColor = backgroundColor
        self.tintColor = .white
        
        // Set icon if provided
        if let icon = icon {
            self.setImage(icon, for: .normal)
        } else if #available(iOS 13.0, *) {
            // Default to pencil icon if none provided
            self.setImage(UIImage(systemName: "pencil"), for: .normal)
        }
        
        // Apply circular shape
        self.layer.cornerRadius = 28
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up constraints for proper size
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 56),
            self.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Add shadow for elevation effect
        let shadow = DesignSystem.Shadow.prominent()
        self.layer.shadowColor = shadow.color
        self.layer.shadowOffset = shadow.offset
        self.layer.shadowOpacity = shadow.opacity
        self.layer.shadowRadius = shadow.radius
        self.clipsToBounds = false
        
        // Configure touch interaction
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        self.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        // Ensure the button is fully opaque and visible
        self.alpha = 1.0
        self.isHidden = false
        
        // IMPORTANT: Ensure user interaction is enabled
        self.isUserInteractionEnabled = true
    }
    
    // MARK: - Touch Handling
    
    @objc private func touchDown() {
        // Create pressed state effect
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.layer.shadowOpacity = DesignSystem.Shadow.subtle().opacity
        }
    }
    
    @objc private func touchUp() {
        // Restore normal state
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform.identity
            self.layer.shadowOpacity = DesignSystem.Shadow.prominent().opacity
        }
    }
    
    @objc private func handleTap() {
        // Execute the action closure if set
        action?()
    }
    
    // MARK: - Menu Support
    
    // Add support for context menu
    func setupMenu(options: [UIAction]) {
        if #available(iOS 14.0, *) {
            self.menu = UIMenu(title: "", children: options)
            self.showsMenuAsPrimaryAction = true
        }
    }
    
    // Make sure hitTest captures touches properly
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Slightly expand the touch area for better usability
        let bounds = self.bounds.insetBy(dx: -10, dy: -10)
        return bounds.contains(point) ? self : nil
    }
}

/// A floating action button with mini size
class MiniFloatingActionButton: FloatingActionButton {
    
    // MARK: - Initialization
    
    override init(icon: UIImage? = nil, backgroundColor: UIColor = DesignSystem.Colors.primary) {
        super.init(icon: icon, backgroundColor: backgroundColor)
        adjustSize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        adjustSize()
    }
    
    // MARK: - Size Adjustment
    
    private func adjustSize() {
        // Make the button smaller
        self.layer.cornerRadius = 20
        
        // Update size constraints
        for constraint in self.constraints {
            if constraint.firstAttribute == .width {
                constraint.constant = 40
            } else if constraint.firstAttribute == .height {
                constraint.constant = 40
            }
        }
        
        // Add new constraints if needed
        if self.constraints.isEmpty {
            NSLayoutConstraint.activate([
                self.widthAnchor.constraint(equalToConstant: 40),
                self.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
}
