//
//  ViewController+SearchUI.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Required to use SearchResultCell

// Extension to handle JSON search UI layout and functionality
extension ViewController {
    // Set up search UI with proper support for different device sizes
    func setupSearchUI() {
        // First, clear any existing subviews to prevent duplicates
        searchContainerView.subviews.forEach { $0.removeFromSuperview() }
        searchOptionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Make the search container visible with background
        searchContainerView.backgroundColor = DesignSystem.Colors.backgroundSecondary
        searchContainerView.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        searchContainerView.layer.shadowColor = UIColor.black.cgColor
        searchContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchContainerView.layer.shadowOpacity = 0.2
        searchContainerView.layer.shadowRadius = 4
        
        // Create improved switch-label pairs with better visual distinction
        let keysStackView = createImprovedSwitchLabelPair(
            switchControl: searchKeysSwitch,
            label: searchKeysLabel,
            icon: UIImage(systemName: "key.fill")
        )
        
        let valuesStackView = createImprovedSwitchLabelPair(
            switchControl: searchValuesSwitch,
            label: searchValuesLabel,
            icon: UIImage(systemName: "doc.text.fill")
        )
        
        let caseSensitiveStackView = createImprovedSwitchLabelPair(
            switchControl: caseSensitiveSwitch,
            label: caseSensitiveLabel,
            icon: UIImage(systemName: "textformat.size")
        )
        
        // Add paired stack views to the options stack view
        searchOptionsStackView.addArrangedSubview(keysStackView)
        searchOptionsStackView.addArrangedSubview(valuesStackView)
        searchOptionsStackView.addArrangedSubview(caseSensitiveStackView)
        
        // Set up initial layout based on current size class
        updateSearchUILayout(for: traitCollection.horizontalSizeClass)
        
        // Make sure both views are added to the main view hierarchy first
        if searchContainerView.superview == nil {
            view.addSubview(searchContainerView)
        }
        if searchResultsTableView.superview == nil {
            view.addSubview(searchResultsTableView)
        }
        if navigationContainerView.superview == nil {
            view.addSubview(navigationContainerView)
        }
        
        // Update search field with search icon
        setupSearchTextField()
        
        // Style the close button
        if #available(iOS 13.0, *) {
            closeSearchButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
        closeSearchButton.tintColor = DesignSystem.Colors.textSecondary
        
        // Add search UI elements to the search container view
        searchContainerView.addSubview(searchTextField)
        searchContainerView.addSubview(searchOptionsStackView)
        searchContainerView.addSubview(searchButton)
        searchContainerView.addSubview(closeSearchButton)
        
        // Ensure search container is on top in the view hierarchy
        view.bringSubviewToFront(searchContainerView)
        view.bringSubviewToFront(searchResultsTableView)
        
        // Set up search UI actions
        searchButton.addTarget(self, action: #selector(performSearch(_:)), for: .touchUpInside)
        closeSearchButton.addTarget(self, action: #selector(closeSearchTapped(_:)), for: .touchUpInside)
        searchTextField.delegate = self
        
        // Apply styling to search button to make it visible and accessible
        searchButton.backgroundColor = DesignSystem.Colors.primary
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        searchButton.isUserInteractionEnabled = true
        searchButton.accessibilityLabel = "Search JSON"
        searchButton.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.semibold)
        
        // Add padding to button for better touchability
        searchButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        // Add "Return" key functionality to search field
        searchTextField.returnKeyType = .search
        
        // Set up constraints for search UI
        setupSearchUIConstraints()
        
        // Configure search results table view
        configureSearchResultsTableView()
    }
    
    // Configure the search text field with a search icon
    private func setupSearchTextField() {
        // Create a search icon view
        if #available(iOS 13.0, *) {
            let searchIconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            searchIconView.tintColor = DesignSystem.Colors.textSecondary
            searchIconView.contentMode = .scaleAspectFit
            searchIconView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            
            // Add some padding
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
            paddingView.addSubview(searchIconView)
            searchIconView.center = CGPoint(x: 15, y: 10)
            
            // Set as left view
            searchTextField.leftView = paddingView
            searchTextField.leftViewMode = .always
        }
        
        // Apply modern styling
        searchTextField.applySearchStyle()
    }
    
    // Create an improved switch-label pair with icon
    private func createImprovedSwitchLabelPair(switchControl: UISwitch, label: UILabel, icon: UIImage? = nil) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = DesignSystem.Spacing.small
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a container for the switch and label
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = DesignSystem.Colors.backgroundTertiary
        contentView.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        
        // Create the icon view if an icon is provided
        if let icon = icon {
            let iconView = UIImageView(image: icon)
            iconView.tintColor = DesignSystem.Colors.textSecondary
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add icon to the stack
            stackView.addArrangedSubview(iconView)
            
            // Set icon size constraints
            NSLayoutConstraint.activate([
                iconView.widthAnchor.constraint(equalToConstant: DesignSystem.Sizing.smallIconSize),
                iconView.heightAnchor.constraint(equalToConstant: DesignSystem.Sizing.smallIconSize)
            ])
        }
        
        // Update label style
        label.font = DesignSystem.Typography.bodyMedium().withWeight(.medium)
        
        // Add switch and label to the stack
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(switchControl)
        
        return stackView
    }
    
    // Configure the search results table view
    private func configureSearchResultsTableView() {
        // Apply styling to table view
        searchResultsTableView.backgroundColor = DesignSystem.Colors.background
        searchResultsTableView.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        
        // Apply shadow
        let shadow = DesignSystem.Shadow.medium()
        searchResultsTableView.layer.shadowColor = shadow.color
        searchResultsTableView.layer.shadowOffset = shadow.offset
        searchResultsTableView.layer.shadowOpacity = shadow.opacity
        searchResultsTableView.layer.shadowRadius = shadow.radius
        searchResultsTableView.clipsToBounds = false
        
        // Add a title view to the search results
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: searchResultsTableView.bounds.width, height: 44))
        headerView.backgroundColor = DesignSystem.Colors.backgroundSecondary
        
        let headerLabel = UILabel(frame: CGRect(x: 16, y: 0, width: headerView.bounds.width - 32, height: 44))
        headerLabel.text = "Search Results"
        headerLabel.font = DesignSystem.Typography.bodyMedium().withWeight(.semibold)
        headerLabel.textColor = DesignSystem.Colors.primary
        
        // Add a clear results button
        let clearButton = UIButton(type: .system)
        clearButton.frame = CGRect(x: headerView.bounds.width - 80, y: 0, width: 64, height: 44)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.tintColor = DesignSystem.Colors.primary
        clearButton.addTarget(self, action: #selector(clearSearchResults), for: .touchUpInside)
        
        headerView.addSubview(headerLabel)
        headerView.addSubview(clearButton)
        searchResultsTableView.tableHeaderView = headerView
        
        // Add a special empty results view to display when no results found
        let emptyView = createEmptyResultsView()
        searchResultsTableView.backgroundView = emptyView
        
        // Register custom cell
        searchResultsTableView.register(SearchResultCellImpl.self, forCellReuseIdentifier: "SearchResultCell")
        
        // Set row height for better spacing
        searchResultsTableView.rowHeight = 72
        searchResultsTableView.separatorStyle = .none
    }
    
    // Create an empty results view
    private func createEmptyResultsView() -> UIView {
        let view = UIView()
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = DesignSystem.Colors.backgroundTertiary
        container.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "magnifyingglass")
            imageView.tintColor = DesignSystem.Colors.textSecondary
        }
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No results found"
        label.font = DesignSystem.Typography.bodyMedium()
        label.textColor = DesignSystem.Colors.textSecondary
        label.textAlignment = .center
        
        container.addSubview(imageView)
        container.addSubview(label)
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 200),
            container.heightAnchor.constraint(equalToConstant: 120),
            
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: DesignSystem.Spacing.medium),
            imageView.widthAnchor.constraint(equalToConstant: DesignSystem.Sizing.largeIconSize),
            imageView.heightAnchor.constraint(equalToConstant: DesignSystem.Sizing.largeIconSize),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: DesignSystem.Spacing.medium),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: DesignSystem.Spacing.small),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -DesignSystem.Spacing.small),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -DesignSystem.Spacing.medium)
        ])
        
        // Hide by default - will be shown when results are empty
        view.isHidden = true
        
        return view
    }
    
    // Set up constraints for search UI with improved layout
    private func setupSearchUIConstraints() {
        let layoutGuide = view.safeAreaLayoutGuide
        
        // First, remove any existing height constraints for search container
        for constraint in searchContainerView.constraints where constraint.firstAttribute == .height {
            constraint.isActive = false
        }
        
        // Remove existing constraints between searchContainerView and navigationContainerView
        // to prevent issues when they don't share the same parent view
        for constraint in view.constraints {
            if (constraint.firstItem === searchContainerView && constraint.secondItem === navigationContainerView) ||
               (constraint.firstItem === navigationContainerView && constraint.secondItem === searchContainerView) {
                constraint.isActive = false
            }
        }
        
        // Ensure both views have a common ancestor (the main view) before setting constraints
        NSLayoutConstraint.activate([
            // Search container constraints - position at a visible location
            searchContainerView.topAnchor.constraint(equalTo: mainToolbar.bottomAnchor, constant: 16),
            searchContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: DesignSystem.Spacing.medium),
            searchContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -DesignSystem.Spacing.medium),
            
            // Search text field with improved height
            searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor, constant: DesignSystem.Spacing.medium),
            searchTextField.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: DesignSystem.Spacing.medium),
            searchTextField.trailingAnchor.constraint(equalTo: closeSearchButton.leadingAnchor, constant: -DesignSystem.Spacing.small),
            searchTextField.heightAnchor.constraint(equalToConstant: DesignSystem.Sizing.buttonHeight),
            
            // Close button
            closeSearchButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            closeSearchButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -DesignSystem.Spacing.medium),
            closeSearchButton.widthAnchor.constraint(equalToConstant: DesignSystem.Sizing.buttonHeight),
            closeSearchButton.heightAnchor.constraint(equalToConstant: DesignSystem.Sizing.buttonHeight),
            
            // Search options stack view
            searchOptionsStackView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: DesignSystem.Spacing.medium),
            searchOptionsStackView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: DesignSystem.Spacing.medium),
            searchOptionsStackView.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -DesignSystem.Spacing.medium),
            searchOptionsStackView.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: -DesignSystem.Spacing.medium),
            
            // Search button with improved size
            searchButton.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: -DesignSystem.Spacing.medium),
            searchButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -DesignSystem.Spacing.medium),
            searchButton.heightAnchor.constraint(equalToConstant: DesignSystem.Sizing.buttonHeight),
            searchButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            // Search results table view with more space
            searchResultsTableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: DesignSystem.Spacing.small),
            searchResultsTableView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: DesignSystem.Spacing.medium),
            searchResultsTableView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -DesignSystem.Spacing.medium),
            searchResultsTableView.heightAnchor.constraint(equalToConstant: 300)  // Increased height
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
            searchOptionsStackView.spacing = DesignSystem.Spacing.small
            searchContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        } else {
            // For iPad (regular size class)
            searchOptionsStackView.axis = .horizontal
            searchOptionsStackView.alignment = .center
            searchOptionsStackView.spacing = DesignSystem.Spacing.medium
            searchContainerView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        }
    }
    
    // Clear search results
    @objc func clearSearchResults() {
        searchResults.removeAll()
        searchResultsTableView.reloadData()
        
        // Show the empty view state
        searchResultsTableView.backgroundView?.isHidden = false
    }
    
    // Implement table view cell for search results
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? SearchResultCellImpl else {
            return UITableViewCell()
        }
        
        // Get the result and configure the cell
        let result = searchResults[indexPath.row]
        cell.configure(with: result)
        
        return cell
    }
    
    // Handle empty results state
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Show or hide the empty results view based on the search results count
        tableView.backgroundView?.isHidden = !searchResults.isEmpty
    }
    
    // Perform search when search button is tapped
    @objc func performSearch(_ sender: UIButton) {
        // Show visual feedback that button was pressed
        UIView.animate(withDuration: 0.1, animations: {
            sender.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.alpha = 1.0
            }
        }
        
        // Check for valid inputs
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            showToast(message: "Please enter a search term", type: .warning)
            return
        }
        
        guard currentJsonObject != nil else {
            showToast(message: "Please load a JSON file first", type: .warning)
            return
        }
        
        // Perform the search using JSONSearcher
        searchResults = jsonSearcher.search(
            jsonObject: currentJsonObject!,
            searchText: searchText,
            searchKeys: searchKeysSwitch.isOn,
            searchValues: searchValuesSwitch.isOn,
            caseSensitive: caseSensitiveSwitch.isOn
        )
        
        // Show search results
        searchResultsTableView.reloadData()
        searchResultsTableView.isHidden = false
        
        // Show appropriate message based on results
        if searchResults.isEmpty {
            showToast(message: "No results found", type: .info)
            searchResultsTableView.backgroundView?.isHidden = false
        } else {
            showToast(message: "Found \(searchResults.count) results", type: .success)
            searchResultsTableView.backgroundView?.isHidden = true
        }
        
        // Make sure search results are in front
        view.bringSubviewToFront(searchResultsTableView)
        
        // Dismiss keyboard
        searchTextField.resignFirstResponder()
    }
    
    // Close search UI when close button is tapped
    @objc func closeSearchTapped(_ sender: UIButton) {
        // Hide search UI elements
        searchContainerView.isHidden = true
        searchResultsTableView.isHidden = true
        
        // Show navigation container
        navigationContainerView.isHidden = false
        
        // Clear search results if needed
        // searchResults = []
        // searchResultsTableView.reloadData()
        
        // Force layout update
        view.layoutIfNeeded()
    }
}
