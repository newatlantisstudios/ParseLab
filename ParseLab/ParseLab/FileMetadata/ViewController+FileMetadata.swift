//
//  ViewController+FileMetadata.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension to handle file metadata display
extension ViewController {
    
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
        metadataToContentConstraint = contentStackView.topAnchor.constraint(equalTo: fileMetadataView.bottomAnchor, constant: 16)
        metadataToContentConstraint.priority = .defaultHigh
        
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
        
        // Create file info button
        fileInfoButton = UIButton(type: .system)
        fileInfoButton.setTitle("File Info", for: .normal)
        fileInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        fileInfoButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to actions stack view
        self.addFileInfoButtonToActions(fileInfoButton)
        
        // Add target action
        fileInfoButton.addTarget(self, action: #selector(toggleFileMetadataView), for: .touchUpInside)
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
            fileInfoButton.setTitle("Hide Info", for: .normal)
            
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
                metadataToContentConstraint.isActive = true
            }
            
            // Update layout for new constraints
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            // Hide the metadata view
            fileMetadataView.isHidden = true
            fileInfoButton.setTitle("File Info", for: .normal)
            
            // Deactivate metadata constraint and reactivate original content stack constraint
            if metadataToContentConstraint.isActive {
                metadataToContentConstraint.isActive = false
            }
            
            if let originalConstraint = originalContentStackTopConstraint {
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
