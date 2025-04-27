//
//  ViewController+Notifications.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Toast notification type for different UI styles
enum ToastType {
    case success
    case warning
    case error
    case info
}

// Extension to handle notifications and toasts
extension ViewController {
    
    /// Show a toast message with the specified type
    /// - Parameters:
    ///   - message: The message to display
    ///   - type: The type of toast (success, warning, error, info)
    ///   - duration: How long to show the toast (in seconds)
    func showToast(message: String, type: ToastType, duration: TimeInterval = 2.0) {
        // Remove any existing toasts first
        view.subviews.forEach { subview in
            if subview.tag == 9999 {
                subview.removeFromSuperview()
            }
        }
        
        // Create toast container
        let toastContainer = UIView()
        toastContainer.tag = 9999
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.layer.cornerRadius = 8
        toastContainer.clipsToBounds = true
        
        // Set up colors based on type
        switch type {
        case .success:
            toastContainer.backgroundColor = UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 0.9)
        case .warning:
            toastContainer.backgroundColor = UIColor(red: 0.9, green: 0.6, blue: 0.0, alpha: 0.9)
        case .error:
            toastContainer.backgroundColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 0.9)
        case .info:
            toastContainer.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 0.9)
        }
        
        // Create icon based on type if iOS 13+
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        
        if #available(iOS 13.0, *) {
            var iconName = ""
            switch type {
            case .success:
                iconName = "checkmark.circle.fill"
            case .warning:
                iconName = "exclamationmark.triangle.fill"
            case .error:
                iconName = "xmark.circle.fill"
            case .info:
                iconName = "info.circle.fill"
            }
            iconView.image = UIImage(systemName: iconName)
        }
        
        // Create label for toast message
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        
        // Add views to container
        toastContainer.addSubview(iconView)
        toastContainer.addSubview(messageLabel)
        
        // Add to main view and ensure it's on top of all other elements
        view.addSubview(toastContainer)
        view.bringSubviewToFront(toastContainer)
        
        // Setup constraints with improved positioning to avoid overlapping with the edit button
        NSLayoutConstraint.activate([
            toastContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toastContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toastContainer.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -140), // Leave space for edit button
            
            iconView.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: toastContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            messageLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -12),
            messageLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -8)
        ])
        
        // Animate in
        toastContainer.alpha = 0
        toastContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            toastContainer.alpha = 1
            toastContainer.transform = CGAffineTransform.identity
        }, completion: { _ in
            // Animate out after duration
            UIView.animate(withDuration: 0.3, delay: duration, options: [.curveEaseIn], animations: {
                toastContainer.alpha = 0
                toastContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}
