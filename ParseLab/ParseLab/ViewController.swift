//
//  ViewController.swift
//  ParseLab
//
//  Created by x on 4/8/25.
//

import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController {
    
    // JSON Highlighter instance
    private let jsonHighlighter = JSONHighlighter()
    
    // Keep track of parsed JSON for tree view
    private var currentJsonObject: Any? = nil
    
    // Reference to the recent files menu
    private var recentFilesMenu: UIMenu?
    
    // JSON Minimap for visual navigation
    private let jsonMinimap: JsonMinimap = {
        let minimap = JsonMinimap()
        minimap.translatesAutoresizingMaskIntoConstraints = false
        return minimap
    }()
    
    // JSON Path Navigator for breadcrumb navigation
    private let jsonPathNavigator: JsonPathNavigator = {
        let navigator = JsonPathNavigator()
        navigator.translatesAutoresizingMaskIntoConstraints = false
        return navigator
    }()
    
    // Current navigation path components
    private var currentPath: [String] = ["$"]
    
    // Scroll position in text view
    private var textViewContentOffset: CGPoint = .zero

    private let openButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open File", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true  // Allow menu for recent files
        return button
    }()
    
    private let actionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let jsonActionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true // Initially hidden
        return stackView
    }()
    
    // Container for the path navigator
    private let navigationContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.isHidden = true // Initially hidden
        return view
    }()
    
    private let loadSampleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load Sample", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let validateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Validate JSON", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let treeViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tree View", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewModeSegmentedControl: UISegmentedControl = {
        let items = ["Text", "Tree"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private let fileContentView: UITextView = { // Renamed from jsonTextView
        let textView = UITextView()
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular) // Keep monospaced for now
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // Main content stack view for file content and minimap
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // Removed SyntaxColors struct

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up UI
        setupUI()
        
        // Clear text view initially and show welcome message
        DispatchQueue.main.async {
            let welcomeMessage = """
            Welcome to ParseLab!
            
            This app can open and display different types of text files, with special support for JSON files.
            
            JSON features:
            • Syntax highlighting
            • JSON validation
            • Tree view for complex JSON structures
            • In-depth JSON analytics
            
            To get started:
            • Tap "Open File" to select a file from your device
            • Tap "Load Sample" to view a sample JSON file
            • Open a JSON file from the Files app by selecting ParseLab
            """
            
            self.fileContentView.text = welcomeMessage
            self.fileContentView.textColor = .label
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    private func setupUI() {
        title = "File Viewer" // More generic title
        view.backgroundColor = .systemBackground
        
        // Set up the Recent Files menu
        updateRecentFilesMenu()

        // Ensure the view extends under the navigation bar and status bar
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true

        // No need to set statusBarStyle directly since we already override preferredStatusBarStyle
        // and have UIViewControllerBasedStatusBarAppearance set to true in Info.plist

        // Setup action buttons at the top
        actionsStackView.addArrangedSubview(openButton)
        actionsStackView.addArrangedSubview(loadSampleButton)
        view.addSubview(actionsStackView)
        
        // Add JSON-specific controls
        jsonActionsStackView.addArrangedSubview(validateButton)
        jsonActionsStackView.addArrangedSubview(viewModeSegmentedControl)
        view.addSubview(jsonActionsStackView)
        
        // Set up navigation container with breadcrumbs
        navigationContainerView.addSubview(jsonPathNavigator)
        view.addSubview(navigationContainerView)
        
        // Set up content stack view with text view and minimap
        contentStackView.addArrangedSubview(fileContentView) // Use renamed view
        contentStackView.addArrangedSubview(jsonMinimap)
        view.addSubview(contentStackView)

        let layoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            actionsStackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 16),
            actionsStackView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            
            jsonActionsStackView.topAnchor.constraint(equalTo: actionsStackView.bottomAnchor, constant: 16),
            jsonActionsStackView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            
            navigationContainerView.topAnchor.constraint(equalTo: jsonActionsStackView.bottomAnchor, constant: 16),
            navigationContainerView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
            navigationContainerView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16),
            navigationContainerView.heightAnchor.constraint(equalToConstant: 44),
            
            jsonPathNavigator.topAnchor.constraint(equalTo: navigationContainerView.topAnchor),
            jsonPathNavigator.leadingAnchor.constraint(equalTo: navigationContainerView.leadingAnchor),
            jsonPathNavigator.trailingAnchor.constraint(equalTo: navigationContainerView.trailingAnchor),
            jsonPathNavigator.bottomAnchor.constraint(equalTo: navigationContainerView.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: navigationContainerView.bottomAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -16),
            
            jsonMinimap.widthAnchor.constraint(equalToConstant: 80)
        ])

        // We'll configure the open button menu instead of a direct action
        loadSampleButton.addTarget(self, action: #selector(loadSampleButtonTapped), for: .touchUpInside)
        validateButton.addTarget(self, action: #selector(validateJsonTapped), for: .touchUpInside)
        viewModeSegmentedControl.addTarget(self, action: #selector(viewModeChanged), for: .valueChanged)
        
        // Set up navigation callbacks
        jsonMinimap.onMinimapSelection = { [weak self] path in
            self?.navigateToJsonPath(path)
        }
        
        jsonPathNavigator.onPathSelected = { [weak self] index in
            guard let self = self, index < self.currentPath.count else { return }
            // Truncate the path to the selected index
            let newPath = Array(self.currentPath.prefix(index + 1))
            self.navigateToPath(newPath)
        }
        
        // Set up scroll observation for minimap updates
        fileContentView.delegate = self
    }

    // Update the recent files menu based on the current recent files list
    private func updateRecentFilesMenu() {
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
    
    // Open the file picker dialog
    private func openFilePicker() {
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
    private func openRecentFile(at index: Int) {
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
    func handleFileUrl(_ url: URL) {
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
            displayFileContent(url: url, data: data)
            
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
            
            // Add to recent files
            RecentFilesManager.shared.addFile(url: url, isJSON: isJSON)
            
            // Update open button menu with new recent files list
            updateRecentFilesMenu()
        } catch {
            displayError("Error reading file: \(error.localizedDescription)")
        }
    }

    // New method to display generic file content
    // Define syntax colors for JSON highlighting
    private struct SyntaxColors {
        static let key = UIColor.systemBlue
        static let string = UIColor.systemGreen
        static let number = UIColor.systemOrange
        static let boolean = UIColor.systemPurple
        static let null = UIColor.systemRed
        static let structural = UIColor.systemGray
        static let error = UIColor.systemRed
        static let plainText = UIColor.label
    }
    
    private func displayFileContent(url: URL, data: Data) {
        let filename = url.lastPathComponent
        let baseFont = fileContentView.font ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
        var displayText: String? = nil
        var textColor = UIColor.label
        
        // Try decoding as UTF-8 text
        if let text = String(data: data, encoding: .utf8) {
            // Check if file is JSON based on extension or content
            if url.pathExtension.lowercased() == "json" || (text.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("{") && text.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("}")) || (text.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("[") && text.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("]")) {
                do {
                    // Validate and pretty-print JSON
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    self.currentJsonObject = jsonObject // Store for later use
                    
                    let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
                    if let prettyText = String(data: prettyData, encoding: .utf8) {
                        displayText = prettyText
                        DispatchQueue.main.async {
                            self.title = "JSON Viewer: \(filename)"
                            self.jsonActionsStackView.isHidden = false
                            self.navigationContainerView.isHidden = false
                            self.jsonMinimap.isHidden = false
                            
                            // Reset navigation path to root
                            self.currentPath = ["$"]
                            self.jsonPathNavigator.updatePath(self.currentPath)
                            
                            // Set the JSON structure for the minimap
                            self.jsonMinimap.setJsonStructure(jsonObject)
                            
                            // Display the JSON with syntax highlighting
                            let attributedString = self.jsonHighlighter.highlightJSON(prettyText, font: self.fileContentView.font)
                            self.fileContentView.attributedText = attributedString
                            
                            // Initial viewport update for minimap
                            self.updateMinimapViewport()
                        }
                        return // Exit early as we've handled the JSON display
                    }
                } catch {
                    // If JSON parsing fails, show the error and raw content
                    displayText = "JSON Parsing Error: \(error.localizedDescription)\n\n\(text)"
                    textColor = SyntaxColors.error
                }
            } else {
                displayText = text
                DispatchQueue.main.async {
                    self.jsonActionsStackView.isHidden = true
                    self.navigationContainerView.isHidden = true
                    self.jsonMinimap.isHidden = true
                    self.currentJsonObject = nil
                }
            }
        } else {
            // If not UTF-8, try common encodings (optional, can be expanded)
            // For now, just indicate it's likely binary
            displayText = "File: \(filename)\n\n(Cannot display binary content)"
            textColor = .secondaryLabel // Use a different color for the message
        }

        let attributedString = NSAttributedString(
            string: displayText ?? "Error: Could not process file content.", // Fallback message
            attributes: [.foregroundColor: textColor, .font: baseFont]
        )

        // Ensure UI updates on main thread
        DispatchQueue.main.async {
            self.title = "File Viewer: \(filename)"
            self.jsonActionsStackView.isHidden = true
            self.navigationContainerView.isHidden = true
            self.jsonMinimap.isHidden = true
            self.currentJsonObject = nil
            self.fileContentView.attributedText = attributedString
        }
    }
    
    // JSON syntax highlighting is now handled by JSONHighlighter class

    // MARK: - Button Actions
    
    @objc private func loadSampleButtonTapped() {
        // Get the URL to the sample.json file in the app bundle
        if let sampleJsonURL = Bundle.main.url(forResource: "sample", withExtension: "json") {
            do {
                let data = try Data(contentsOf: sampleJsonURL)
                displayFileContent(url: sampleJsonURL, data: data)
            } catch {
                displayError("Error loading sample JSON: \(error.localizedDescription)")
            }
        } else {
            displayError("Could not find sample.json in the app bundle")
        }
    }
    
    // MARK: - JSON Actions
    
    @objc private func validateJsonTapped() {
        guard let jsonObject = currentJsonObject else {
            displayError("No valid JSON loaded")
            return
        }
        
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
        
        let stats = """
        JSON Validation Results:
        • Structure is valid JSON
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
        
        let baseFont = fileContentView.font ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
        let attributedString = NSAttributedString(
            string: stats,
            attributes: [.foregroundColor: UIColor.label, .font: baseFont]
        )
        
        fileContentView.attributedText = attributedString
    }
    
    @objc private func viewModeChanged(_ sender: UISegmentedControl) {
        guard let jsonObject = currentJsonObject else {
            sender.selectedSegmentIndex = 0 // Revert to Text view
            return
        }
        
        if sender.selectedSegmentIndex == 0 { // Text mode
            do {
                let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
                if let prettyText = String(data: prettyData, encoding: .utf8) {
                    let attributedString = jsonHighlighter.highlightJSON(prettyText, font: fileContentView.font)
                    fileContentView.attributedText = attributedString
                }
            } catch {
                displayError("Error formatting JSON: \(error.localizedDescription)")
            }
        } else { // Tree mode
            let treeText = generateJsonTreeView(jsonObject)
            let baseFont = fileContentView.font ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
            let attributedString = NSAttributedString(
                string: treeText,
                attributes: [.foregroundColor: UIColor.label, .font: baseFont]
            )
            fileContentView.attributedText = attributedString
        }
    }
    
    private func generateJsonTreeView(_ json: Any, level: Int = 0, isLastItem: Bool = true, path: String = "$") -> String {
        let indent = String(repeating: "  ", count: level)
        let connector = isLastItem ? "└─ " : "├─ "
        var result = ""
        
        if let dict = json as? [String: Any] {
            result += "\(indent)\(level > 0 ? connector : "")\(path) (Object) {\n"
            
            let keys = dict.keys.sorted()
            for (index, key) in keys.enumerated() {
                let isLast = index == keys.count - 1
                let value = dict[key]!
                let childPath = "\(path).\(key)"
                result += generateJsonTreeView(value, level: level + 1, isLastItem: isLast, path: key)
            }
            
            result += "\(indent)}\n"
        } else if let array = json as? [Any] {
            result += "\(indent)\(level > 0 ? connector : "")\(path) (Array) [\n"
            
            for (index, item) in array.enumerated() {
                let isLast = index == array.count - 1
                let childPath = "\(path)[\(index)]"
                result += generateJsonTreeView(item, level: level + 1, isLastItem: isLast, path: "[\(index)]")
            }
            
            result += "\(indent)]\n"
        } else {
            var valueStr = ""
            
            if let stringValue = json as? String {
                valueStr = "\"\(stringValue)\""
            } else if let boolValue = json as? Bool {
                valueStr = boolValue ? "true" : "false"
            } else if json is NSNull {
                valueStr = "null"
            } else {
                valueStr = "\(json)"
            }
            
            result += "\(indent)\(level > 0 ? connector : "")\(path): \(valueStr)\n"
        }
        
        return result
    }

    private func displayError(_ message: String) {
        let baseFont = fileContentView.font ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
        let attributedString = NSAttributedString(
            string: message,
            attributes: [.foregroundColor: UIColor.systemRed, .font: baseFont]
        )
        // Ensure this runs on the main thread
        DispatchQueue.main.async {
            self.fileContentView.attributedText = attributedString
        }
    }
}

// MARK: - JSON Navigation Methods

private extension ViewController {
    // Update the viewport rectangle in the minimap
    func updateMinimapViewport() {
        let visibleRect = CGRect(
            x: fileContentView.contentOffset.x,
            y: fileContentView.contentOffset.y,
            width: fileContentView.bounds.width,
            height: fileContentView.bounds.height
        )
        
        let contentSize = fileContentView.contentSize
        jsonMinimap.updateVisibleRect(visibleRect, contentSize: contentSize)
    }
    
    // Navigate to a specific path in the JSON
    func navigateToJsonPath(_ path: String) {
        // Parse the path into components
        let components = parseJsonPath(path)
        navigateToPath(components)
    }
    
    // Navigate to a path represented as an array of components
    func navigateToPath(_ pathComponents: [String]) {
        guard let jsonObject = currentJsonObject else { return }
        
        // Update the current path
        self.currentPath = pathComponents
        
        // Update the path navigator
        jsonPathNavigator.updatePath(pathComponents)
        
        // Find the node at this path
        var currentNode = jsonObject
        var jsonPath = pathComponents.first ?? "$" // Start at root
        
        // Skip the root component ($) when traversing
        for component in pathComponents.dropFirst() {
            if component.hasPrefix("[") && component.hasSuffix("]") {
                // Array index
                let indexStr = component.dropFirst().dropLast()
                if let index = Int(indexStr), let array = currentNode as? [Any], index < array.count {
                    currentNode = array[index]
                    jsonPath += component
                } else {
                    // Invalid path
                    return
                }
            } else {
                // Object property
                if let dict = currentNode as? [String: Any], let value = dict[component] {
                    currentNode = value
                    jsonPath += "." + component
                } else {
                    // Invalid path
                    return
                }
            }
        }
        
        // Generate a tree or formatted JSON for this node
        if viewModeSegmentedControl.selectedSegmentIndex == 0 { // Text mode
            do {
                // Pretty-print the node
                let prettyData = try JSONSerialization.data(withJSONObject: currentNode, options: [.prettyPrinted, .sortedKeys])
                if let prettyText = String(data: prettyData, encoding: .utf8) {
                    let attributedString = jsonHighlighter.highlightJSON(prettyText, font: fileContentView.font)
                    fileContentView.attributedText = attributedString
                }
            } catch {
                displayError("Error formatting JSON node: \(error.localizedDescription)")
            }
        } else { // Tree mode
            let treeText = generateJsonTreeView(currentNode, path: pathComponents.last ?? "$")
            let baseFont = fileContentView.font ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
            let attributedString = NSAttributedString(
                string: treeText,
                attributes: [.foregroundColor: UIColor.label, .font: baseFont]
            )
            fileContentView.attributedText = attributedString
        }
    }
    
    // Parse a JSON path string into components
    func parseJsonPath(_ path: String) -> [String] {
        var components: [String] = []
        var currentComponent = ""
        var inBracket = false
        
        // Handle root component
        if path.hasPrefix("$") {
            components.append("$")
        }
        
        // Parse the rest of the path
        for char in path {
            if char == "[" {
                // Start of array index
                if !currentComponent.isEmpty {
                    components.append(currentComponent)
                    currentComponent = ""
                }
                currentComponent += String(char)
                inBracket = true
            } else if char == "]" {
                // End of array index
                currentComponent += String(char)
                components.append(currentComponent)
                currentComponent = ""
                inBracket = false
            } else if char == "." && !inBracket {
                // Property separator
                if !currentComponent.isEmpty {
                    components.append(currentComponent)
                    currentComponent = ""
                }
            } else {
                // Part of the current component
                currentComponent += String(char)
            }
        }
        
        // Add the last component if any
        if !currentComponent.isEmpty {
            components.append(currentComponent)
        }
        
        return components
    }
}

// MARK: - UITextViewDelegate for Minimap Updates

extension ViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === fileContentView {
            // Store current offset
            textViewContentOffset = scrollView.contentOffset
            // Update minimap viewport
            updateMinimapViewport()
        }
    }
}

extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        // Call the centralized handler
        handleFileUrl(url)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Optional: Handle cancellation if needed
        print("Document picker was cancelled.")
    }
}
