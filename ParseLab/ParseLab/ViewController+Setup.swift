//
//  ViewController+Setup.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Helper extension to ensure all our UI elements are properly set up
extension ViewController {
    // Call this method from setupUI in the main ViewController
    func setupUIComponents() {
        // Apply modern design to all UI elements
        applyModernDesignToUI()
        
        // Setup search UI first
        setupSearchUI()
        
        // Setup file metadata view after other UI elements are in place
        // This ensures the navigation container view is already in the view hierarchy
        DispatchQueue.main.async {
            self.setupFileMetadataView()
        }
        
        // Register search result cells
        searchResultsTableView.register(SearchResultCell.self, forCellReuseIdentifier: "SearchResultCell")
        
        // Setup delegates 
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchTextField.delegate = self
        
        // Setup actions
        searchButton.addTarget(self, action: #selector(performSearch(_:)), for: .touchUpInside)
        closeSearchButton.addTarget(self, action: #selector(closeSearchTapped(_:)), for: .touchUpInside)
        
        // Apply initial layout based on current device
        updateSearchUILayout(for: traitCollection.horizontalSizeClass)
        
        // Adaptive button display for compact width
        updateButtonForSizeClass()
    }
    
    // Setup keyboard and other notifications
    internal func setupNotifications() {
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
    }
    
    // Apply modern design to all UI elements
    private func applyModernDesignToUI() {
        // Top actions toolbar
        mainToolbar.applyCardStyle()
        mainToolbar.backgroundColor = DesignSystem.Colors.backgroundSecondary
        
        // Main content area
        fileContentView.applyCodeStyle()
        
        // Action buttons
        openButton.applyPrimaryStyle()
        loadSampleButton.applySecondaryStyle()
        validateButton.applySecondaryStyle()
        searchToggleButton.applySecondaryStyle()
        minimapToggleButton.applySecondaryStyle()
        
        // Card containers
        navigationContainerView.applyCardStyle(shadowLevel: 0)
        searchContainerView.applyCardStyle(shadowLevel: 0)
        searchResultsTableView.applyModernStyle()
        
        // Search elements
        searchTextField.applySearchStyle()
        searchButton.applyPrimaryStyle()
        
        // Make close search button more visually appealing
        closeSearchButton.applyIconButtonStyle(primaryColor: false)
        
        // Update view mode segmented control
        if #available(iOS 13.0, *) {
            viewModeSegmentedControl.selectedSegmentTintColor = DesignSystem.Colors.primary
            viewModeSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            viewModeSegmentedControl.setTitleTextAttributes([.font: DesignSystem.Typography.bodyMedium()], for: .normal)
        }
        
        // Edit controls
        if rawViewToggleButton != nil {
            rawViewToggleButton.applySecondaryStyle()
        }
        if editToggleButton != nil {
            editToggleButton.applySecondaryStyle()
        }
        if saveButton != nil {
            saveButton.applyPrimaryStyle()
        }
        if cancelButton != nil {
            cancelButton.applySecondaryStyle()
        }
        
        // Tree view controls
        if treeViewControlsContainer != nil {
            treeViewControlsContainer.applyCardStyle(shadowLevel: 0)
        }
        if expandAllButton != nil {
            expandAllButton.applyIconButtonStyle(primaryColor: true)
        }
        if collapseAllButton != nil {
            collapseAllButton.applyIconButtonStyle(primaryColor: true)
        }
    }
    
    // Create a visually appealing welcome message with app features
    func createWelcomeMessage() -> NSAttributedString {
        let welcomeTitle = "Welcome to ParseLab"
        let welcomeDesc = "A modern tool for working with JSON files"
        let featuresTitle = "Features"
        let features = [
            "• Syntax highlighting for JSON",
            "• Tree view for complex structures",
            "• JSON validation and error checking",
            "• JSON Schema validation",
            "• Search within JSON keys and values",
            "• Edit and save JSON files"
        ]
        let startingGuide = [
            "To get started:",
            "• Tap \"Open File\" to select a file from your device",
            "• Tap \"Load Sample\" to view a sample JSON file",
            "• Open a JSON file from the Files app by selecting ParseLab"
        ]
        
        let attributedString = NSMutableAttributedString()
        
        // Title - Use fonts with standard fallbacks
        let titleFont = UIFont.systemFont(ofSize: 28, weight: .bold)
        let titleColor = UIColor.systemBlue
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: titleColor
        ]
        attributedString.append(NSAttributedString(string: welcomeTitle + "\n", attributes: titleAttributes))
        
        // Description
        let descFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        let descColor = UIColor.darkText
        let descAttributes: [NSAttributedString.Key: Any] = [
            .font: descFont,
            .foregroundColor: descColor
        ]
        attributedString.append(NSAttributedString(string: welcomeDesc + "\n\n", attributes: descAttributes))
        
        // Features title
        let featuresTitleFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
        let featuresTitleColor = UIColor.systemIndigo
        let featuresTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: featuresTitleFont,
            .foregroundColor: featuresTitleColor
        ]
        attributedString.append(NSAttributedString(string: featuresTitle + "\n", attributes: featuresTitleAttributes))
        
        // Features list
        let featuresFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        let featuresColor = UIColor.darkText
        let featuresAttributes: [NSAttributedString.Key: Any] = [
            .font: featuresFont,
            .foregroundColor: featuresColor
        ]
        let featuresText = features.joined(separator: "\n")
        attributedString.append(NSAttributedString(string: featuresText + "\n\n", attributes: featuresAttributes))
        
        // Getting started
        let startingTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: featuresTitleFont,
            .foregroundColor: featuresTitleColor
        ]
        attributedString.append(NSAttributedString(string: "Getting Started\n", attributes: startingTitleAttributes))
        
        let startingAttributes: [NSAttributedString.Key: Any] = [
            .font: featuresFont,
            .foregroundColor: featuresColor
        ]
        let startingText = startingGuide.joined(separator: "\n")
        attributedString.append(NSAttributedString(string: startingText, attributes: startingAttributes))
        
        return attributedString
    }
    
    // Enhanced toast message with modern styling
    func showEnhancedToast(message: String, type: ToastType = .info, duration: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            // Create the container view
            let toastContainer = UIView()
            toastContainer.translatesAutoresizingMaskIntoConstraints = false
            toastContainer.alpha = 0
            toastContainer.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
            
            // Set the proper background color based on the type
            switch type {
            case .success:
                toastContainer.backgroundColor = DesignSystem.Colors.success.withAlphaComponent(0.9)
            case .error:
                toastContainer.backgroundColor = DesignSystem.Colors.error.withAlphaComponent(0.9)
            case .warning:
                toastContainer.backgroundColor = DesignSystem.Colors.warning.withAlphaComponent(0.9)
            case .info:
                toastContainer.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.9)
            }
            
            // Add shadow for elevation
            let shadow = DesignSystem.Shadow.medium()
            toastContainer.layer.shadowColor = shadow.color
            toastContainer.layer.shadowOffset = shadow.offset
            toastContainer.layer.shadowOpacity = shadow.opacity
            toastContainer.layer.shadowRadius = shadow.radius
            toastContainer.clipsToBounds = false
            
            // Create the label
            let toastLabel = UILabel()
            toastLabel.textColor = .white
            toastLabel.text = message
            toastLabel.numberOfLines = 0
            toastLabel.textAlignment = .center
            toastLabel.font = DesignSystem.Typography.bodyMedium().withWeight(.medium)
            toastLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Create an icon based on the type
            let iconImageView = UIImageView()
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            iconImageView.tintColor = .white
            
            // Set the proper icon based on the type
            if #available(iOS 13.0, *) {
                switch type {
                case .success:
                    iconImageView.image = UIImage(systemName: "checkmark.circle.fill")
                case .error:
                    iconImageView.image = UIImage(systemName: "exclamationmark.circle.fill")
                case .warning:
                    iconImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
                case .info:
                    iconImageView.image = UIImage(systemName: "info.circle.fill")
                }
            }
            
            // Add the subviews to the container
            toastContainer.addSubview(iconImageView)
            toastContainer.addSubview(toastLabel)
            
            // Add the container to the view and ensure it's on top of all other elements
            self.view.addSubview(toastContainer)
            self.view.bringSubviewToFront(toastContainer)
            
            // Setup the constraints
            NSLayoutConstraint.activate([
                iconImageView.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: DesignSystem.Spacing.medium),
                iconImageView.centerYAnchor.constraint(equalTo: toastContainer.centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: DesignSystem.Sizing.iconSize),
                iconImageView.heightAnchor.constraint(equalToConstant: DesignSystem.Sizing.iconSize),
                
                toastLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: DesignSystem.Spacing.small),
                toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -DesignSystem.Spacing.medium),
                toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: DesignSystem.Spacing.small),
                toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -DesignSystem.Spacing.small),
                
                // Position toast at the bottom middle of the screen
                toastContainer.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -DesignSystem.Spacing.large),
                toastContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                toastContainer.widthAnchor.constraint(lessThanOrEqualTo: self.view.widthAnchor, constant: -DesignSystem.Spacing.large)
            ])
            
            // Animate the toast showing
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                toastContainer.alpha = 1
            }, completion: { _ in
                // Animate the toast hiding
                UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseInOut, animations: {
                    toastContainer.alpha = 0
                }, completion: { _ in
                    toastContainer.removeFromSuperview()
                })
            })
        }
    }
    
    // Toast types for different message types
    enum ToastType {
        case success
        case error
        case warning
        case info
    }
    
    // MARK: - Adaptive Button Display
    func updateButtonForSizeClass() {
        let isCompact = traitCollection.horizontalSizeClass == .compact

        // Raw view toggle button
        if let rawButton = rawViewToggleButton {
            let rawIcon = UIImage(systemName: "doc.plaintext")
            if isCompact {
                rawButton.setTitle("", for: .normal)
                rawButton.setImage(rawIcon, for: .normal)
                rawButton.imageEdgeInsets = .zero
                rawButton.imageView?.contentMode = .scaleAspectFit
                rawButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2) // Debug background
            } else {
                let title = isRawViewMode ? "Formatted" : "Raw"
                rawButton.setTitle(title, for: .normal)
                rawButton.setImage(rawIcon, for: .normal)
                rawButton.imageEdgeInsets = .zero
                rawButton.imageView?.contentMode = .scaleAspectFit
                rawButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2) // Debug background
            }
        }

        // Tree mode button
        if let treeButton = treeModeButton {
            let treeIcon = UIImage(systemName: "list.bullet")
            if isCompact {
                treeButton.setTitle("", for: .normal)
                treeButton.setImage(treeIcon, for: .normal)
                treeButton.imageEdgeInsets = .zero
                treeButton.imageView?.contentMode = .scaleAspectFit
                treeButton.backgroundColor = .clear
            } else {
                treeButton.setTitle("", for: .normal)
                treeButton.setImage(treeIcon, for: .normal)
                treeButton.imageEdgeInsets = .zero
                treeButton.imageView?.contentMode = .scaleAspectFit
                treeButton.backgroundColor = .clear
            }
        }

        // Edit button
        if let editButton = editToggleButton {
            let editIcon = UIImage(systemName: "pencil")
            if isCompact {
                editButton.setTitle("", for: .normal)
                editButton.setImage(editIcon, for: .normal)
                editButton.imageEdgeInsets = .zero
                editButton.imageView?.contentMode = .scaleAspectFit
                editButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2) // Debug background
            } else {
                editButton.setTitle("Edit", for: .normal)
                editButton.setImage(editIcon, for: .normal)
                editButton.imageEdgeInsets = .zero
                editButton.imageView?.contentMode = .scaleAspectFit
                editButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2) // Debug background
            }
        }
    }
}
