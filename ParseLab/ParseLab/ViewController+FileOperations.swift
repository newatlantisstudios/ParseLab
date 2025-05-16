//
//  ViewController+FileOperations.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit
import UniformTypeIdentifiers

// Extension to handle file operations
extension ViewController {
    
    // Enable the info button appropriately based on its type
    private func enableInfoButton() {
        if let infoView = fileInfoButton as? InfoButtonView {
            infoView.isEnabled = true
        } else if let button = fileInfoButton as? UIButton {
            button.isEnabled = true
        }
    }
    
        // Handler for the open file button tap
    @objc internal func openFileButtonTapped() {
        print("[ACTION LOG] openFileButtonTapped called!")
        openFilePicker()
    }
    
    // Open the file picker dialog
    internal func openFilePicker() {
        // Ensure file metadata view is set up, which initializes the fileInfoButton
        if fileMetadataView == nil || fileInfoButton == nil {
            setupFileMetadataView()
        }
        
        // Support specific file types and also general content types
        let jsonUTType = UTType(filenameExtension: "json") ?? UTType.json
        
        // YAML file types
        var yamlUTType = UTType(filenameExtension: "yaml")
        let ymlUTType = UTType(filenameExtension: "yml")
        
        // TOML file type
        var tomlUTType = UTType(filenameExtension: "toml")
        
        // INI file type
        var iniUTType = UTType(filenameExtension: "ini")
        
        // If yamlUTType is nil, create a dynamic UTType
        if yamlUTType == nil {
            yamlUTType = UTType(exportedAs: "public.yaml")
        }
        
        // If tomlUTType is nil, create a dynamic UTType
        if tomlUTType == nil {
            tomlUTType = UTType(exportedAs: "public.toml")
        }
        
        // If iniUTType is nil, create a dynamic UTType
        if iniUTType == nil {
            iniUTType = UTType(exportedAs: "public.ini")
        }
        
        // Create array of content types to support
        var contentTypes = [jsonUTType, UTType.data, UTType.content]
        
        // Add YAML types if available
        if let yamlType = yamlUTType {
            contentTypes.append(yamlType)
        }
        if let ymlType = ymlUTType {
            contentTypes.append(ymlType)
        }
        
        // Add TOML type if available
        if let tomlType = tomlUTType {
            contentTypes.append(tomlType)
        }
        
        // Add INI type if available
        if let iniType = iniUTType {
            contentTypes.append(iniType)
        }
        
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: contentTypes,
            asCopy: true
        )
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    // Open a recent file at the specified index
    internal func openRecentFile(at index: Int) {
        let recentFiles = RecentFilesManager.shared.files
        guard index >= 0 && index < recentFiles.count else { return }
        
        // Cancel any pending CSV setup if switching files
        self.pendingCSVSetupWorkItem?.cancel()
        self.pendingCSVSetupWorkItem = nil
        
        // When opening a recent file, ensure we clean up any existing CSV state
        if self.isCSVFile {
            print("[DEBUG] Cleaning up CSV state before opening recent file")
            self.isCSVFile = false
        }
        
        let recentFile = recentFiles[index]
        
        // Check if the file still exists
        if FileManager.default.fileExists(atPath: recentFile.path) {
            // Try to access the file
            var isAccessible = true
            if recentFile.url.startAccessingSecurityScopedResource() {
                // Stop accessing when done
                recentFile.url.stopAccessingSecurityScopedResource()
            } else {
                // If we can't access, we'll still try to open but note that it might fail
                isAccessible = false
            }
            
            handleFileUrl(recentFile.url)
        } else {
            // File no longer exists, show an error and remove from recent files
            let alert = UIAlertController(
                title: "File Not Found",
                message: "The file \(recentFile.name) no longer exists or is not accessible from this app.",
                preferredStyle: .alert
            )
            
            // Option to remove from recents
            alert.addAction(UIAlertAction(title: "Remove from Recent Files", style: .destructive) { _ in
                RecentFilesManager.shared.removeFile(at: index)
                self.updateRecentFilesMenu()
            })
            
            // Cancel option
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
    }
    
    // Method called by SceneDelegate or DocumentPicker
    internal func handleFileUrl(_ url: URL) {
        print("📂 handleFileUrl called for: \(url.lastPathComponent)")
        
        // Clean up any existing CSV state before loading a new file
        if self.isCSVFile {
            print("[DEBUG] Cleaning up CSV state before handling new file")
            self.isCSVFile = false
        }
        
        // Hide file metadata view when loading a new file if it exists
        if fileMetadataView != nil {
            fileMetadataView.isHidden = true
        }
        
        // Update file info button if it exists
        if fileInfoButton != nil {
            // For iOS 13 and above, we can use SF Symbols
            if #available(iOS 13.0, *) {
                let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
                let icon = UIImage(systemName: "info.circle", withConfiguration: config)
                
                // For our custom view
                if let infoView = fileInfoButton as? InfoButtonView {
                    infoView.updateIcon(icon)
                }
                // For standard UIButton fallback
                else if let button = fileInfoButton as? UIButton {
                    button.setImage(icon, for: .normal)
                }
            } else {
                // Handle pre-iOS 13 case
                if let button = fileInfoButton as? UIButton {
                    button.setTitle("File Info", for: .normal)
                }
            }
        }
        
        fileMetadataVisible = false
        
        // Start accessing the security-scoped resource.
        // Important: SceneDelegate already calls startAccessing, but UIDocumentPicker does not automatically.
        // Calling it again here is safe and ensures access regardless of the entry point.
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url)
            print("📄 File loaded successfully: \(data.count) bytes")
            
            // Store the current file URL for save operations
            self.currentFileUrl = url
            
            // Determine if the file is JSON, YAML, TOML, INI, or CSV based on content and extension
            var isJSON = false
            var isYAML = false
            var isTOML = false
            var isINI = false
            var isCSV = false
            
            let fileExtension = url.pathExtension.lowercased()
            
            if fileExtension == "json" {
                isJSON = true
            } else if fileExtension == "yaml" || fileExtension == "yml" {
                isYAML = true
            } else if fileExtension == "toml" {
                isTOML = true
            } else if fileExtension == "ini" {
                isINI = true
            } else if fileExtension == "csv" {
                isCSV = true
            } else if data.count > 0, let fileContent = String(data: data, encoding: .utf8) {
                // If extension doesn't clearly indicate the type, check content
                
                // Check for JSON indicators (starts with { or [)
                if let firstChar = String(data: data.prefix(1), encoding: .utf8), (firstChar == "{" || firstChar == "[") {
                    // Further validate by attempting to parse as JSON
                    do {
                        _ = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                        isJSON = true
                    } catch {
                        // Not valid JSON despite starting with { or [
                        isJSON = false
                    }
                }
                
                // If not JSON, check if it might be YAML, TOML or INI
                if !isJSON {
                    // Use our custom YAML detection
                    isYAML = YAMLParser.isYAML(content: fileContent)
                    
                    // If not YAML, check if it might be TOML
                    if !isYAML {
                        // Use our custom TOML detection
                        isTOML = TOMLParser.isTOML(content: fileContent)
                        
                        // If not TOML, check if it might be INI
                        if !isTOML {
                            // Use our custom INI detection
                            isINI = INIParser.isINI(content: fileContent)
                        }
                    }
                }
            }
            
            // Now display the content after determining file type
            displayFileContent(url: url, data: data, isYAML: isYAML, isTOML: isTOML, isINI: isINI)
            
            // Add to recent files - treat YAML, TOML, INI, and CSV as JSON for compatibility
            RecentFilesManager.shared.addFile(url: url, isJSON: isJSON || isYAML || isTOML || isINI || isCSV)
            
            // Update open button menu with new recent files list
            updateRecentFilesMenu()
            
            // Enable file info button if it exists
            if fileInfoButton != nil {
                enableInfoButton()
            }
            
            // Before scheduling the async block, ensure the default mode is text view
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                print("[DEBUG] AsyncAfter block executing - isCSVFile: \(self.isCSVFile)")
                // Make sure JSON-specific UI elements visible
                self.jsonActionsStackView.isHidden = false
                self.jsonActionsToolbar.isHidden = false
                self.navigationContainerView.isHidden = false
                self.actionsBar.isHidden = false
                print("[DEBUG] Actions bar hidden after async: \(self.actionsBar.isHidden)")
                print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from FileOperations.swift (asyncAfter .1s), isLoaded: true")
                self.updateUIVisibilityForJsonLoaded(true)
                // Only restore the text view if the tree view is not visible
                if !self.isTreeViewVisible {
                    print("[DEBUG] (Refactor) Ensuring text view is visible after UI update (asyncAfter .1s)")
                    self.switchToTextView(animated: false)
                } else {
                    print("[DEBUG] (Refactor) Tree view is visible, not switching views in async block.")
                }
                self.fixTreeViewForStandardTextView()
            }
            
            // Show success toast
            showEnhancedToast(message: "File loaded successfully", type: ToastType.success)
        } catch {
            showEnhancedToast(message: "Error reading file: \(error.localizedDescription)", type: ToastType.error)
        }
    }

    // Display file content
    internal func displayFileContent(url: URL, data: Data, isYAML: Bool = false, isTOML: Bool = false, isINI: Bool = false, isCSV: Bool = false) {
        print("📝 Displaying file content for: \(url.lastPathComponent)")
        let filename = url.lastPathComponent
        let baseFont = fileContentView.font ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
        var displayText: String? = nil
        var textColor = UIColor.label
        
        // Reset format flags - will be set to true if needed
        self.isYAMLFile = false
        self.isTOMLFile = false
        self.isINIFile = false
        
        // Check file extension to determine if we're switching to CSV
        let fileExtension = url.pathExtension.lowercased()
        let isCsvExtension = fileExtension == "csv"
        
        // Check if we need to reset CSV state at the very beginning
        let wasCSVFile = self.isCSVFile
        
        // If we're switching away from a CSV file, reset the flag immediately
        if wasCSVFile && !isCSV && !isCsvExtension {
            // Cancel any pending CSV setup operations
            self.pendingCSVSetupWorkItem?.cancel()
            self.pendingCSVSetupWorkItem = nil
            
            // Reset the flag FIRST to prevent interference with JSON UI updates
            self.isCSVFile = false
            
            // We're switching from CSV to another format
            print("[DEBUG] Switching from CSV to another format - resetting isCSVFile flag")
            print("[DEBUG] Toolbar will be configured when processing the new file type")
        }
        
        // Restore normal tree button visibility for non-CSV files
        if let treeButton = treeModeButton {
            // If it's a CSV file, hide the tree button (checked later)
            // For non-CSV files, show the tree button now
            treeButton.isHidden = false
            
            // Make sure it's enabled
            treeButton.isEnabled = true
            
            // Reset appearance if needed
            if treeButton.backgroundColor != .clear {
                treeButton.backgroundColor = .clear
                treeButton.tintColor = DesignSystem.Colors.text
            }
        }
        
        // Try decoding as UTF-8 text
        if let text = String(data: data, encoding: .utf8) {
            // Check file type based on extension or content
            let fileExtension = url.pathExtension.lowercased()
            let isJsonExtension = fileExtension == "json"
            let isYamlExtension = fileExtension == "yaml" || fileExtension == "yml"
            let isTomlExtension = fileExtension == "toml"
            let isIniExtension = fileExtension == "ini"
            let isCsvExtension = fileExtension == "csv"
            let content = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let startsWithBrace = content.hasPrefix("{") && content.hasSuffix("}")
            let startsWithBracket = content.hasPrefix("[") && content.hasSuffix("]")
            
            // Process CSV files
            if isCSV || isCsvExtension {
                print("[DEBUG] Processing as CSV file - Extension: \(isCsvExtension), isCSV flag: \(isCSV)")
                
                // Set flag indicating this is a CSV file and setup CSV mode
                self.isCSVFile = true
                
                // Just hide the tree button and let setupCSVViewControls handle the Table View button
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    print("[DEBUG] Initial processing for CSV file - hiding tree button")
                    
                    // Hide the tree button if it exists
                    if let treeButton = self.treeModeButton {
                        treeButton.isHidden = true
                    }
                    
                    // We'll let setupCSVViewControls handle the actual table view button creation
                    // This ensures consistent placement of the button in the toolbar
                }
                
                
                
                // Make sure tree mode button has been set up
                if treeModeButton == nil {
                    // Try to find it through view hierarchy inspection
                    for subview in view.subviews {
                        if let toolbar = subview as? UIView, toolbar == actionsBar {
                            for item in toolbar.subviews {
                                if let btn = item as? UIButton, btn.tag == 1 {
                                    treeModeButton = btn
                                    break
                                }
                            }
                        }
                    }
                }
                
                // Try to parse CSV
                let csvDocument = CSVParser.parse(csvString: text, filePath: url)
                self.currentCSVDocument = csvDocument
                
                // Set the title
                self.title = "CSV: \(filename)"
                
                // Display the CSV with syntax highlighting in text view
                if let boundedTextView = self.fileContentView as? BoundedTextView {
                    print("[DEBUG] displayFileContent: Updating existing BoundedTextView with CSV.")
                    
                    // Use CSV highlighter
                    let csvHighlighter = CSVHighlighter()
                    let attributedString = csvHighlighter.highlightCSV(text, font: boundedTextView.font)
                    
                    // Make sure content stack view is visible and properly set up
                    self.contentStackView.isHidden = false
                    self.contentStackView.alpha = 1.0
                    
                    // Update the text view
                    boundedTextView.attributedText = attributedString
                    boundedTextView.isEditable = false
                    boundedTextView.isSelectable = true
                    boundedTextView.isUserInteractionEnabled = true
                    boundedTextView.applyCustomCodeStyle()
                    boundedTextView.invalidateIntrinsicContentSize()
                    
                    boundedTextView.isHidden = false
                    boundedTextView.alpha = 1.0
                    
                    if !self.contentStackView.arrangedSubviews.contains(boundedTextView) {
                        print("[WARNING] displayFileContent: BoundedTextView was not in contentStackView, re-inserting.")
                        self.contentStackView.insertArrangedSubview(boundedTextView, at: 0)
                    }
                    
                    // Make sure we can see the text content
                    boundedTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
                    
                    // Force the layout to update with constraints properly applied
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                } else {
                    print("[DEBUG] displayFileContent: Fallback - Updating standard UITextView with CSV.")
                    let csvHighlighter = CSVHighlighter()
                    let attributedString = csvHighlighter.highlightCSV(text, font: self.fileContentView.font)
                    
                    // Make sure content stack view is visible and properly set up
                    self.contentStackView.isHidden = false
                    self.contentStackView.alpha = 1.0
                    
                    // Update the text view
                    self.fileContentView.attributedText = attributedString
                    self.fileContentView.isEditable = false
                    self.fileContentView.isSelectable = true
                    self.fileContentView.isHidden = false
                    self.fileContentView.alpha = 1.0
                    
                    // Make sure we can see the text content
                    self.fileContentView.scrollRangeToVisible(NSRange(location: 0, length: 0))
                    
                    // Force the layout to update with constraints properly applied
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }
                
                // Set up CSV-specific controls with multiple staged fixes
                print("[DEBUG] Scheduling mega CSV toolbar fix sequence")
                
                // First hide the tree button immediately
                if let treeButton = self.treeModeButton {
                    treeButton.isHidden = true
                }
                
                // First ensure key buttons are visible immediately
                self.validateButton.isHidden = false
                self.validateButton.isEnabled = true
                self.searchToggleButton.isHidden = false
                self.searchToggleButton.isEnabled = true
                self.editToggleButton.isHidden = false
                self.editToggleButton.isEnabled = true
                
                // Cancel any previous pending CSV setup
                self.pendingCSVSetupWorkItem?.cancel()
                
                // Setup CSV controls with the new dedicated toolbar manager
                let csvSetupWorkItem = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    // Only proceed if we're still showing a CSV file
                    guard self.isCSVFile else {
                        print("[DEBUG] CSV setup cancelled - no longer showing CSV file")
                        return
                    }
                    print("[DEBUG] Now calling setupCSVViewControls from main location with dedicated toolbar")
                    self.setupCSVViewControls()
                }
                self.pendingCSVSetupWorkItem = csvSetupWorkItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: csvSetupWorkItem)
                
                return // Exit early as we've handled the CSV display
            }
            
            // YAML and TOML processing will happen later in the code
            
            // Process INI files
            if isINI || isIniExtension {
                print("[DEBUG] Processing as INI file")
                self.isINIFile = true
                
                // Configure toolbar for INI
                self.modularToolbarManager?.configureForFileType(.ini)
                do {
                    // Try to convert INI to JSON
                    let jsonString = try INIParser.convertToPrettyJSON(text)
                    displayText = jsonString
                    
                    // Parse the converted JSON
                    if let jsonData = jsonString.data(using: .utf8) {
                        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
                        self.currentJsonObject = jsonObject // Store for later use
                        
                        self.title = "INI: \(filename)"
                        
                        // Store a flag indicating this is an INI file
                        self.isINIFile = true
                        
                        // Reset navigation path to root
                        self.currentPath = ["$"]
                        self.jsonPathNavigator.updatePath(self.currentPath)
                        
                        // Display the INI with syntax highlighting
                        if let boundedTextView = self.fileContentView as? BoundedTextView {
                            print("[DEBUG] displayFileContent: Updating existing BoundedTextView with INI.")
                            
                            // Use INI highlighter directly on the original INI
                            let iniHighlighter = INIHighlighter()
                            let attributedString = iniHighlighter.highlightINI(text, font: boundedTextView.font)
                            
                            // Safely update the attributed text and verify it's not nil
                            if attributedString.length > 0 {
                                boundedTextView.attributedText = attributedString
                            } else {
                                // Fallback to plain text if highlighting fails
                                boundedTextView.text = text
                            }
                            
                            // Configure text view
                            boundedTextView.isEditable = false
                            boundedTextView.isSelectable = true
                            boundedTextView.isUserInteractionEnabled = true
                            boundedTextView.applyCustomCodeStyle()
                            boundedTextView.invalidateIntrinsicContentSize()
                            
                            boundedTextView.isHidden = false
                            boundedTextView.alpha = 1.0
                            if !self.contentStackView.arrangedSubviews.contains(boundedTextView) {
                                print("[WARNING] displayFileContent: BoundedTextView was not in contentStackView, re-inserting.")
                                self.contentStackView.insertArrangedSubview(boundedTextView, at: 0)
                            }
                        } else {
                            print("[DEBUG] displayFileContent: Fallback - Updating standard UITextView with INI.")
                            let iniHighlighter = INIHighlighter()
                            let attributedString = iniHighlighter.highlightINI(text, font: self.fileContentView.font)
                            
                            // Safely update the attributed text
                            if attributedString.length > 0 {
                                self.fileContentView.attributedText = attributedString
                            } else {
                                // Fallback to plain text if highlighting fails
                                self.fileContentView.text = text
                            }
                            self.fileContentView.isEditable = false
                            self.fileContentView.isSelectable = true
                            self.fileContentView.isHidden = false
                            self.fileContentView.alpha = 1.0
                        }
                        
                        // Update UI for the parsed file
                        self.view.layoutIfNeeded()
                        self.fileContentView.scrollRangeToVisible(NSRange(location: 0, length: 0))
                        
                        // Make all UI elements visible
                        self.jsonActionsStackView.isHidden = false
                        self.jsonActionsToolbar.isHidden = false
                        self.navigationContainerView.isHidden = false
                        self.actionsBar.isHidden = false
                        
                        if let rawButton = self.rawViewToggleButton {
                            rawButton.setTitle("Raw", for: .normal)
                            rawButton.isHidden = false
                        }
                        
                        if let editButton = self.editToggleButton {
                            editButton.setTitle("Edit", for: .normal)
                            editButton.isEnabled = true
                            editButton.isHidden = false
                        }
                        
                        if let saveButton = self.saveButton {
                            saveButton.isHidden = true
                        }
                        
                        if let cancelButton = self.cancelButton {
                            cancelButton.isHidden = true
                        }
                        
                        self.isMinimapVisible = true
                        print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from FileOperations.swift (INI handling), isLoaded: true")
                        self.updateUIVisibilityForJsonLoaded(true)
                        return // Exit early as we've handled the INI display
                    }
                } catch {
                    // Could not parse or convert INI
                    print("Error processing INI: \(error)")
                    displayText = text
                    textColor = .label
                    DispatchQueue.main.async { [weak self] in
                         guard let self = self else { return }
                        self.title = "INI (Error): \(filename)"
                         self.fileContentView.text = displayText
                         self.fileContentView.textColor = textColor
                         self.fileContentView.isEditable = false
                         self.fileContentView.isHidden = false
                         self.fileContentView.alpha = 1.0
                         self.currentJsonObject = nil
                         print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from FileOperations.swift (INI error), isLoaded: false")
                         self.updateUIVisibilityForJsonLoaded(false)
                    }
                }
            }
            // Process TOML files
            else if isTOML || isTomlExtension {
                print("[DEBUG] Processing as TOML file")
                self.isTOMLFile = true
                
                // Configure toolbar for TOML
                self.modularToolbarManager?.configureForFileType(.toml)
                do {
                    // Try to convert TOML to JSON
                    let jsonString = try TOMLParser.convertToPrettyJSON(text)
                    displayText = jsonString
                    
                    // Parse the converted JSON
                    if let jsonData = jsonString.data(using: .utf8) {
                        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
                        self.currentJsonObject = jsonObject // Store for later use
                        
                        self.title = "TOML: \(filename)"
                        
                        // Store a flag indicating this is a TOML file
                        self.isTOMLFile = true
                        
                        // Reset navigation path to root
                        self.currentPath = ["$"]
                        self.jsonPathNavigator.updatePath(self.currentPath)
                        
                        // Display the TOML with syntax highlighting
                        if let boundedTextView = self.fileContentView as? BoundedTextView {
                            print("[DEBUG] displayFileContent: Updating existing BoundedTextView with TOML.")
                            
                            // Use TOML highlighter directly on the original TOML
                            let tomlHighlighter = TOMLHighlighter()
                            let attributedString = tomlHighlighter.highlightTOML(text, font: boundedTextView.font)
                            
                            // Safely update the attributed text and verify it's not nil
                            if attributedString.length > 0 {
                                boundedTextView.attributedText = attributedString
                            } else {
                                // Fallback to plain text if highlighting fails
                                boundedTextView.text = text
                            }
                            
                            // Configure text view
                            boundedTextView.isEditable = false
                            boundedTextView.isSelectable = true
                            boundedTextView.isUserInteractionEnabled = true
                            boundedTextView.applyCustomCodeStyle()
                            boundedTextView.invalidateIntrinsicContentSize()
                            
                            boundedTextView.isHidden = false
                            boundedTextView.alpha = 1.0
                            if !self.contentStackView.arrangedSubviews.contains(boundedTextView) {
                                print("[WARNING] displayFileContent: BoundedTextView was not in contentStackView, re-inserting.")
                                self.contentStackView.insertArrangedSubview(boundedTextView, at: 0)
                            }
                        } else {
                            print("[DEBUG] displayFileContent: Fallback - Updating standard UITextView with TOML.")
                            let tomlHighlighter = TOMLHighlighter()
                            let attributedString = tomlHighlighter.highlightTOML(text, font: self.fileContentView.font)
                            
                            // Safely update the attributed text
                            if attributedString.length > 0 {
                                self.fileContentView.attributedText = attributedString
                            } else {
                                // Fallback to plain text if highlighting fails
                                self.fileContentView.text = text
                            }
                            self.fileContentView.isEditable = false
                            self.fileContentView.isSelectable = true
                            self.fileContentView.isHidden = false
                            self.fileContentView.alpha = 1.0
                        }
                        
                        // Update UI for the parsed file
                        self.view.layoutIfNeeded()
                        self.fileContentView.scrollRangeToVisible(NSRange(location: 0, length: 0))
                        
                        // Make all UI elements visible
                        self.jsonActionsStackView.isHidden = false
                        self.jsonActionsToolbar.isHidden = false
                        self.navigationContainerView.isHidden = false
                        self.actionsBar.isHidden = false
                        
                        if let rawButton = self.rawViewToggleButton {
                            rawButton.setTitle("Raw", for: .normal)
                            rawButton.isHidden = false
                        }
                        
                        if let editButton = self.editToggleButton {
                            editButton.setTitle("Edit", for: .normal)
                            editButton.isEnabled = true
                            editButton.isHidden = false
                        }
                        
                        if let saveButton = self.saveButton {
                            saveButton.isHidden = true
                        }
                        
                        if let cancelButton = self.cancelButton {
                            cancelButton.isHidden = true
                        }
                        
                        self.isMinimapVisible = true
                        print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from FileOperations.swift (TOML handling), isLoaded: true")
                        self.updateUIVisibilityForJsonLoaded(true)
                        return // Exit early as we've handled the TOML display
                    }
                } catch {
                    // Could not parse or convert TOML
                    print("Error processing TOML: \(error)")
                    displayText = text
                    textColor = .label
                    DispatchQueue.main.async { [weak self] in
                         guard let self = self else { return }
                        self.title = "TOML (Error): \(filename)"
                         self.fileContentView.text = displayText
                         self.fileContentView.textColor = textColor
                         self.fileContentView.isEditable = false
                         self.fileContentView.isHidden = false
                         self.fileContentView.alpha = 1.0
                         self.currentJsonObject = nil
                         print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from FileOperations.swift (TOML error), isLoaded: false")
                         self.updateUIVisibilityForJsonLoaded(false)
                    }
                }
            } 
            // Process YAML files
            else if isYAML || isYamlExtension {
                print("[DEBUG] Processing as YAML file")
                self.isYAMLFile = true
                
                // Configure toolbar for YAML
                self.modularToolbarManager?.configureForFileType(.yaml)
                do {
                    // Try to convert YAML to JSON
                    let jsonString = try YAMLParser.convertToPrettyJSON(text)
                    displayText = jsonString
                    
                    // Parse the converted JSON
                    if let jsonData = jsonString.data(using: .utf8) {
                        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
                        self.currentJsonObject = jsonObject // Store for later use
                        
                        self.title = "YAML: \(filename)"
                        
                        // Store a flag indicating this is a YAML file
                        self.isYAMLFile = true
                        
                        // Reset navigation path to root
                        self.currentPath = ["$"]
                        self.jsonPathNavigator.updatePath(self.currentPath)
                        
                        // Display the converted YAML as JSON
                        if let boundedTextView = self.fileContentView as? BoundedTextView {
                            print("[DEBUG] displayFileContent: Updating existing BoundedTextView with YAML->JSON.")
                            
                            // Use YAML highlighter directly on the original YAML
                            let yamlHighlighter = YAMLHighlighter()
                            let attributedString = yamlHighlighter.highlightYAML(text, font: boundedTextView.font)
                            boundedTextView.attributedText = attributedString
                            
                            // Configure text view
                            boundedTextView.isEditable = false
                            boundedTextView.isSelectable = true
                            boundedTextView.isUserInteractionEnabled = true
                            boundedTextView.applyCustomCodeStyle()
                            boundedTextView.invalidateIntrinsicContentSize()
                            
                            boundedTextView.isHidden = false
                            boundedTextView.alpha = 1.0
                            if !self.contentStackView.arrangedSubviews.contains(boundedTextView) {
                                print("[WARNING] displayFileContent: BoundedTextView was not in contentStackView, re-inserting.")
                                self.contentStackView.insertArrangedSubview(boundedTextView, at: 0)
                            }
                        } else {
                            print("[DEBUG] displayFileContent: Fallback - Updating standard UITextView with YAML.")
                            let yamlHighlighter = YAMLHighlighter()
                            let attributedString = yamlHighlighter.highlightYAML(text, font: self.fileContentView.font)
                            self.fileContentView.attributedText = attributedString
                            self.fileContentView.isEditable = false
                            self.fileContentView.isSelectable = true
                            self.fileContentView.isHidden = false
                            self.fileContentView.alpha = 1.0
                        }
                        
                        // Update UI for the parsed file
                        self.view.layoutIfNeeded()
                        self.fileContentView.scrollRangeToVisible(NSRange(location: 0, length: 0))
                        
                        // Make all UI elements visible
                        self.jsonActionsStackView.isHidden = false
                        self.jsonActionsToolbar.isHidden = false
                        self.navigationContainerView.isHidden = false
                        self.actionsBar.isHidden = false
                        
                        if let rawButton = self.rawViewToggleButton {
                            rawButton.setTitle("Raw", for: .normal)
                            rawButton.isHidden = false
                        }
                        
                        if let editButton = self.editToggleButton {
                            editButton.setTitle("Edit", for: .normal)
                            editButton.isEnabled = true
                            editButton.isHidden = false
                        }
                        
                        if let saveButton = self.saveButton {
                            saveButton.isHidden = true
                        }
                        
                        if let cancelButton = self.cancelButton {
                            cancelButton.isHidden = true
                        }
                        
                        self.isMinimapVisible = true
                        print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from FileOperations.swift (YAML handling), isLoaded: true")
                        self.updateUIVisibilityForJsonLoaded(true)
                        return // Exit early as we've handled the YAML display
                    }
                } catch {
                    // Could not parse or convert YAML
                    print("Error processing YAML: \(error)")
                    displayText = text
                    textColor = .label
                    DispatchQueue.main.async { [weak self] in
                         guard let self = self else { return }
                        self.title = "YAML (Error): \(filename)"
                         self.fileContentView.text = displayText
                         self.fileContentView.textColor = textColor
                         self.fileContentView.isEditable = false
                         self.fileContentView.isHidden = false
                         self.fileContentView.alpha = 1.0
                         self.currentJsonObject = nil
                         print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from FileOperations.swift (YAML error), isLoaded: false")
                         self.updateUIVisibilityForJsonLoaded(false)
                    }
                }
            } else if isJsonExtension || startsWithBrace || startsWithBracket {
                print("[DEBUG] Processing as JSON file")
                
                // Configure toolbar for JSON
                self.modularToolbarManager?.configureForFileType(.json)
                do {
                    // Validate and pretty-print JSON
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    self.currentJsonObject = jsonObject // Store for later use
                    
                    let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
                    if let prettyText = String(data: prettyData, encoding: .utf8) {
                        displayText = prettyText
                        self.title = "JSON: \(filename)"
                        
                        // Reset navigation path to root
                        self.currentPath = ["$"]
                        self.jsonPathNavigator.updatePath(self.currentPath)
                        
                        // Display the JSON using the specialized method if possible
                        if let boundedTextView = self.fileContentView as? BoundedTextView {
                            print("[DEBUG] displayFileContent: Updating existing BoundedTextView.")
                            
                            // Instead of creating a new view, update the existing one
                            let attributedString = self.jsonHighlighter.highlightJSON(prettyText, font: boundedTextView.font)
                            boundedTextView.attributedText = attributedString
                            
                            // Ensure it's correctly configured for display
                            boundedTextView.isEditable = false
                            boundedTextView.isSelectable = true
                            boundedTextView.isUserInteractionEnabled = true
                            boundedTextView.applyCustomCodeStyle() // Re-apply style if needed
                            boundedTextView.invalidateIntrinsicContentSize() // Tell layout system size changed
                            
                            // Ensure it's visible and properly positioned within the stack view
                            boundedTextView.isHidden = false
                            boundedTextView.alpha = 1.0
                            if !self.contentStackView.arrangedSubviews.contains(boundedTextView) {
                                // If somehow it got removed from arrangedSubviews, add it back
                                // (This shouldn't happen if we don't remove it here)
                                print("[WARNING] displayFileContent: BoundedTextView was not in contentStackView, re-inserting.")
                                self.contentStackView.insertArrangedSubview(boundedTextView, at: 0) // Or appropriate index
                            }
                            print("[DEBUG] displayFileContent: Updated existing BoundedTextView with text length: \(boundedTextView.text.count)")
                        } else {
                            // Fallback: If it's not a BoundedTextView (shouldn't happen after viewDidLoad),
                            // just set the attributed text on the standard UITextView.
                            print("[DEBUG] displayFileContent: Fallback - Updating standard UITextView.")
                            let attributedString = self.jsonHighlighter.highlightJSON(prettyText, font: self.fileContentView.font)
                            self.fileContentView.attributedText = attributedString
                            self.fileContentView.isEditable = false
                            self.fileContentView.isSelectable = true
                            self.fileContentView.isHidden = false
                            self.fileContentView.alpha = 1.0
                        }
                        
                        // Force layout update after setting content
                        self.view.layoutIfNeeded()
                        print("[DEBUG] displayFileContent: Frame after layoutIfNeeded: \(self.fileContentView.frame)") // Log Frame
                        
                        // Scroll to top
                        self.fileContentView.scrollRangeToVisible(NSRange(location: 0, length: 0))

                        // Make all UI elements visible and update buttons
                        self.jsonActionsStackView.isHidden = false // Deprecated?
                        self.jsonActionsToolbar.isHidden = false // Deprecated?
                        self.navigationContainerView.isHidden = false
                        self.actionsBar.isHidden = false // Use the modern actions bar
                        
                        if let rawButton = self.rawViewToggleButton {
                            rawButton.setTitle("Raw", for: .normal)
                            rawButton.isHidden = false
                        }
                        
                        if let editButton = self.editToggleButton {
                            editButton.setTitle("Edit", for: .normal)
                            editButton.isEnabled = true
                            editButton.isHidden = false
                        }
                        
                        if let saveButton = self.saveButton {
                            saveButton.isHidden = true
                        }
                        
                        if let cancelButton = self.cancelButton {
                            cancelButton.isHidden = true
                        }
                        
                        // Update overall UI visibility state
                        self.isMinimapVisible = true
                        print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from FileOperations.swift (after updating text view), isLoaded: true")
                        self.updateUIVisibilityForJsonLoaded(true)
                        return // Exit early as we've handled the JSON display
                    }
                } catch {
                    // Could not pretty print JSON, display raw text
                    displayText = text
                    textColor = .label
                    DispatchQueue.main.async { [weak self] in
                         guard let self = self else { return }
                        self.title = "Text: \(filename)"
                         self.fileContentView.text = displayText
                         self.fileContentView.textColor = textColor
                         self.fileContentView.isEditable = false
                         self.fileContentView.isHidden = false
                         self.fileContentView.alpha = 1.0
                         self.currentJsonObject = nil // Mark as not JSON
                         print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from FileOperations.swift (non-JSON), isLoaded: false")
                         self.updateUIVisibilityForJsonLoaded(false) // Hide JSON specific UI
                    }
                }
            } else {
                // Not JSON, display as plain text
                print("Displaying as plain text file")
                displayText = text
                textColor = .label
                DispatchQueue.main.async { [weak self] in
                     guard let self = self else { return }
                    self.title = "Text: \(filename)"
                     self.fileContentView.text = displayText
                     self.fileContentView.textColor = textColor
                     self.fileContentView.isEditable = false
                     self.fileContentView.isHidden = false
                     self.fileContentView.alpha = 1.0
                     self.currentJsonObject = nil // Mark as not JSON
                     print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from FileOperations.swift (plain text), isLoaded: false")
                     self.updateUIVisibilityForJsonLoaded(false) // Hide JSON specific UI
                }
            }
        } else {
            // Could not decode as UTF-8 text
            displayText = "Error: Could not decode file content."
            textColor = .red
            DispatchQueue.main.async { [weak self] in
                 guard let self = self else { return }
                self.title = "Error: \(filename)"
                 self.fileContentView.text = displayText
                 self.fileContentView.textColor = textColor
                 self.fileContentView.isEditable = false
                 self.fileContentView.isHidden = false
                 self.fileContentView.alpha = 1.0
                 self.currentJsonObject = nil // Mark as not JSON
                 print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from FileOperations.swift (decode error), isLoaded: false")
                 self.updateUIVisibilityForJsonLoaded(false) // Hide JSON specific UI
            }
        }
        
        // Ensure main UI update happens after potential content update
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Final check on UI visibility based on whether JSON loaded successfully
            self.updateUIVisibilityForJsonLoaded(self.currentJsonObject != nil)
            self.view.layoutIfNeeded() // Ensure layout updates after visibility changes
        }
    }
    
    // Update the recent files menu based on the current recent files list
    internal func updateRecentFilesMenu() {
        // Create the open action
        let openAction = UIAction(title: "Browse Files...", image: UIImage(systemName: "folder")) { [weak self] _ in
            self?.openFilePicker()
        }
        
        // Get recent files from manager
        let recentFiles = RecentFilesManager.shared.files
        
        if recentFiles.isEmpty {
            // If no recent files, just show the open option
            openButton.menu = UIMenu(title: "", children: [openAction])
        } else {
            // Create actions for each recent file
            var recentFileActions: [UIMenuElement] = []
            
            // Add a section header for recent files
            let recentFilesSection = UIMenu(title: "Recent Files", options: .displayInline, children: 
                recentFiles.enumerated().map { index, recentFile in
                    // Get appropriate icon for the file type
                    let iconName = FileTypeIconHelper.getSystemIconName(for: recentFile.url)
                    
                    // Create a date formatter for showing when the file was last opened
                    let dateFormatter = DateFormatter()
                    dateFormatter.doesRelativeDateFormatting = true
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .short
                    
                    // Format the subtitle with relative date
                    let subtitle = "Last opened: \(dateFormatter.string(from: recentFile.timestamp))"
                    
                    // Create the action with the file and its metadata
                    return UIAction(title: recentFile.name,
                                  subtitle: subtitle,
                                  image: UIImage(systemName: iconName)) { [weak self] _ in
                        self?.openRecentFile(at: index)
                    }
                }
            )
            
            // Add a clear option
            let clearAction = UIAction(title: "Clear Recent Files", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                RecentFilesManager.shared.clearAllFiles()
                self?.updateRecentFilesMenu()
            }
            
            // Build the full menu
            recentFileActions = [recentFilesSection, openAction, clearAction]
            openButton.menu = UIMenu(title: "", children: recentFileActions)
        }
    }
    
    // Load sample JSON file
    @objc internal func loadSampleButtonTapped() {
        print("[ACTION LOG] loadSampleButtonTapped called!")
        
        // Show a menu with sample file options
        let actionSheet = UIAlertController(title: "Choose a Sample File", message: nil, preferredStyle: .actionSheet)
        
        // Add JSON file option
        actionSheet.addAction(UIAlertAction(title: "Sample JSON", style: .default) { [weak self] _ in
            self?.loadSampleFile(name: "sample", extension: "json")
        })
        
        // Add YAML config file option
        actionSheet.addAction(UIAlertAction(title: "Sample YAML Config", style: .default) { [weak self] _ in
            self?.loadSampleFile(name: "sample-config", extension: "yaml")
        })
        
        // Add YAML person file option
        actionSheet.addAction(UIAlertAction(title: "Sample YAML Person", style: .default) { [weak self] _ in
            self?.loadSampleFile(name: "valid-person", extension: "yaml")
        })
        
        // Add TOML config file option
        actionSheet.addAction(UIAlertAction(title: "Sample TOML Config", style: .default) { [weak self] _ in
            self?.loadSampleFile(name: "sample-config", extension: "toml")
        })
        
        // Add TOML person file option
        actionSheet.addAction(UIAlertAction(title: "Sample TOML Person", style: .default) { [weak self] _ in
            self?.loadSampleFile(name: "sample-person", extension: "toml")
        })
        
        // Add TOML validation test file option
        actionSheet.addAction(UIAlertAction(title: "TOML Validation Test", style: .default) { [weak self] _ in
            self?.loadSampleFile(name: "test-validation", extension: "toml")
        })
        
        // Add INI config file option
        actionSheet.addAction(UIAlertAction(title: "Sample INI Config", style: .default) { [weak self] _ in
            self?.loadSampleFile(name: "sample-config", extension: "ini")
        })
        
        // Add INI person file option
        actionSheet.addAction(UIAlertAction(title: "Sample INI Person", style: .default) { [weak self] _ in
            self?.loadSampleFile(name: "sample-person", extension: "ini")
        })
        
        // Add CSV data file option
        actionSheet.addAction(UIAlertAction(title: "Sample CSV Data", style: .default) { [weak self] _ in
            self?.loadSampleFile(name: "sample-data", extension: "csv")
        })
        
        // Add cancel option
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present the menu
        if let popoverController = actionSheet.popoverPresentationController {
            // For iPad support
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(actionSheet, animated: true)
    }
    
    // Load a specific sample file
    private func loadSampleFile(name: String, extension fileExtension: String) {
        // Cancel any pending CSV setup if switching files
        self.pendingCSVSetupWorkItem?.cancel()
        self.pendingCSVSetupWorkItem = nil
        // Don't set up file metadata view here - let the natural flow handle it
        // Hide file metadata view when loading a new file if it exists
        if fileMetadataView != nil {
            fileMetadataView.isHidden = true
            
            // Update file info button if it exists
            if fileInfoButton != nil {
                if #available(iOS 13.0, *) {
                    let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
                    let icon = UIImage(systemName: "info.circle", withConfiguration: config)
                    
                    // For our custom view
                    if let infoView = fileInfoButton as? InfoButtonView {
                        infoView.updateIcon(icon)
                    }
                    // For standard UIButton fallback
                    else if let button = fileInfoButton as? UIButton {
                        button.setImage(icon, for: .normal)
                    }
                } else {
                    // Handle pre-iOS 13 case
                    if let button = fileInfoButton as? UIButton {
                        button.setTitle("i", for: .normal)
                    }
                }
            }
            
            fileMetadataVisible = false
        }
        
        // Get the URL to the sample file in the app bundle
        // First try with no subdirectory, then try with subdirectory
        var sampleFileURL = Bundle.main.url(forResource: name, withExtension: fileExtension)
        if sampleFileURL == nil {
            // Try looking in SampleFiles directory
            sampleFileURL = Bundle.main.url(forResource: name, withExtension: fileExtension, subdirectory: "SampleFiles")
        }
        
        if let sampleFileURL = sampleFileURL {
            do {
                // Load the sample file content
                let data = try Data(contentsOf: sampleFileURL)
                
                // Check if it's a YAML, TOML, INI, or CSV file
                let isYAML = fileExtension.lowercased() == "yaml" || fileExtension.lowercased() == "yml"
                let isTOML = fileExtension.lowercased() == "toml"
                let isINI = fileExtension.lowercased() == "ini"
                let isCSV = fileExtension.lowercased() == "csv"
                
                if isYAML {
                    // Reset file type flags before loading YAML
                    self.isCSVFile = false
                    self.isYAMLFile = true
                    self.isTOMLFile = false
                    self.isINIFile = false
                    // Display as YAML
                    displayFileContent(url: sampleFileURL, data: data, isYAML: true)
                    return
                } else if isTOML {
                    // Reset file type flags before loading TOML
                    self.isCSVFile = false
                    self.isYAMLFile = false
                    self.isTOMLFile = true
                    self.isINIFile = false
                    // Display as TOML
                    displayFileContent(url: sampleFileURL, data: data, isTOML: true)
                    return
                } else if isINI {
                    // Reset file type flags before loading INI
                    self.isCSVFile = false
                    self.isYAMLFile = false
                    self.isTOMLFile = false
                    self.isINIFile = true
                    // Display as INI
                    displayFileContent(url: sampleFileURL, data: data, isINI: true)
                    return
                } else if isCSV {
                    // Display as CSV
                    // Parse the CSV file and set flags
                    if let csvString = String(data: data, encoding: .utf8) {
                        print("[DEBUG] Loading sample CSV file: \(sampleFileURL.lastPathComponent)")
                        
                        // Reset file type flags before loading CSV
                        self.isCSVFile = true
                        self.isYAMLFile = false
                        self.isTOMLFile = false
                        self.isINIFile = false
                        
                        // Parse the CSV data
                        let csvDocument = CSVParser.parse(csvString: csvString, filePath: sampleFileURL)
                        self.currentCSVDocument = csvDocument
                        
                        // Set the title right away
                        self.title = "CSV: \(sampleFileURL.lastPathComponent)"
                        
                        // Force layout update before displaying content
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                        
                        // Display the content with a small delay to ensure UI is ready
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                            guard let self = self else { return }
                            self.displayFileContent(url: sampleFileURL, data: data, isCSV: true)
                            
                            // Setup CSV controls with multiple staged fixes
                            print("[DEBUG] Scheduling mega CSV toolbar fix sequence for sample")
                            
                            // First hide the tree button immediately
                            if let treeButton = self.treeModeButton {
                                treeButton.isHidden = true
                            }
                            
                            // First ensure key buttons are visible immediately
                            self.validateButton.isHidden = false
                            self.validateButton.isEnabled = true
                            self.searchToggleButton.isHidden = false
                            self.searchToggleButton.isEnabled = true
                            self.editToggleButton.isHidden = false
                            self.editToggleButton.isEnabled = true
                            
                            // Cancel any previous pending CSV setup
                            self.pendingCSVSetupWorkItem?.cancel()
                            
                            // Setup CSV controls with the new dedicated toolbar manager
                            let csvSetupWorkItem = DispatchWorkItem { [weak self] in
                                guard let self = self else { return }
                                // Only proceed if we're still showing a CSV file
                                guard self.isCSVFile else {
                                    print("[DEBUG] CSV setup cancelled - no longer showing CSV file")
                                    return
                                }
                                print("[DEBUG] Now calling setupCSVViewControls from sample location with dedicated toolbar")
                                self.setupCSVViewControls()
                            }
                            self.pendingCSVSetupWorkItem = csvSetupWorkItem
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: csvSetupWorkItem)
                        }
                    }
                    return
                }
                
                // For JSON, continue with the existing flow
                // IMPORTANT: Reset file type flags before loading JSON
                self.isCSVFile = false
                self.isYAMLFile = false
                self.isTOMLFile = false
                self.isINIFile = false
                
                // Parse the JSON to make sure it's valid
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                
                // Note: Sample file URL is read-only (in bundle)
                // We'll set it but inform user they can't save changes to it
                self.currentFileUrl = sampleFileURL
                self.currentJsonObject = jsonObject
                
                // Create the pretty-printed version of the JSON
                let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
                if let prettyText = String(data: prettyData, encoding: .utf8) {
                    // Get a highlighted version of the JSON
                    let baseFont = self.fileContentView.font ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
                    let attributedString = self.jsonHighlighter.highlightJSON(prettyText, font: baseFont)
                    
                    // Update the UI safely on the main thread
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        // Set the app title
                        self.title = "JSON: sample.json"
                        
                        // Configure text container to ensure proper wrapping
                        self.configureTextViewForJSONDisplay()
                        
                        // Direct access to fileContentView
                        self.fileContentView.attributedText = attributedString
                        
                        // Force text view to be properly configured
                        self.fileContentView.isEditable = false
                        self.fileContentView.isSelectable = true
                        self.fileContentView.isUserInteractionEnabled = true
                        
                        // Ensure text view is properly visible with explicit orders
                        self.fileContentView.isHidden = false
                        self.fileContentView.alpha = 1.0
                        self.contentStackView.isHidden = false
                        self.contentStackView.alpha = 1.0
                        
                        // Scroll to top of content
                        self.fileContentView.scrollRangeToVisible(NSRange(location: 0, length: 0))
                        
                        // Reset navigation path to root
                        self.currentPath = ["$"]
                        self.jsonPathNavigator.updatePath(self.currentPath)
                        
                        // Configure toolbar for JSON
                        self.modularToolbarManager?.configureForFileType(.json)
                        
                        // Make JSON-specific UI elements visible
                        self.jsonActionsStackView.isHidden = false
                        self.jsonActionsToolbar.isHidden = false
                        self.navigationContainerView.isHidden = false
                        
                        // Reset edit mode
                        self.isEditMode = false
                        self.isRawViewMode = false
                        
                        // Make sure edit controls are properly setup and added to UI
                        self.setupEditControls()
                        
                        // Show the edit button but with special handling for sample files
                        self.editToggleButton.isHidden = false
                        self.editToggleButton.setTitle("Edit", for: .normal)
                        
                        // Enable the edit button for sample files (was previously disabled)
                        self.editToggleButton.isEnabled = true
                        
                        // Show raw view toggle button with proper title
                        self.rawViewToggleButton.isHidden = false
                        self.rawViewToggleButton.setTitle("Raw", for: .normal)
                        
                        // Hide save/cancel buttons initially (until edit mode is activated)
                        self.saveButton.isHidden = true
                        self.cancelButton.isHidden = true
                        
                        // Make sure JSON-specific UI elements visible
                        self.jsonActionsStackView.isHidden = false
                        self.jsonActionsToolbar.isHidden = false
                        self.navigationContainerView.isHidden = false
                        
                        // Make sure action buttons are all configured, same as Sample file
                        self.actionsBar.isHidden = false
                        
                        // Update UI visibility to make sure all JSON tools are visible
                        print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from FileOperations.swift (after sample load), isLoaded: true")
                        self.updateUIVisibilityForJsonLoaded(true)
                        
                        // Fix any buttons displaying "..." text instead of an icon
                        self.fixEllipsisButtons()
                        
                        // Apply fixes for tree view and minimap when using standard UITextView
                        self.fixTreeViewForStandardTextView()
                        
                        // Don't show the read-only toast immediately on load
                    }
                }
            } catch {
                print("Error loading sample JSON: \(error)")
                self.showEnhancedToast(message: "Error loading sample JSON: \(error.localizedDescription)", type: ToastType.error)
            }
        } else {
            self.showEnhancedToast(message: "Could not find sample.json in the app bundle", type: ToastType.error)
        }
    }

    // Add this method at the end of the extension to fix tree view constraints when using standard UITextView
    @objc internal func fixTreeViewForStandardTextView() {
        print("[DEBUG] fixTreeViewForStandardTextView: Applying constraint fixes for standard UITextView")
        
        // If our text view is not a BoundedTextView, we need special handling for tree view
        if !(self.fileContentView is BoundedTextView) {
            // Store a reference to the fix in the document window controller
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // Fix any broken constraints in our view hierarchy
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        // Cancel any pending CSV setup if switching files
        self.pendingCSVSetupWorkItem?.cancel()
        self.pendingCSVSetupWorkItem = nil
        
        // Ensure that the fileInfoButton is properly initialized before proceeding
        // This will be called asynchronously to let any initialization complete
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Call the centralized handler
            self.handleFileUrl(url)
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Optional: Handle cancellation if needed
        print("Document picker was cancelled.")
    }
}
