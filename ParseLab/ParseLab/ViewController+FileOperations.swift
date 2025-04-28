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
        
        // Support specific JSON files and also general content types
        let jsonUTType = UTType(filenameExtension: "json") ?? UTType.json
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [jsonUTType, UTType.data, UTType.content],
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
            
            // Determine if the file is JSON based on content and extension
            var isJSON = false
            
            if url.pathExtension.lowercased() == "json" {
                isJSON = true
            } else if data.count > 0, let firstChar = String(data: data.prefix(1), encoding: .utf8) {
                // Check if content starts with { or [ (JSON indicators)
                if firstChar == "{" || firstChar == "[" {
                    // Further validate by attempting to parse
                    do {
                        _ = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                        isJSON = true
                    } catch {
                        // Not valid JSON despite starting with { or [
                        isJSON = false
                    }
                }
            }
            
            // Now display the content after determining if it's JSON
            displayFileContent(url: url, data: data)
            
            // Add to recent files
            RecentFilesManager.shared.addFile(url: url, isJSON: isJSON)
            
            // Update open button menu with new recent files list
            updateRecentFilesMenu()
            
            // Enable file info button if it exists
            if fileInfoButton != nil {
                enableInfoButton()
            }
            
            // Before scheduling the async block, ensure the default mode is text view
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                // Make sure JSON-specific UI elements visible
                self.jsonActionsStackView.isHidden = false
                self.jsonActionsToolbar.isHidden = false
                self.navigationContainerView.isHidden = false
                self.actionsBar.isHidden = false
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
    internal func displayFileContent(url: URL, data: Data) {
        print("📝 Displaying file content for: \(url.lastPathComponent)")
        let filename = url.lastPathComponent
        let baseFont = fileContentView.font ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
        var displayText: String? = nil
        var textColor = UIColor.label
        
        // Try decoding as UTF-8 text
        if let text = String(data: data, encoding: .utf8) {
            // Check if file is JSON based on extension or content
            let isJsonExtension = url.pathExtension.lowercased() == "json"
            let content = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let startsWithBrace = content.hasPrefix("{") && content.hasSuffix("}")
            let startsWithBracket = content.hasPrefix("[") && content.hasSuffix("]")
            
            if isJsonExtension || startsWithBrace || startsWithBracket {
                print("Processing as JSON file")
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
        // Get the URL to the sample.json file in the app bundle
        // First try with no subdirectory, then try with subdirectory
        var sampleJsonURL = Bundle.main.url(forResource: "sample", withExtension: "json")
        if sampleJsonURL == nil {
            // Try looking in SampleFiles directory
            sampleJsonURL = Bundle.main.url(forResource: "sample", withExtension: "json", subdirectory: "SampleFiles")
        }
        
        if let sampleJsonURL = sampleJsonURL {
            do {
                // Load the sample JSON content
                let data = try Data(contentsOf: sampleJsonURL)
                
                // Parse the JSON to make sure it's valid
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                
                // Note: Sample file URL is read-only (in bundle)
                // We'll set it but inform user they can't save changes to it
                self.currentFileUrl = sampleJsonURL
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
                        
                        // Show toast message
                        self.showEnhancedToast(message: "Sample file is read-only", type: ToastType.info)
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
