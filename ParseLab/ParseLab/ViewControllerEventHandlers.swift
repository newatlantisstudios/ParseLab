import UIKit
import ObjectiveC

// Extension with disambiguation for event handlers
extension ViewController {
    
    // Public implementation for search button functionality
    @objc func handleSearchButtonTapped() {
        guard currentJsonObject != nil else {
            // Show toast message for better UX
            showToast(message: "Please load a JSON file first", type: .warning)
            return
        }
        
        // Create a stylized search controller with a semi-transparent background
        let searchVC = UIViewController()
        searchVC.modalPresentationStyle = .overCurrentContext
        searchVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        // Create a container for search elements with card-like appearance
        let containerView = UIView()
        containerView.backgroundColor = DesignSystem.Colors.backgroundSecondary
        containerView.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowRadius = 8
        
        // Create search field with app styling
        let searchField = UITextField()
        searchField.placeholder = "Search JSON keys and values..."
        searchField.borderStyle = .roundedRect
        searchField.autocorrectionType = .no
        searchField.backgroundColor = DesignSystem.Colors.background
        searchField.textColor = DesignSystem.Colors.text
        searchField.font = DesignSystem.Typography.bodyMedium()
        searchField.translatesAutoresizingMaskIntoConstraints = false
        
        // Add search icon to text field
        if #available(iOS 13.0, *) {
            let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            searchIcon.tintColor = DesignSystem.Colors.textSecondary
            searchIcon.contentMode = .scaleAspectFit
            
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
            paddingView.addSubview(searchIcon)
            searchIcon.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
            
            searchField.leftView = paddingView
            searchField.leftViewMode = .always
        }
        
        // Add options for search (checkboxes)
        let optionsStack = UIStackView()
        optionsStack.axis = .horizontal
        optionsStack.distribution = .equalSpacing
        optionsStack.spacing = 16
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Keys checkbox
        let keysSwitch = UISwitch()
        keysSwitch.isOn = true
        keysSwitch.onTintColor = DesignSystem.Colors.primary
        keysSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let keysLabel = UILabel()
        keysLabel.text = "Search in keys"
        keysLabel.font = DesignSystem.Typography.bodySmall()
        keysLabel.textColor = DesignSystem.Colors.textSecondary
        
        let keysStack = UIStackView(arrangedSubviews: [keysSwitch, keysLabel])
        keysStack.axis = .horizontal
        keysStack.spacing = 8
        keysStack.alignment = .center
        
        // Values checkbox
        let valuesSwitch = UISwitch()
        valuesSwitch.isOn = true
        valuesSwitch.onTintColor = DesignSystem.Colors.primary
        valuesSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let valuesLabel = UILabel()
        valuesLabel.text = "Search in values"
        valuesLabel.font = DesignSystem.Typography.bodySmall()
        valuesLabel.textColor = DesignSystem.Colors.textSecondary
        
        let valuesStack = UIStackView(arrangedSubviews: [valuesSwitch, valuesLabel])
        valuesStack.axis = .horizontal
        valuesStack.spacing = 8
        valuesStack.alignment = .center
        
        optionsStack.addArrangedSubview(keysStack)
        optionsStack.addArrangedSubview(valuesStack)
        
        // Create search button with app styling
        let searchButton = UIButton(type: .system)
        searchButton.setTitle("Search", for: .normal)
        searchButton.backgroundColor = DesignSystem.Colors.primary
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        searchButton.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.semibold)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Create cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(DesignSystem.Colors.textSecondary, for: .normal)
        cancelButton.backgroundColor = DesignSystem.Colors.backgroundTertiary
        cancelButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        cancelButton.titleLabel?.font = DesignSystem.Typography.bodyMedium()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add action to cancel button
        cancelButton.addAction(UIAction { [weak searchVC] _ in
            searchVC?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        // Add buttons in a row
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, searchButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 16
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Add elements to container view
        containerView.addSubview(searchField)
        containerView.addSubview(optionsStack)
        containerView.addSubview(buttonStack)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add container to the search view controller
        searchVC.view.addSubview(containerView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Container positioning
            containerView.centerXAnchor.constraint(equalTo: searchVC.view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: searchVC.view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: searchVC.view.widthAnchor, multiplier: 0.85),
            
            // Search field
            searchField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            searchField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            searchField.heightAnchor.constraint(equalToConstant: 44),
            
            // Options stack
            optionsStack.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            optionsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            optionsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Button stack
            buttonStack.topAnchor.constraint(equalTo: optionsStack.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add action to search button
        searchButton.addAction(UIAction { [weak self, weak searchField, weak searchVC, weak keysSwitch, weak valuesSwitch] _ in
            guard let self = self, let searchText = searchField?.text, !searchText.isEmpty else { return }
            
            // Get options values
            let searchInKeys = keysSwitch?.isOn ?? true
            let searchInValues = valuesSwitch?.isOn ?? true
            
            // Perform search
            self.searchResults = self.jsonSearcher.search(
                jsonObject: self.currentJsonObject!,
                searchText: searchText,
                searchKeys: searchInKeys,
                searchValues: searchInValues,
                caseSensitive: false
            )
            
            // Dismiss search view
            searchVC?.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                // Update UI with search results
                if self.searchResults.isEmpty {
                    self.showToast(message: "No results found", type: .info)
                } else {
                    self.showToast(message: "Found \(self.searchResults.count) results", type: .success)
                    
                    // Show results in a new view or alert
                    DispatchQueue.main.async {
                        self.showSearchResults()
                    }
                }
            }
        }, for: .touchUpInside)
        
        // Present the search controller
        present(searchVC, animated: true) {
            // Focus on search field
            searchField.becomeFirstResponder()
        }
    }
    
    // Show search results in a stylized table view
    func showSearchResults() {
        guard !searchResults.isEmpty else { return }
        
        // Create results view controller
        let resultsVC = UIViewController()
        resultsVC.modalPresentationStyle = .pageSheet
        
        // Create table view for results
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = DesignSystem.Colors.background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(SearchResultCellImpl.self, forCellReuseIdentifier: "SearchResultCell")
        
        // Set up table view data source and delegate
        let dataSource = SearchResultsDataSource(results: searchResults)
        tableView.dataSource = dataSource
        
        // Store reference to prevent deallocation
        objc_setAssociatedObject(tableView, "dataSource", dataSource, .OBJC_ASSOCIATION_RETAIN)
        
        // Add table view to results view controller
        resultsVC.view.addSubview(tableView)
        
        // Set up navigation bar
        let navBar = UINavigationBar()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.backgroundColor = DesignSystem.Colors.backgroundSecondary
        
        let navItem = UINavigationItem(title: "Search Results (\(searchResults.count))")
        let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        closeButton.tintColor = DesignSystem.Colors.primary
        closeButton.action = #selector(dismissSearchResults(_:))
        closeButton.target = self
        navItem.rightBarButtonItem = closeButton
        navBar.items = [navItem]
        
        resultsVC.view.addSubview(navBar)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: resultsVC.view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: resultsVC.view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: resultsVC.view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: resultsVC.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: resultsVC.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: resultsVC.view.bottomAnchor)
        ])
        
        // Present results view controller
        present(resultsVC, animated: true)
    }
    
    // Add this method to handle dismissing the resultsVC
    @objc func dismissSearchResults(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Data source for search results table view
    class SearchResultsDataSource: NSObject, UITableViewDataSource {
        let results: [JSONSearchResult]
        
        init(results: [JSONSearchResult]) {
            self.results = results
            super.init()
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return results.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? SearchResultCellImpl else {
                return UITableViewCell()
            }
            
            let result = results[indexPath.row]
            cell.configure(with: result)
            return cell
        }
    }
    
    // Placeholder for edit button action
    @objc func editButtonTapped() {
        print("[ACTION LOG] editButtonTapped called!")
        // TODO: Implement logic to enter edit mode or present SimpleModalEditor
        // Example: Using SimpleModalEditor approach
        print("Using SimpleModalEditor approach")
        let currentText = fileContentView.attributedText?.string ?? fileContentView.text ?? "{}"
        let editor = SimpleModalEditor(textToEdit: currentText)
        editor.delegate = self
        present(editor, animated: true)
    }

    // Placeholder for format JSON action
    @objc func formatJsonTapped() {
        print("Format JSON button tapped - action TBD")
        // TODO: Implement logic to format JSON in fileContentView
        // Example: Deferring to existing formatJson in ViewController+JsonEdit
        formatJson()
    }
    
    // Handle raw/formatted view toggle
    @objc func handleRawViewToggleButtonTapped() {
        print("[DEBUG] handleRawViewToggleButtonTapped: forwarding to toggleRawView")
        // Delegate to the RawView extension
        self.toggleRawView()
    }
    
    // Handle view mode segmented control changes
    @objc func handleViewModeChanged(_ sender: UISegmentedControl) {
        // ... (existing code) ...
    }
    
    // Implement the validateJsonTapped method
    @objc func validateJsonTapped() {
        print("[DEBUG] validateJsonTapped entered")
        guard let jsonObject = currentJsonObject else {
            print("[DEBUG] validateJsonTapped: currentJsonObject is nil")
            showErrorMessage("No valid data loaded")
            return
        }
        print("[DEBUG] validateJsonTapped: currentJsonObject is valid")

        // Count elements in the JSON structure
        var objectCount = 0
        var arrayCount = 0
        var stringCount = 0
        var numberCount = 0
        var boolCount = 0
        var nullCount = 0
        var maxDepth = 0
        
        func analyzeJson(_ json: Any, depth: Int = 0) {
            maxDepth = max(maxDepth, depth)
            
            if let dict = json as? [String: Any] {
                objectCount += 1
                for (_, value) in dict {
                    analyzeJson(value, depth: depth + 1)
                }
            } else if let array = json as? [Any] {
                arrayCount += 1
                for item in array {
                    analyzeJson(item, depth: depth + 1)
                }
            } else if json is String {
                stringCount += 1
            } else if json is NSNumber {
                if CFGetTypeID(json as CFTypeRef) == CFBooleanGetTypeID() {
                    boolCount += 1
                } else {
                    numberCount += 1
                }
            } else if json is NSNull {
                nullCount += 1
            }
        }
        
        analyzeJson(jsonObject)
        
        // Determine the format based on the file type
        let formatName = isTOMLFile ? "TOML" : (isYAMLFile ? "YAML" : (isINIFile ? "INI" : "JSON"))
        
        let stats = """
        \(formatName) Validation Results:
        • Structure is valid \(formatName)
        • Max depth: \(maxDepth)
        
        Elements:
        • Objects: \(objectCount)
        • Arrays: \(arrayCount)
        • Strings: \(stringCount)
        • Numbers: \(numberCount)
        • Booleans: \(boolCount)
        • Null values: \(nullCount)
        
        Total elements: \(objectCount + arrayCount + stringCount + numberCount + boolCount + nullCount)
        """
        print("[DEBUG] validateJsonTapped: Generated stats:\n\(stats)")

        let baseFont = fileContentView.font ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
        let attributedString = NSAttributedString(
            string: stats,
            attributes: [.foregroundColor: UIColor.label, .font: baseFont]
        )
        
        // Ensure UI update happens on the main thread
        DispatchQueue.main.async {
            print("[DEBUG] validateJsonTapped: Updating fileContentView.isHidden = \(self.fileContentView.isHidden)")
            self.fileContentView.attributedText = attributedString
            print("[DEBUG] validateJsonTapped: fileContentView updated. New text: \(self.fileContentView.text ?? "NIL")")
            
            // Show success toast with appropriate format name
            self.showToast(message: "\(formatName) is valid", type: .success)
        }
    }
    
    // Handle button mode changes for custom button segment
    @objc func buttonModeChanged(_ sender: UIButton) {
        guard currentJsonObject != nil else {
            showToast(message: "Please load a JSON file first", type: .warning)
            return
        }

        let selectedTag = sender.tag
        let showTreeView = (selectedTag == 1) // 1 = Tree, 0 = Text

        // Update button appearances
        updateModeButtonsUI(selectedMode: selectedTag)

        // Switch the view
        if showTreeView {
            switchToTreeView(animated: true)
        } else {
            switchToTextView(animated: true)
            updateJsonDisplayFormat()
        }
        // (Raw toggle remains visible in both text and tree modes)
    }
    
    // Update the UI state of our custom mode buttons
    func updateModeButtonsUI(selectedMode: Int) {
        if selectedMode == 0 { // Text mode selected
            textModeButton?.backgroundColor = DesignSystem.Colors.primary
            textModeButton?.tintColor = .white
            treeModeButton?.backgroundColor = .clear
            treeModeButton?.tintColor = DesignSystem.Colors.textSecondary
        } else { // Tree mode selected
            textModeButton?.backgroundColor = .clear
            textModeButton?.tintColor = DesignSystem.Colors.textSecondary
            treeModeButton?.backgroundColor = DesignSystem.Colors.primary
            treeModeButton?.tintColor = .white
        }
    }

    // Setup button targets with explicit references
    // MARK: - Button Action Setup (Moved from MainUI for clarity)

    func setupButtonActions() {
        // Actions defined in this file or other ViewController extensions
        // Apply optional chaining (?) only to properties declared as optional (?) or implicitly unwrapped (!)
        openButton.addTarget(self, action: #selector(openFileButtonTapped), for: .touchUpInside)
        loadSampleButton.addTarget(self, action: #selector(loadSampleButtonTapped), for: .touchUpInside)
        validateButton.addTarget(self, action: #selector(validateJsonTapped), for: .touchUpInside)
        // Format button removed as requested
        searchToggleButton.addTarget(self, action: #selector(handleSearchButtonTapped), for: .touchUpInside)
        editToggleButton?.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        // rawViewToggleButton target already set in setupRawViewToggle(), no need to add duplicate handler
        
        // View Mode (Text/Tree) - handled by custom buttons now
        textModeButton?.addTarget(self, action: #selector(buttonModeChanged(_:)), for: .touchUpInside)
        treeModeButton?.addTarget(self, action: #selector(buttonModeChanged(_:)), for: .touchUpInside)
        
        // Search UI Buttons
        searchButton.addTarget(self, action: #selector(performSearch(_:)), for: .touchUpInside)
        closeSearchButton.addTarget(self, action: #selector(closeSearchTapped(_:)), for: .touchUpInside)
        
        // Edit Mode Buttons (Save/Cancel) - Actions likely set in setupEditControls
        saveButton?.addTarget(self, action: #selector(saveJsonChanges), for: .touchUpInside)
        cancelButton?.addTarget(self, action: #selector(cancelEditing), for: .touchUpInside)
        
        // File Info Button - Action set where button is created/added
        // Note: fileInfoButton itself might be the custom InfoButtonView which handles its own tap
        
        // Also handle editFab (UIView?)
        (editFab as? UIButton)?.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside) 
    }

    // Note: @objc methods like openFileButtonTapped, loadSampleButtonTapped, etc., 
    // are assumed to be defined in ViewController+FileOperations.swift or elsewhere.
}
