//
//  UIView+Toast.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension to add toast capability to UIView
extension UIView {
    
    /// Shows a simple toast message on any UIView
    /// - Parameters:
    ///   - message: The message to display
    ///   - duration: How long the toast should appear (default: 3 seconds)
    public func showSimpleToast(message: String, duration: TimeInterval = 3.0) {
        // Check if a toast is already visible and remove it
        self.subviews.forEach { subview in
            if subview.tag == 9999 {
                subview.removeFromSuperview()
            }
        }
        
        // Create toast container
        let toastContainer = UIView()
        toastContainer.tag = 9999
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.layer.cornerRadius = 12
        toastContainer.clipsToBounds = true
        toastContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        toastContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        toastContainer.layer.shadowOpacity = 1.0
        toastContainer.layer.shadowRadius = 4
        toastContainer.clipsToBounds = false
        
        // Set background color (simple dark background)
        if #available(iOS 13.0, *) {
            toastContainer.backgroundColor = UIColor.systemGray.withAlphaComponent(0.9)
        } else {
            toastContainer.backgroundColor = UIColor(white: 0.3, alpha: 0.9)
        }
        
        // Create message label
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        // Add components to container
        toastContainer.addSubview(label)
        self.addSubview(toastContainer)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Toast container
            toastContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            toastContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            toastContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            
            // Label
            label.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -12)
        ])
        
        // Animate the toast in
        toastContainer.alpha = 0
        toastContainer.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            toastContainer.alpha = 1
            toastContainer.transform = .identity
        })
        
        // Automatically dismiss after the duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                toastContainer.alpha = 0
                toastContainer.transform = CGAffineTransform(translationX: 0, y: 50)
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        }
    }
    
    /// Shows a toast with buttons
    /// - Parameters:
    ///   - message: The message to display
    ///   - primaryButtonTitle: Title for the primary action button (default: "OK")
    ///   - secondaryButtonTitle: Optional title for the secondary action button (default: nil)
    ///   - primaryAction: Closure to execute when the primary button is tapped
    ///   - secondaryAction: Optional closure to execute when the secondary button is tapped
    ///   - duration: How long the toast should appear before auto-dismissing (default: nil = stay until button press)
    public func showToastWithButtons(
        message: String,
        primaryButtonTitle: String = "OK",
        secondaryButtonTitle: String? = nil,
        primaryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil,
        duration: TimeInterval? = nil
    ) {
        // Check if a toast is already visible and remove it
        self.subviews.forEach { subview in
            if subview.tag == 9999 {
                subview.removeFromSuperview()
            }
        }
        
        // Create toast container
        let toastContainer = UIView()
        toastContainer.tag = 9999
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.layer.cornerRadius = 12
        toastContainer.clipsToBounds = true
        toastContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        toastContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        toastContainer.layer.shadowOpacity = 1.0
        toastContainer.layer.shadowRadius = 4
        toastContainer.clipsToBounds = false
        
        // Set background color
        if #available(iOS 13.0, *) {
            toastContainer.backgroundColor = UIColor.secondarySystemBackground
        } else {
            toastContainer.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        }
        
        // Create message label
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        if #available(iOS 13.0, *) {
            label.textColor = UIColor.label
        } else {
            label.textColor = UIColor.black
        }
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        // Create stack view for buttons
        let buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 8
        buttonStackView.distribution = .fillEqually
        
        // Create primary button
        let primaryButton = UIButton(type: .system)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.setTitle(primaryButtonTitle, for: .normal)
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.backgroundColor = UIColor.systemBlue
        primaryButton.layer.cornerRadius = 8
        // Remove fixed height constraint that's causing conflicts
        // primaryButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        // Create secondary button if needed
        var secondaryButton: UIButton?
        if let secondaryTitle = secondaryButtonTitle {
            secondaryButton = UIButton(type: .system)
            secondaryButton?.translatesAutoresizingMaskIntoConstraints = false
            secondaryButton?.setTitle(secondaryTitle, for: .normal)
            secondaryButton?.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
            secondaryButton?.layer.cornerRadius = 8
            // Remove fixed height constraint that's causing conflicts
            // secondaryButton?.heightAnchor.constraint(equalToConstant: 32).isActive = true
        }
        
        // Add actions to buttons
        primaryButton.addAction(UIAction(handler: { _ in
            self.hideToast(view: toastContainer)
            primaryAction?()
        }), for: .touchUpInside)
        
        if let secondaryButton = secondaryButton {
            secondaryButton.addAction(UIAction(handler: { _ in
                self.hideToast(view: toastContainer)
                secondaryAction?()
            }), for: .touchUpInside)
        }
        
        // Add buttons to stack
        buttonStackView.addArrangedSubview(primaryButton)
        if let secondaryButton = secondaryButton {
            buttonStackView.addArrangedSubview(secondaryButton)
        }
        
        // Add components to container
        toastContainer.addSubview(label)
        toastContainer.addSubview(buttonStackView)
        
        // Add container to view
        self.addSubview(toastContainer)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Toast container
            toastContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            toastContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            toastContainer.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Message label
            label.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 16),
            
            // Button stack
            buttonStackView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -16)
        ])
        
        // Add minimum height constraints for buttons instead of exact height
        primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true
        secondaryButton?.heightAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true
        
        // Animate the toast in
        toastContainer.alpha = 0
        toastContainer.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            toastContainer.alpha = 1
            toastContainer.transform = .identity
        })
        
        // Automatically dismiss after the duration if specified
        if let duration = duration {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.hideToast(view: toastContainer)
            }
        }
    }
    
    private func hideToast(view: UIView) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 50)
        }, completion: { _ in
            view.removeFromSuperview()
        })
    }
}
