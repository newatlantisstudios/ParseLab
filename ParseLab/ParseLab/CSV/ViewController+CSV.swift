import UIKit

import ObjectiveC

// Extension to handle CSV file operations
// This extension uses a dedicated CSVToolbarManager instead of ModernToolbar
extension ViewController {
    
    
    // Show the CSV in table view
    internal func showCSVTableView(with document: CSVDocument) {
        // Create CSV table view controller
        let csvTableVC = CSVTableViewController(csvDocument: document)
        
        // Present it modally
        csvTableVC.modalPresentationStyle = .fullScreen
        
        // Add a completion handler to handle any errors
        present(csvTableVC, animated: true) { [weak self] in
            print("[DEBUG] CSV Table View presented successfully")
            
            // Ensure we're on the main thread for UI updates
            DispatchQueue.main.async {
                // Force layout again after presentation
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    // Property to access CSV toolbar manager
    internal func getOrCreateCSVToolbarManager() -> CSVToolbarManager {
        let csvToolbarKey = "com.parselab.csvToolbarManager"
        
        if let existingManager = objc_getAssociatedObject(self, csvToolbarKey) as? CSVToolbarManager {
            print("[DEBUG] Using existing CSVToolbarManager")
            return existingManager
        }
        
        let manager = CSVToolbarManager(viewController: self)
        objc_setAssociatedObject(self, csvToolbarKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        print("[DEBUG] CSVToolbarManager created")
        return manager
    }
    
    // Set up CSV view controls with the new toolbar manager approach
    internal func setupCSVViewControls() {
        // Guard against being called when no longer showing a CSV file
        guard isCSVFile else {
            print("[DEBUG] setupCSVViewControls called but isCSVFile is false - aborting")
            return
        }
        
        print("[DEBUG] Setting up CSV view controls - CSV file detected: \(isCSVFile)")
        
        // Force layout calculation first
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        // Ensure text view is showing the beginning of the content
        fileContentView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        
        // Ensure all core container views are visible
        contentStackView.isHidden = false
        contentStackView.alpha = 1.0
        fileContentView.isHidden = false
        fileContentView.alpha = 1.0
        
        // Always ensure tree button is hidden for CSV files
        if let treeButton = treeModeButton {
            print("[DEBUG] Found tree button - hiding it for CSV files")
            treeButton.isHidden = true
        }
        
        // Configure buttons for CSV mode
        if let rawButton = rawViewToggleButton {
            rawButton.setTitle("Raw", for: .normal)
            rawButton.isHidden = false
        }
        
        if let saveButton = saveButton {
            saveButton.isHidden = true
        }
        
        if let cancelButton = cancelButton {
            cancelButton.isHidden = true
        }
        
        // Enable minimap for CSV files
        isMinimapVisible = true
        
        // Use the modular toolbar manager for CSV configuration
        print("[DEBUG] Using modular toolbar manager for CSV configuration")
        self.modularToolbarManager?.configureForFileType(.csv)
        
        print("[DEBUG] CSV view controls setup complete with dedicated toolbar manager")
        
        // Force layout after setup
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    // A completely new approach to directly build the toolbar for CSV files
    private func setupCsvToolbarDirectly(tableViewButton: UIButton) {
        print("[DEBUG] Direct toolbar setup initiated")
        
        if let modernToolbar = actionsBar as? ModernToolbar {
            print("[DEBUG] Modern toolbar found")
            
            // Create new left items array with validate and edit buttons
            var leftItems: [UIView] = []
            
            // Add validate button first
            leftItems.append(validateButton)
            print("[DEBUG] Added validateButton to leftItems")
            
            // Add edit toggle button 
            leftItems.append(editToggleButton)
            print("[DEBUG] Added editToggleButton to leftItems")
            
            // Create center items with the view mode control (but hide tree button)
            let viewModeContainer = createViewModeControl()
            var centerItems: [UIView] = [viewModeContainer]
            print("[DEBUG] Added viewModeContainer to centerItems")
            
            // Create right items array with search and table view buttons
            var rightItems: [UIView] = []
            
            // Add search button first
            rightItems.append(searchToggleButton)
            print("[DEBUG] Added searchToggleButton to rightItems")
            
            // Add table view button
            rightItems.append(tableViewButton)
            print("[DEBUG] Added tableViewButton to rightItems")
            
            // Add file info button if it exists
            if let infoButton = fileInfoButton {
                rightItems.append(infoButton)
                print("[DEBUG] Added fileInfoButton to rightItems")
            }
            
            // Set all items on the toolbar
            modernToolbar.setLeftItems(leftItems)
            modernToolbar.setCenterItems(centerItems)
            modernToolbar.setRightItems(rightItems)
            
            // Force layout update
            modernToolbar.setNeedsLayout()
            modernToolbar.layoutIfNeeded()
            
            print("[DEBUG] Direct toolbar setup complete")
        } else {
            print("[DEBUG] Modern toolbar not found, using fallback")
            
            // Add table view button directly to view as fallback
            view.addSubview(tableViewButton)
            
            // Position it in a visible location
            NSLayoutConstraint.activate([
                tableViewButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
                tableViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                tableViewButton.widthAnchor.constraint(equalToConstant: 120),
                tableViewButton.heightAnchor.constraint(equalToConstant: 36)
            ])
            
            // Bring button to front to ensure visibility
            tableViewButton.layer.zPosition = 100
        }
    }
    
    // Helper to create a view mode control specifically for CSV
    private func createViewModeControl() -> UIView {
        let viewModeContainer = UIView()
        viewModeContainer.translatesAutoresizingMaskIntoConstraints = false
        viewModeContainer.backgroundColor = DesignSystem.Colors.backgroundTertiary
        viewModeContainer.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        viewModeContainer.clipsToBounds = true

        let textModeButton = UIButton(type: .system)
        textModeButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            let icon = UIImage(systemName: "doc", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
            textModeButton.setImage(icon, for: .normal)
        } else { textModeButton.setTitle("T", for: .normal) }
        textModeButton.backgroundColor = DesignSystem.Colors.primary // Initially selected
        textModeButton.tintColor = .white
        textModeButton.tag = 0

        let buttonPadding = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        textModeButton.contentEdgeInsets = buttonPadding
        textModeButton.imageView?.contentMode = .scaleAspectFit
        
        // Add to container
        viewModeContainer.addSubview(textModeButton)
        NSLayoutConstraint.activate([
            textModeButton.topAnchor.constraint(equalTo: viewModeContainer.topAnchor),
            textModeButton.bottomAnchor.constraint(equalTo: viewModeContainer.bottomAnchor),
            textModeButton.leadingAnchor.constraint(equalTo: viewModeContainer.leadingAnchor),
            textModeButton.trailingAnchor.constraint(equalTo: viewModeContainer.trailingAnchor)
        ])

        return viewModeContainer
    }
    
    // Final verification and fix for toolbar buttons
    private func verifyAndFixToolbarButtons(tableViewButton: UIButton) {
        if let modernToolbar = actionsBar as? ModernToolbar {
            // Dump the current state of the toolbar for diagnosis
            print("[DEBUG] Toolbar dump:")
            print("[DEBUG]   Left items: \(modernToolbar.leftStackView.arrangedSubviews.count) items")
            for (i, item) in modernToolbar.leftStackView.arrangedSubviews.enumerated() {
                if let button = item as? UIButton {
                    print("[DEBUG]     Left[\(i)]: Button with title \(button.title(for: .normal) ?? "nil")")
                } else {
                    print("[DEBUG]     Left[\(i)]: \(type(of: item))")
                }
            }
            
            print("[DEBUG]   Center items: \(modernToolbar.centerStackView.arrangedSubviews.count) items")
            
            print("[DEBUG]   Right items: \(modernToolbar.rightStackView.arrangedSubviews.count) items")
            for (i, item) in modernToolbar.rightStackView.arrangedSubviews.enumerated() {
                if let button = item as? UIButton {
                    print("[DEBUG]     Right[\(i)]: Button with title \(button.title(for: .normal) ?? "nil")")
                } else {
                    print("[DEBUG]     Right[\(i)]: \(type(of: item))")
                }
            }
            
            // Forcefully check if key buttons are missing and add them
            let leftItems = modernToolbar.leftStackView.arrangedSubviews
            let rightItems = modernToolbar.rightStackView.arrangedSubviews
            
            // Check if validate button is missing
            var hasValidateButton = false
            for item in leftItems {
                if item === validateButton {
                    hasValidateButton = true
                    break
                }
            }
            
            if !hasValidateButton {
                print("[DEBUG] validateButton missing! Adding it")
                modernToolbar.leftStackView.insertArrangedSubview(validateButton, at: 0)
            }
            
            // Check if search button is missing
            var hasSearchButton = false
            for item in rightItems {
                if item === searchToggleButton {
                    hasSearchButton = true
                    break
                }
            }
            
            if !hasSearchButton {
                print("[DEBUG] searchToggleButton missing! Adding it")
                modernToolbar.rightStackView.insertArrangedSubview(searchToggleButton, at: 0)
            }
            
            // Final check if table view button is there
            var hasTableViewButton = false
            for item in leftItems {
                if let button = item as? UIButton, button.title(for: .normal) == "Table View" {
                    hasTableViewButton = true
                    break
                }
            }
            
            if !hasTableViewButton {
                // Try the right items too
                for item in rightItems {
                    if let button = item as? UIButton, button.title(for: .normal) == "Table View" {
                        hasTableViewButton = true
                        break
                    }
                }
                
                // If still missing, add it
                if !hasTableViewButton {
                    print("[DEBUG] Table View button missing! Adding it to left items")
                    if let rawButton = rawViewToggleButton, modernToolbar.leftStackView.arrangedSubviews.contains(rawButton) {
                        let rawIndex = modernToolbar.leftStackView.arrangedSubviews.firstIndex(of: rawButton) ?? 0
                        modernToolbar.leftStackView.insertArrangedSubview(tableViewButton, at: rawIndex + 1)
                    } else {
                        modernToolbar.leftStackView.addArrangedSubview(tableViewButton)
                    }
                }
            }
            
            // Make sure everything is visible
            validateButton.isHidden = false
            validateButton.isEnabled = true
            searchToggleButton.isHidden = false
            searchToggleButton.isEnabled = true
            editToggleButton.isHidden = false
            editToggleButton.isEnabled = true
            tableViewButton.isHidden = false
            tableViewButton.isEnabled = true
            
            // Force layout refresh
            modernToolbar.setNeedsLayout()
            modernToolbar.layoutIfNeeded()
        }
    }
    
    // Emergency function to force toolbar buttons to be visible for CSV files
    @objc internal func emergencyCSVToolbarFix() {
        print("[EMERGENCY FIX] Applying emergency toolbar fix for CSV files")
        
        // Get the CSV toolbar manager and show it
        let toolbarManager = getOrCreateCSVToolbarManager()
        
        // Show the dedicated CSV toolbar
        toolbarManager.showCSVToolbar()
        
        // Force layout update
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        print("[EMERGENCY FIX] Emergency toolbar fix complete with dedicated toolbar")
    }
    
    // Handle table view button tap
    @objc internal func tableViewButtonTapped() {
        print("[DEBUG] tableViewButtonTapped called")
        
        // Force the view to layout before proceeding
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        if let csvDocument = currentCSVDocument {
            print("[DEBUG] Using existing CSV document for table view")
            // Use a longer delay to ensure all UI updates are complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.showCSVTableView(with: csvDocument)
                
                // Re-enable the button if found
                if let actionBar = self.actionsBar as? ModernToolbar {
                    for item in actionBar.getAllItems() {
                        if let button = item as? UIButton, button.title(for: .normal) == "Table View" {
                            button.isEnabled = true
                        }
                    }
                } else if let actionBar = self.actionsBar as? UIView {
                    for subview in actionBar.subviews {
                        if let button = subview as? UIButton, button.title(for: .normal) == "Table View" {
                            button.isEnabled = true
                        }
                    }
                }
            }
        } else {
            // Try to parse the content if needed
            if let csvString = fileContentView.text {
                print("[DEBUG] Parsing CSV text for table view")
                // Parse CSV without try since we made it non-throwing
                let csvData = CSVParser.parse(csvString: csvString, filePath: currentFileUrl)
                currentCSVDocument = csvData
                
                // Use a longer delay to ensure all UI updates are complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    self.showCSVTableView(with: csvData)
                    
                    // Re-enable the button if found
                    if let actionBar = self.actionsBar as? ModernToolbar {
                        for item in actionBar.getAllItems() {
                            if let button = item as? UIButton, button.title(for: .normal) == "Table View" {
                                button.isEnabled = true
                            }
                        }
                    } else if let actionBar = self.actionsBar as? UIView {
                        for subview in actionBar.subviews {
                            if let button = subview as? UIButton, button.title(for: .normal) == "Table View" {
                                button.isEnabled = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Toggle between text view and table view modes
    internal func toggleCSVViewMode() {
        isCSVTableViewEnabled = !isCSVTableViewEnabled
        
        // Reload the current CSV file with the new mode
        if let url = currentFileUrl, let data = try? Data(contentsOf: url) {
            // First, set the flag that we'll check in handleFileUrl
            self.isCSVFile = true
            
            // Now display the file content normally
            displayFileContent(url: url, data: data)
        }
    }
}