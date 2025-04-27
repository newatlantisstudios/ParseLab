//
//  ModernToolbarFix.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

extension ModernToolbar {
    
    /// Ensures that all buttons in the toolbar are properly displayed
    /// Ensures that all buttons in the toolbar are properly displayed
        func ensureButtonsAreVisible() {
            // Make the stack views visible
            leftStackView.isHidden = false
            centerStackView.isHidden = false
            rightStackView.isHidden = false
            
            // Force layout of the toolbar
            layoutIfNeeded()
            
            // If left section is empty, ensure all buttons are added back
            if leftStackView.arrangedSubviews.isEmpty {
                // Re-add the left items (validate and format buttons)
                guard let viewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController as? ViewController else {
                    return
                }
                
                // Use guard to verify buttons exist but don't use conditional binding
                guard viewController.validateButton != nil,
                      viewController.formatJsonButton != nil else {
                    return
                }
                
                setLeftItems([viewController.validateButton, viewController.formatJsonButton])
                
                // Use the public getter method to access right items
                let currentItems = getRightItems()
                setRightItems(currentItems)
            }
            
            // Update buttons for better visibility
            for sectionStack in [leftStackView, centerStackView, rightStackView] {
                for view in sectionStack.arrangedSubviews {
                    if let button = view as? UIButton {
                        // Ensure button is visible
                        button.isHidden = false
                        
                        // Apply high compression resistance
                        button.setContentCompressionResistancePriority(.required, for: .horizontal)
                        
                        // Set minimum width for visibility
                        let minWidthConstraint = button.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
                        minWidthConstraint.priority = .defaultHigh
                        minWidthConstraint.isActive = true
                    }
                }
            }
            
            // Force layout update
            layoutSubviews()
        }
    
    /// Updates all items in the toolbar for better visibility
    private func updateAllItems() {
        // Process all items in all sections
        for (index, item) in getAllItems().enumerated() {
            // Ensure each item is properly configured
            if let button = item as? UIButton {
                // Apply high compression resistance
                button.setContentCompressionResistancePriority(.required, for: .horizontal)
                
                // Set minimum width for button visibility
                let minWidthConstraint = button.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
                minWidthConstraint.priority = .defaultHigh
                minWidthConstraint.isActive = true
                
                // Add shadow to make more visible
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.1
                button.layer.shadowOffset = CGSize(width: 0, height: 1)
                button.layer.shadowRadius = 1
                
                // Ensure open and sample buttons are properly styled
                if button.title(for: .normal) == "Open" {
                    // Make open button more prominent
                    button.backgroundColor = DesignSystem.Colors.primary
                    button.setTitleColor(.white, for: .normal)
                    button.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
                    
                    // If it's in the first position, ensure it's visible
                    if index == 0 {
                        // Make sure it has high priority for visibility
                        button.setContentHuggingPriority(.required, for: .horizontal)
                    }
                }
                else if button.title(for: .normal) == "Sample" {
                    // Style sample button
                    button.backgroundColor = DesignSystem.Colors.backgroundTertiary
                    button.setTitleColor(DesignSystem.Colors.primary, for: .normal)
                    button.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
                }
            }
        }
    }
}

/// Extension to add custom toolbar setup methods to ViewController
extension ViewController {
    /// Fix the main toolbar to ensure both Open and Sample buttons are visible
    func fixMainToolbar() {
        // Check if mainToolbar is a ModernToolbar
        guard let toolbar = mainToolbar as? ModernToolbar else {
            // If not a ModernToolbar, try to replace it with SimpleTwoButtonToolbar
            replaceWithSimpleTwoButtonToolbar()
            return
        }
        // Get references to the existing buttons
        let existingOpenButton = self.openButton
        let existingSampleButton = self.loadSampleButton
        
        // Create new buttons with more prominent styling
        let newOpenButton = ToolbarButton(title: "Open", icon: UIImage(systemName: "folder"), isPrimary: true)
        newOpenButton.addTarget(self, action: #selector(openFileButtonTapped), for: .touchUpInside)
        
        let newSampleButton = ToolbarButton(title: "Sample", icon: UIImage(systemName: "doc.text"), isPrimary: false)
        newSampleButton.addTarget(self, action: #selector(loadSampleButtonTapped), for: .touchUpInside)
        
        // Add edit button with the same styling
        let newEditButton = ToolbarButton(title: "Edit", icon: UIImage(systemName: "pencil"), isPrimary: false)
        newEditButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        
        // Create a container view with both buttons side by side
        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStack = UIStackView(arrangedSubviews: [newOpenButton, newSampleButton, newEditButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 16
        buttonContainer.addSubview(buttonStack)
        
        // Set up constraints for the button stack
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
        ])
        
        // Clear existing buttons - using the toolbar reference
        toolbar.setLeftItems([])
        toolbar.setRightItems([])
        
        // Add both buttons to the toolbar
        toolbar.addSubview(buttonContainer)
        
        // Center the container in the toolbar
        NSLayoutConstraint.activate([
            buttonContainer.centerXAnchor.constraint(equalTo: toolbar.centerXAnchor),
            buttonContainer.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            buttonContainer.widthAnchor.constraint(lessThanOrEqualTo: toolbar.widthAnchor, constant: -32),
            buttonContainer.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Update references to the new buttons
        self.openButton = newOpenButton
        self.loadSampleButton = newSampleButton
        
        // Force layout update
        toolbar.layoutIfNeeded()
    }
}
