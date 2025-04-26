//
//  ViewController+SearchUI.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension to handle JSON search UI layout and functionality
extension ViewController {
    // Set up search UI with proper support for different device sizes
    func setupSearchUI() {
        // First, clear any existing subviews to prevent duplicates
        searchContainerView.subviews.forEach { $0.removeFromSuperview() }
        searchOptionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create stack views for each switch-label pair
        let keysStackView = createSwitchLabelPair(
            switchControl: searchKeysSwitch,
            label: searchKeysLabel
        )
        
        let valuesStackView = createSwitchLabelPair(
            switchControl: searchValuesSwitch,
            label: searchValuesLabel
        )
        
        let caseSensitiveStackView = createSwitchLabelPair(
            switchControl: caseSensitiveSwitch,
            label: caseSensitiveLabel
        )
        
        // Add paired stack views to the options stack view
        searchOptionsStackView.addArrangedSubview(keysStackView)
        searchOptionsStackView.addArrangedSubview(valuesStackView)
        searchOptionsStackView.addArrangedSubview(caseSensitiveStackView)
        
        // Set up initial layout based on current size class
        updateSearchUILayout(for: traitCollection.horizontalSizeClass)
        
        // Add search UI elements to the view hierarchy
        searchContainerView.addSubview(searchTextField)
        searchContainerView.addSubview(searchOptionsStackView)
        searchContainerView.addSubview(searchButton)
        searchContainerView.addSubview(closeSearchButton)
        
        // Ensure search container is on top in the view hierarchy
        view.bringSubviewToFront(searchContainerView)
        view.bringSubviewToFront(searchResultsTableView)
        
        // Set up search UI actions
        searchButton.addTarget(self, action: #selector(performSearch), for: .touchUpInside)
        closeSearchButton.addTarget(self, action: #selector(closeSearchTapped), for: .touchUpInside)
        searchTextField.delegate = self
        
        // Set up constraints for search UI
        setupSearchUIConstraints()
    }
    
    private func createSwitchLabelPair(switchControl: UISwitch, label: UILabel) -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.spacing = 4
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    stackView.addArrangedSubview(switchControl)
    stackView.addArrangedSubview(label)
    
    return stackView
    }
    
    private func setupSearchUIConstraints() {
    let layoutGuide = view.safeAreaLayoutGuide
    
    // First, remove any existing height constraints for search container
    for constraint in searchContainerView.constraints where constraint.firstAttribute == .height {
        constraint.isActive = false
    }
    
    NSLayoutConstraint.activate([
    // Search container constraints with proper z-index positioning
    searchContainerView.topAnchor.constraint(equalTo: navigationContainerView.topAnchor),
    searchContainerView.leadingAnchor.constraint(equalTo: navigationContainerView.leadingAnchor),
    searchContainerView.trailingAnchor.constraint(equalTo: navigationContainerView.trailingAnchor),
    
    // Search text field
    searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor, constant: 12),
    searchTextField.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 12),
    searchTextField.trailingAnchor.constraint(equalTo: closeSearchButton.leadingAnchor, constant: -8),
    searchTextField.heightAnchor.constraint(equalToConstant: 36),
    
    // Close button
    closeSearchButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
    closeSearchButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -12),
    closeSearchButton.widthAnchor.constraint(equalToConstant: 24),
    closeSearchButton.heightAnchor.constraint(equalToConstant: 24),
    
    // Search options stack view
    searchOptionsStackView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 12),
    searchOptionsStackView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 12),
    searchOptionsStackView.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -8),
    searchOptionsStackView.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: -12),
    
    // Search button
    searchButton.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: -12),
    searchButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -12),
    searchButton.heightAnchor.constraint(equalToConstant: 36),
    searchButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
    
    // Search results table view
    searchResultsTableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 8),
    searchResultsTableView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
    searchResultsTableView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16),
    searchResultsTableView.heightAnchor.constraint(equalToConstant: 200)
    ])
    }
    
    // Update layout based on size class (iPhone vs iPad)
    func updateSearchUILayout(for sizeClass: UIUserInterfaceSizeClass) {
        // Remove existing height constraint
        for constraint in searchContainerView.constraints where constraint.firstAttribute == .height {
            constraint.isActive = false
        }
        
        if sizeClass == .compact {
            // For iPhone (compact size class)
            searchOptionsStackView.axis = .vertical
            searchOptionsStackView.alignment = .leading
            searchOptionsStackView.spacing = 8
            searchContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        } else {
            // For iPad (regular size class)
            searchOptionsStackView.axis = .horizontal
            searchOptionsStackView.alignment = .center
            searchOptionsStackView.spacing = 16
            searchContainerView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        }
    }
}
