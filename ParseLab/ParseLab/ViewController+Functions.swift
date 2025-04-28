//
//  ViewController+Functions.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// MARK: - Layout Constraint Properties
var regularConstraints: [NSLayoutConstraint] = []
var compactConstraints: [NSLayoutConstraint] = []
var minimapWidthConstraint: NSLayoutConstraint?

// Extension with missing or ambiguous functions
extension ViewController {
    
    // Track if tree view is currently shown
    var isShowingTree: Bool {
        return isTreeViewVisible
    }
    
    // MARK: - Layout Functions
    
    // Update layout based on current size class
    func updateLayoutForSizeClass() {
        if traitCollection.horizontalSizeClass == .regular {
            // iPad or large size class - tree on left, content on right
            NSLayoutConstraint.deactivate(compactConstraints)
            NSLayoutConstraint.activate(regularConstraints)
            
            // Show tree controller
            if !treeViewController.view.isDescendant(of: self.view) {
                addChild(treeViewController)
                view.addSubview(treeViewController.view)
                treeViewController.didMove(toParent: self)
            }
            treeViewController.view.isHidden = false
            
        } else {
            // iPhone or compact size class - tree hidden, content full width
            NSLayoutConstraint.deactivate(regularConstraints)
            NSLayoutConstraint.activate(compactConstraints)
            
            // Hide tree controller completely and remove from view hierarchy when not displayed
            treeViewController.view.isHidden = true
            if !isShowingTree && treeViewController.view.isDescendant(of: self.view) {
                treeViewController.willMove(toParent: nil)
                treeViewController.view.removeFromSuperview()
                treeViewController.removeFromParent()
            }
        }
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
