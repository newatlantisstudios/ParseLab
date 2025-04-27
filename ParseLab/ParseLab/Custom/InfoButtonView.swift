//
//  InfoButtonView.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

class InfoButtonView: UIView {
    
    // The icon image view
    private let iconImageView = UIImageView()
    
    // Action to perform when tapped
    var onTap: (() -> Void)?
    
    // Track enabled state
    private var _isEnabled = true
    
    // Support enabling/disabling like a button
    var isEnabled: Bool {
        get { return _isEnabled }
        set {
            _isEnabled = newValue
            // Update appearance based on enabled state
            alpha = newValue ? 1.0 : 0.5
            isUserInteractionEnabled = newValue
        }
    }
    
    // Initialize with a specific size
    init(size: CGFloat = 36) {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        setupView(size: size)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(size: 36)
    }
    
    private func setupView(size: CGFloat) {
        // Configure the container view
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Use a combination of preferred size constraints and content priorities
        // The preferred size constraints provide a hint for the desired size
        // but can be broken if needed to satisfy other constraints
        
        // Create preferred size constraints with high but breakable priority
        let widthConstraint = widthAnchor.constraint(equalToConstant: size)
        widthConstraint.priority = UILayoutPriority(750) // Medium priority
        widthConstraint.isActive = true
        
        let heightConstraint = heightAnchor.constraint(equalToConstant: size)
        heightConstraint.priority = UILayoutPriority(750) // Medium priority
        heightConstraint.isActive = true
        
        // Set content hugging and compression priorities to maintain size when possible
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        // Set up the image view
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .center
        iconImageView.tintColor = .systemBlue
        
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: "info.circle")
        } else {
            // Fallback for earlier iOS versions
            // Create a text-based image or use a bundled image
            let label = UILabel()
            label.text = "i"
            label.textAlignment = .center
            label.textColor = .systemBlue
            label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 24), false, 0)
            if let context = UIGraphicsGetCurrentContext() {
                label.layer.render(in: context)
                iconImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            }
            UIGraphicsEndImageContext()
        }
        
        // Add the image view to the container
        addSubview(iconImageView)
        
        // Center the image view in the container
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc private func handleTap() {
        // Only call the tap handler if enabled
        if _isEnabled {
            onTap?()
        }
    }
    
    // Update the icon image
    func updateIcon(_ image: UIImage?) {
        iconImageView.image = image
    }
    
    // Set the active/inactive state
    func setActive(_ active: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.iconImageView.tintColor = active ? 
                UIColor.systemBlue.withAlphaComponent(0.8) : 
                UIColor.systemBlue
        }
    }
}
