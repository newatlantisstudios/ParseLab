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
        // Setup search UI first
        setupSearchUI()
        
        // Setup file metadata view after other UI elements are in place
        // This ensures the navigation container view is already in the view hierarchy
        DispatchQueue.main.async {
            self.setupFileMetadataView()
        }
        
        // Register search result cells
        searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
        
        // Setup delegates 
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchTextField.delegate = self
        
        // Setup actions
        searchButton.addTarget(self, action: #selector(self.performSearch), for: .touchUpInside)
        closeSearchButton.addTarget(self, action: #selector(self.closeSearchTapped), for: .touchUpInside)
        
        // Apply initial layout based on current device
        updateSearchUILayout(for: traitCollection.horizontalSizeClass)
    }
}
