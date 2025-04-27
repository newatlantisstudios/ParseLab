//
//  UIViewController+Toast.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Definition of toast message types
public enum ToastStyle {
    case info
    case success
    case warning
    case error
    
    var color: UIColor {
        switch self {
        case .info:
            return UIColor.systemBlue
        case .success:
            return UIColor.systemGreen
        case .warning:
            return UIColor.systemOrange
        case .error:
            return UIColor.systemRed
        }
    }
    
    var icon: String {
        switch self {
        case .info:
            return "info.circle"
        case .success:
            return "checkmark.circle"
        case .warning:
            return "exclamationmark.triangle"
        case .error:
            return "xmark.circle"
        }
    }
}

// Toast message extension for UIViewController
extension UIViewController {
    
    /// Shows an enhanced toast message with icon and styled background
    /// - Parameters:
    ///   - message: The message to display
    ///   - type: The type of toast (info, success, warning, error)
    ///   - duration: How long to display the toast (in seconds)
    public func showEnhancedToast(message: String, type: ToastStyle = .info, duration: TimeInterval = 3.0) {
        // Create container view
        let toastContainer = UIView()
        toastContainer.backgroundColor = type.color.withAlphaComponent(0.9)
        toastContainer.layer.cornerRadius = 10
        toastContainer.clipsToBounds = true
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.alpha = 0
        
        // Create icon view if system supports SF Symbols
        var iconView: UIImageView?
        if #available(iOS 13.0, *) {
            if let image = UIImage(systemName: type.icon) {
                iconView = UIImageView(image: image)
                iconView?.contentMode = .scaleAspectFit
                iconView?.tintColor = .white
                iconView?.translatesAutoresizingMaskIntoConstraints = false
                toastContainer.addSubview(iconView!)
            }
        }
        
        // Create message label
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.textAlignment = .left
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.addSubview(messageLabel)
        
        // Add container to view
        self.view.addSubview(toastContainer)
        
        // Add constraints
        NSLayoutConstraint.activate([
            toastContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            toastContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            toastContainer.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        // Icon constraints (if available)
        if let iconView = iconView {
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 16),
                iconView.centerYAnchor.constraint(equalTo: toastContainer.centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: 24),
                iconView.heightAnchor.constraint(equalToConstant: 24)
            ])
            
            // Adjust label constraints when icon is present
            NSLayoutConstraint.activate([
                messageLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
                messageLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -16),
                messageLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 12),
                messageLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -12)
            ])
        } else {
            // Center label when no icon
            NSLayoutConstraint.activate([
                messageLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 16),
                messageLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -16),
                messageLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 12),
                messageLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -12)
            ])
        }
        
        // Animate toast in
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            toastContainer.alpha = 1
        }, completion: { _ in
            // Animate toast out after delay
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseInOut, animations: {
                toastContainer.alpha = 0
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
    }
    
    /// Shows a simple toast message
    /// - Parameters:
    ///   - message: The message to display
    ///   - type: The type of toast (info, success, warning, error)
    ///   - duration: How long to display the toast (in seconds)
    public func showToast(message: String, type: ToastStyle = .info, duration: TimeInterval = 3.0) {
        // Create container view
        let toastContainer = UIView()
        toastContainer.backgroundColor = type.color.withAlphaComponent(0.9)
        toastContainer.layer.cornerRadius = 10
        toastContainer.clipsToBounds = true
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.alpha = 0
        
        // Create message label
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.addSubview(messageLabel)
        
        // Add container to view
        self.view.addSubview(toastContainer)
        
        // Add constraints
        NSLayoutConstraint.activate([
            toastContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            toastContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            toastContainer.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            messageLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -12)
        ])
        
        // Animate toast in
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            toastContainer.alpha = 1
        }, completion: { _ in
            // Animate toast out after delay
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseInOut, animations: {
                toastContainer.alpha = 0
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}