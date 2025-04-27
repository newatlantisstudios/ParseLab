//
//  ViewController+Functions.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension with missing or ambiguous functions
extension ViewController {
    
    // MARK: - Layout Functions
    
    // Update layout based on current size class
    func updateLayoutForCurrentSizeClass() {
        // Update search UI layout
        updateSearchUILayout(for: traitCollection.horizontalSizeClass)
        
        // Update content layout for different device sizes
        if traitCollection.horizontalSizeClass == .compact {
            // iPhone (compact width)
            contentStackView.axis = .vertical
            
            // Reset minimap constraints for vertical layout
            for constraint in jsonMinimap.constraints where constraint.firstAttribute == .width {
                constraint.isActive = false
            }
            
            // Set minimap height for vertical layout
            jsonMinimap.heightAnchor.constraint(equalToConstant: 100).isActive = true
        } else {
            // iPad (regular width)
            contentStackView.axis = .horizontal
            
            // Reset minimap constraints for horizontal layout
            for constraint in jsonMinimap.constraints where constraint.firstAttribute == .height {
                constraint.isActive = false
            }
            
            // Set minimap width for horizontal layout
            jsonMinimap.widthAnchor.constraint(equalToConstant: 100).isActive = true
        }
        
        // Force layout update
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    // MARK: - Search Functions
    
    // Perform search action
    @objc func performSearch() {
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            showEnhancedToast(message: "Please enter a search term", type: ToastType.warning)
            return
        }
        
        // Get search options
        let searchKeys = searchKeysSwitch.isOn
        let searchValues = searchValuesSwitch.isOn
        let caseSensitive = caseSensitiveSwitch.isOn
        
        // Validate at least one search option is enabled
        if !searchKeys && !searchValues {
            showEnhancedToast(message: "Please select at least one search option (Keys or Values)", type: ToastType.warning)
            return
        }
        
        // Perform the search
        if let jsonObject = currentJsonObject {
            searchResults = jsonSearcher.search(
                jsonObject: jsonObject,
                searchText: searchText,
                searchKeys: searchKeys,
                searchValues: searchValues,
                caseSensitive: caseSensitive
            )
            
            // Update UI based on search results
            searchResultsTableView.reloadData()
            searchResultsTableView.isHidden = false
            
            // Show result count in toast message
            if searchResults.isEmpty {
                showEnhancedToast(message: "No results found", type: ToastType.info)
            } else {
                let resultText = searchResults.count == 1 ? "result" : "results"
                showEnhancedToast(message: "\(searchResults.count) \(resultText) found", type: ToastType.success)
            }
            
            // Ensure search results table is visible
            view.bringSubviewToFront(searchResultsTableView)
        } else {
            showEnhancedToast(message: "No JSON data to search", type: ToastType.error)
        }
    }
    
    // Close search UI
    @objc func closeSearchTapped() {
        // Hide search UI
        searchContainerView.isHidden = true
        searchResultsTableView.isHidden = true
        navigationContainerView.isHidden = false
        
        // Clear search text and results
        searchTextField.text = nil
        searchResults.removeAll()
        searchResultsTableView.reloadData()
        
        // Dismiss keyboard
        view.endEditing(true)
    }
    
    // MARK: - Helper Functions
}
