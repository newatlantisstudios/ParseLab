//
//  ViewController+FileMetadata.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension to handle file metadata display
extension ViewController {
    
    // Create a dedicated row for buttons including the info button
    private func createInfoButtonRow() -> UIView {
        // Create container
        let buttonRowContainer = UIView()
        buttonRowContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonRowContainer.backgroundColor = .clear
        
        // Create stack view for buttons
        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .equalSpacing
        buttonStack.alignment = .center
        buttonStack.spacing = 12
        
        // Create our custom info view
        let infoView = InfoButtonView(size: 36)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.onTap = { [weak self] in
            self?.toggleFileMetadataView()
        }
        
        // Store reference
        self.fileInfoButton = infoView
        
        // Add buttons to stack
        buttonStack.addArrangedSubview(infoView)
        
        // Add stack to container
        buttonRowContainer.addSubview(buttonStack)
        
        // Set constraints
        NSLayoutConstraint.activate([
            buttonStack.centerXAnchor.constraint(equalTo: buttonRowContainer.centerXAnchor),
            buttonStack.centerYAnchor.constraint(equalTo: buttonRowContainer.centerYAnchor),
            buttonStack.topAnchor.constraint(equalTo: buttonRowContainer.topAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: buttonRowContainer.bottomAnchor),
            buttonRowContainer.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return buttonRowContainer
    }
    
    // Set up the file metadata view
    func setupFileMetadataView() {
        // Create the file metadata view
        fileMetadataView = FileMetadataView()
        fileMetadataView.translatesAutoresizingMaskIntoConstraints = false
        fileMetadataView.isHidden = true // Initially hidden
        fileMetadataView.backgroundColor = .systemBackground
        fileMetadataView.layer.cornerRadius = 8
        fileMetadataView.layer.borderWidth = 0.5
        fileMetadataView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Add to main view
        view.addSubview(fileMetadataView)
        
        // Store the original content stack view top constraint for later toggle
        // First check contentStackView's own constraints
        for constraint in contentStackView.constraints {
            if let firstItem = constraint.firstItem as? UIView, firstItem == contentStackView,
               constraint.firstAttribute == .top {
                originalContentStackTopConstraint = constraint
                break
            }
        }
        
        // If not found, check view's constraints
        if originalContentStackTopConstraint == nil {
            for constraint in view.constraints {
                if let firstItem = constraint.firstItem as? UIView, firstItem == contentStackView,
                   constraint.firstAttribute == .top {
                    originalContentStackTopConstraint = constraint
                    break
                } else if let secondItem = constraint.secondItem as? UIView, secondItem == contentStackView,
                          constraint.secondAttribute == .top {
                    // Handle cases where contentStackView might be the second item
                    originalContentStackTopConstraint = constraint
                    break
                }
            }
        }
        
        // Create constraint to adjust content stack view position when metadata is shown
        // Only if both views are in the hierarchy
        if fileMetadataView.superview == view && contentStackView.superview == view {
            metadataToContentConstraint = contentStackView.topAnchor.constraint(equalTo: fileMetadataView.bottomAnchor, constant: 16)
            metadataToContentConstraint.priority = .defaultHigh
        } else {
            // Create a placeholder constraint that will be replaced later
            metadataToContentConstraint = NSLayoutConstraint()
        }
        
        // Add constraints for metadata view - ensure views are in the hierarchy first
        if navigationContainerView.superview == view {
            NSLayoutConstraint.activate([
                fileMetadataView.topAnchor.constraint(equalTo: navigationContainerView.bottomAnchor, constant: 16),
                fileMetadataView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                fileMetadataView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
            ])
        } else {
            // Fallback if navigation container view is not in the hierarchy yet
            let layoutGuide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                fileMetadataView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 120), // Approximate position
                fileMetadataView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
                fileMetadataView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16)
            ])
        }
        
        // We now use the info button in the toolbar instead of a separate row
        // let infoButtonRow = createInfoButtonRow()
        // view.addSubview(infoButtonRow)
        
        // // Add constraints for the button row, checking if navigationContainerView is in the hierarchy
        // if navigationContainerView.superview == view {
        //     NSLayoutConstraint.activate([
        //         infoButtonRow.topAnchor.constraint(equalTo: navigationContainerView.bottomAnchor, constant: 8),
        //         infoButtonRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        //         infoButtonRow.heightAnchor.constraint(equalToConstant: 44)
        //     ])
        // } else {
        //     // Fallback if navigation container view is not in hierarchy
        //     NSLayoutConstraint.activate([
        //         infoButtonRow.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
        //         infoButtonRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        //         infoButtonRow.heightAnchor.constraint(equalToConstant: 44)
        //     ])
        // }
        
        // Update content stack constraint to use navigationContainerView instead of info button row
        if contentStackView.superview == view {
            if let originalConstraint = originalContentStackTopConstraint {
                originalConstraint.isActive = false
            }
            
            if navigationContainerView.superview == view {
                // New constraint from content to navigation container
                let contentTopConstraint = contentStackView.topAnchor.constraint(equalTo: navigationContainerView.bottomAnchor, constant: 12)
                contentTopConstraint.isActive = true
                originalContentStackTopConstraint = contentTopConstraint
            }
        }
    }
    
    // Toggle the file metadata view visibility
    @objc func toggleFileMetadataView() {
        // Only show if we have a current file URL
        guard let fileUrl = currentFileUrl else {
            showToast(message: "No file loaded")
            return
        }
        
        // Toggle visibility
        fileMetadataVisible = !fileMetadataVisible
        
        if fileMetadataVisible {
            // Bring file metadata view to front
            view.bringSubviewToFront(fileMetadataView)
            fileMetadataView.isHidden = false
            
            // Update button state
            if let infoView = fileInfoButton as? InfoButtonView {
                infoView.setActive(true)
            } else {
                // Fallback for other button types
                fileInfoButton.tintColor = DesignSystem.Colors.primary
            }
            
            // Get file metadata from the manager
            if let metadata = FileMetadataManager.shared.getMetadata(for: fileUrl) {
                // Update with comprehensive metadata
                fileMetadataView.updateWithFileURL(fileUrl)
            } else {
                // Simple update if metadata can't be retrieved
                fileMetadataView.updateWithFileURL(fileUrl)
            }
            
            // If it's a JSON file, add some JSON-specific metadata
            if let jsonObject = currentJsonObject {
                // Count objects in JSON
                var counts = countJsonElements(jsonObject)
                
                // Add JSON-specific metadata
                var jsonMetadata: [String: String] = [:]
                
                if counts.totalCount > 0 {
                    jsonMetadata["JSON Elements"] = "\(counts.totalCount) total"
                    
                    if counts.objectCount > 0 {
                        jsonMetadata["Objects"] = "\(counts.objectCount)"
                    }
                    
                    if counts.arrayCount > 0 {
                        jsonMetadata["Arrays"] = "\(counts.arrayCount)"
                    }
                    
                    if counts.valueCount > 0 {
                        jsonMetadata["Values"] = "\(counts.valueCount)"
                    }
                    
                    jsonMetadata["Max Depth"] = "\(counts.maxDepth)"
                }
                
                // Update with JSON-specific metadata
                fileMetadataView.updateWithFileURL(fileUrl, customData: jsonMetadata)
            }
            
            // Deactivate original content stack constraint and activate metadata constraint
            if let originalConstraint = originalContentStackTopConstraint {
                originalConstraint.isActive = false
            }
            
            // Make sure both views are in the view hierarchy before activating the constraint
            if fileMetadataView.superview == view && contentStackView.superview == view {
                // If metadataToContentConstraint is a placeholder, create a proper one now
                if metadataToContentConstraint.firstAttribute == .notAnAttribute {
                    metadataToContentConstraint = contentStackView.topAnchor.constraint(equalTo: fileMetadataView.bottomAnchor, constant: 16)
                    metadataToContentConstraint.priority = .defaultHigh
                }
                metadataToContentConstraint.isActive = true
            }
            
            // Update layout for new constraints
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            // Hide the metadata view
            fileMetadataView.isHidden = true
            
            // Reset button state
            if let infoView = fileInfoButton as? InfoButtonView {
                infoView.setActive(false)
            } else {
                // Fallback for other button types
                fileInfoButton.tintColor = .systemBlue
            }
            
            // Deactivate metadata constraint and reactivate original content stack constraint
            if metadataToContentConstraint.firstAttribute != .notAnAttribute && metadataToContentConstraint.isActive {
                metadataToContentConstraint.isActive = false
            }
            
            if let originalConstraint = originalContentStackTopConstraint, contentStackView.superview == view {
                originalConstraint.isActive = true
            }
            
            // Update layout for original constraints
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // Helper method to count elements in JSON
    private func countJsonElements(_ json: Any) -> (objectCount: Int, arrayCount: Int, valueCount: Int, maxDepth: Int, totalCount: Int) {
        var objectCount = 0
        var arrayCount = 0
        var valueCount = 0
        var maxDepth = 0
        
        func countElements(_ json: Any, depth: Int = 0) {
            maxDepth = max(maxDepth, depth)
            
            if let dict = json as? [String: Any] {
                objectCount += 1
                for (_, value) in dict {
                    countElements(value, depth: depth + 1)
                }
            } else if let array = json as? [Any] {
                arrayCount += 1
                for item in array {
                    countElements(item, depth: depth + 1)
                }
            } else {
                valueCount += 1
            }
        }
        
        countElements(json)
        let totalCount = objectCount + arrayCount + valueCount
        
        return (objectCount, arrayCount, valueCount, maxDepth, totalCount)
    }
}
