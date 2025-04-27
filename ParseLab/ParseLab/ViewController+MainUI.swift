//
//  ViewController+MainUI.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit
import Foundation

// Extension to handle the main UI setup for ViewController
extension ViewController {

    // Setup the main UI structure with modern components
    func setupModernUI() {
        // Apply the app theme colors
        if #available(iOS 13.0, *) {
            view.backgroundColor = DesignSystem.Colors.background
        } else {
            view.backgroundColor = .white
        }
        
        // --- Main Toolbar (Top: Open/Sample) --- TEST: Using standard UIStackView
        let mainToolbar = UIStackView() // Use standard UIStackView for testing
        mainToolbar.axis = .horizontal
        mainToolbar.distribution = .fillEqually // Simple distribution
        mainToolbar.spacing = DesignSystem.Spacing.medium
        mainToolbar.translatesAutoresizingMaskIntoConstraints = false
        mainToolbar.isUserInteractionEnabled = true
        
        // Create Open File button
        let openFileButton = UIButton(type: .system)
        openFileButton.setTitle("Open", for: .normal)
        if #available(iOS 13.0, *) {
            openFileButton.setImage(UIImage(systemName: "folder"), for: .normal)
        }
        openFileButton.translatesAutoresizingMaskIntoConstraints = false
        openFileButton.backgroundColor = DesignSystem.Colors.primary
        openFileButton.setTitleColor(.white, for: .normal)
        openFileButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        openFileButton.tintColor = .white
        openFileButton.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.medium)
        openFileButton.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.tiny,
            left: DesignSystem.Spacing.small,
            bottom: DesignSystem.Spacing.tiny,
            right: DesignSystem.Spacing.small
        )
        openFileButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        openFileButton.showsMenuAsPrimaryAction = true
        openFileButton.setContentHuggingPriority(.required, for: .horizontal)
        openFileButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        openFileButton.isUserInteractionEnabled = true
        self.openButton = openFileButton
        
        // Create Load Sample button
        let loadSampleButton = UIButton(type: .system)
        loadSampleButton.setTitle("Sample", for: .normal)
        if #available(iOS 13.0, *) {
            loadSampleButton.setImage(UIImage(systemName: "doc.text"), for: .normal)
        }
        loadSampleButton.translatesAutoresizingMaskIntoConstraints = false
        loadSampleButton.backgroundColor = DesignSystem.Colors.backgroundTertiary
        loadSampleButton.setTitleColor(DesignSystem.Colors.text, for: .normal)
        loadSampleButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        loadSampleButton.tintColor = DesignSystem.Colors.primary
        loadSampleButton.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.medium)
        loadSampleButton.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.tiny,
            left: DesignSystem.Spacing.small,
            bottom: DesignSystem.Spacing.tiny,
            right: DesignSystem.Spacing.small
        )
        loadSampleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        loadSampleButton.isUserInteractionEnabled = true
        self.loadSampleButton = loadSampleButton
        
        // Add buttons directly to the test stack view
        mainToolbar.addArrangedSubview(openFileButton)
        mainToolbar.addArrangedSubview(loadSampleButton)
        view.addSubview(mainToolbar)
        
        // --- Actions Bar (Second Toolbar: JSON Actions) ---
        let actionsBar = ModernToolbar()
        actionsBar.translatesAutoresizingMaskIntoConstraints = false
        actionsBar.isHidden = true // Initially hidden until JSON is loaded
        self.actionsBar = actionsBar // Store reference
        
        // Create action buttons using helper
        let validateButton = createStyledToolbarButton(systemName: "checkmark.circle")
        self.validateButton = validateButton

        let formatJsonButton = createStyledToolbarButton(systemName: "text.alignleft")
        self.formatJsonButton = formatJsonButton

        let editButton = createStyledToolbarButton(systemName: "pencil")
        self.editFab = editButton // Compatibility
        self.editToggleButton = editButton

        let searchButton = createStyledToolbarButton(systemName: "magnifyingglass")
        self.searchToggleButton = searchButton

        let minimapButton = createStyledToolbarButton(systemName: "sidebar.right")
        self.minimapToggleButton = minimapButton
        
        // Create View Mode Buttons (Text/Tree)
        let viewModeContainer = createViewModeControl()

        // Add buttons to actions bar
        actionsBar.setLeftItems([validateButton, formatJsonButton, editButton])
        actionsBar.setCenterItems([viewModeContainer])
        actionsBar.setRightItems([searchButton, minimapButton])
        
        view.addSubview(actionsBar)
        
        // --- Path Container ---
        let pathContainer = UIView()
        pathContainer.translatesAutoresizingMaskIntoConstraints = false
        pathContainer.backgroundColor = DesignSystem.Colors.backgroundTertiary
        pathContainer.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        pathContainer.isHidden = true // Initially hidden
        self.pathContainer = pathContainer // Store reference
        pathContainer.addSubview(jsonPathNavigator)
        NSLayoutConstraint.activate([
            jsonPathNavigator.topAnchor.constraint(equalTo: pathContainer.topAnchor, constant: DesignSystem.Spacing.small),
            jsonPathNavigator.bottomAnchor.constraint(equalTo: pathContainer.bottomAnchor, constant: -DesignSystem.Spacing.small),
            jsonPathNavigator.leadingAnchor.constraint(equalTo: pathContainer.leadingAnchor, constant: DesignSystem.Spacing.medium),
            jsonPathNavigator.trailingAnchor.constraint(equalTo: pathContainer.trailingAnchor, constant: -DesignSystem.Spacing.medium)
        ])
        view.addSubview(pathContainer)
        
        // --- Content Stack (TextView + Minimap) ---
        contentStackView.spacing = DesignSystem.Spacing.medium
        fileContentView.applyCodeStyle()
        jsonMinimap.applyCardStyle(cornerRadius: DesignSystem.Sizing.smallCornerRadius, shadowLevel: 0)
        jsonMinimap.isHidden = true
        contentStackView.addArrangedSubview(fileContentView)
        contentStackView.addArrangedSubview(jsonMinimap)
        view.addSubview(contentStackView)
        
        // --- Search UI ---
        view.addSubview(searchContainerView)
        view.addSubview(searchResultsTableView)
        
        // --- Constraints ---
        let layoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // Main toolbar (now UIStackView)
            mainToolbar.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: DesignSystem.Spacing.small),
            mainToolbar.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: DesignSystem.Spacing.small),
            mainToolbar.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -DesignSystem.Spacing.small),
            mainToolbar.heightAnchor.constraint(equalToConstant: 44), // Use standard height
            
            // Actions bar (still ModernToolbar)
            actionsBar.topAnchor.constraint(equalTo: mainToolbar.bottomAnchor, constant: DesignSystem.Spacing.medium),
            actionsBar.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: DesignSystem.Spacing.small),
            actionsBar.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -DesignSystem.Spacing.small),
            actionsBar.heightAnchor.constraint(equalToConstant: 44), // Keep standard height
            
            // Path container
            pathContainer.topAnchor.constraint(equalTo: actionsBar.bottomAnchor, constant: DesignSystem.Spacing.medium),
            pathContainer.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: DesignSystem.Spacing.small),
            pathContainer.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -DesignSystem.Spacing.small),
            pathContainer.heightAnchor.constraint(equalToConstant: 44),
            
            // Content stack
            contentStackView.topAnchor.constraint(equalTo: pathContainer.bottomAnchor, constant: DesignSystem.Spacing.medium),
            contentStackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: DesignSystem.Spacing.small),
            contentStackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -DesignSystem.Spacing.small),
            contentStackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -DesignSystem.Spacing.small),
            
            // Minimap width
            jsonMinimap.widthAnchor.constraint(equalToConstant: 120),
        ])
        
        // Store reference to main toolbar (now UIStackView)
        self.mainToolbar = mainToolbar
        
        // Add button actions
        setupButtonActions()
    }

    // Helper to create styled icon-only toolbar buttons
    private func createStyledToolbarButton(systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal) // Icon only
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium) // Adjusted size
            let icon = UIImage(systemName: systemName, withConfiguration: config)
            button.setImage(icon, for: .normal)
            button.imageView?.contentMode = .center
            button.tintColor = DesignSystem.Colors.primary
        }
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) // Square padding
        button.backgroundColor = DesignSystem.Colors.backgroundTertiary
        button.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        
        let sizeConstraint: CGFloat = 40
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: sizeConstraint)
        widthConstraint.priority = .defaultHigh
        widthConstraint.isActive = true
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: sizeConstraint)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return button
    }
    
    // Helper to create the Text/Tree view mode control
    private func createViewModeControl() -> UIView {
        let viewModeContainer = UIView()
        viewModeContainer.translatesAutoresizingMaskIntoConstraints = false
        viewModeContainer.backgroundColor = DesignSystem.Colors.backgroundTertiary
        viewModeContainer.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius

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
        textModeButton.addTarget(self, action: #selector(buttonModeChanged(_:)), for: .touchUpInside)
        self.textModeButton = textModeButton // Store reference

        let treeModeButton = UIButton(type: .system)
        treeModeButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            let icon = UIImage(systemName: "list.bullet", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
            treeModeButton.setImage(icon, for: .normal)
        } else { treeModeButton.setTitle("L", for: .normal) }
        treeModeButton.backgroundColor = .clear // Initially deselected
        treeModeButton.tintColor = DesignSystem.Colors.text
        treeModeButton.tag = 1
        treeModeButton.addTarget(self, action: #selector(buttonModeChanged(_:)), for: .touchUpInside)
        self.treeModeButton = treeModeButton // Store reference

        let buttonPadding = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        textModeButton.contentEdgeInsets = buttonPadding
        treeModeButton.contentEdgeInsets = buttonPadding
        
        textModeButton.imageView?.contentMode = .scaleAspectFit
        treeModeButton.imageView?.contentMode = .scaleAspectFit

        let buttonStack = UIStackView(arrangedSubviews: [textModeButton, treeModeButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 0
        
        viewModeContainer.addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: viewModeContainer.topAnchor, constant: 2),
            buttonStack.bottomAnchor.constraint(equalTo: viewModeContainer.bottomAnchor, constant: -2),
            buttonStack.leadingAnchor.constraint(equalTo: viewModeContainer.leadingAnchor, constant: 2),
            buttonStack.trailingAnchor.constraint(equalTo: viewModeContainer.trailingAnchor, constant: -2)
        ])
        
        // Hidden compatibility control
        let segmentedControl = UISegmentedControl(items: ["Text", "Tree"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.isHidden = true
        self.viewModeSegmentedControl = segmentedControl
        viewModeContainer.addSubview(segmentedControl)

        return viewModeContainer
    }
    
    // Method to add the file info button to the action bar
    internal func setupFileInfoButton(_ originalButton: UIView) {
            let infoView = InfoButtonView(size: 36)
            infoView.onTap = { [weak self] in
                self?.toggleFileMetadataView()
            }
        self.fileInfoButton = infoView // Store reference of type InfoButtonView?
        infoView.isEnabled = false

        // Add infoView to the end of the right items in actionsBar
        var existingItems = actionsBar.getRightItems()
        existingItems.append(infoView)
        actionsBar.setRightItems(existingItems)
    }
    
    // Show or hide JSON-specific UI elements
    func updateUIVisibilityForJsonLoaded(_ isLoaded: Bool) {
        print("[UI UPDATE] updateUIVisibility called with isLoaded: \(isLoaded)")
        actionsBar.isHidden = !isLoaded
        pathContainer.isHidden = !isLoaded
        
        print("[UI UPDATE] mainToolbar.isHidden: \(mainToolbar.isHidden)")
        print("[UI UPDATE] actionsBar.isHidden: \(actionsBar.isHidden)")
        print("[UI UPDATE] pathContainer.isHidden: \(pathContainer.isHidden)")
        
        // Enable/disable JSON action buttons - remove optional chaining
        validateButton.isEnabled = isLoaded
        formatJsonButton.isEnabled = isLoaded
        editToggleButton.isEnabled = isLoaded
        searchToggleButton.isEnabled = isLoaded
        minimapToggleButton.isEnabled = isLoaded
        (fileInfoButton as? InfoButtonView)?.isEnabled = isLoaded
        textModeButton.isEnabled = isLoaded
        treeModeButton.isEnabled = isLoaded
        
        if !jsonMinimap.isHidden {
            jsonMinimap.isHidden = !isLoaded
            print("[UI UPDATE] jsonMinimap.isHidden: \(jsonMinimap.isHidden)")
        }
        
        if !isLoaded {
            searchContainerView.isHidden = true
            searchResultsTableView.isHidden = true
            print("[UI UPDATE] Search UI hidden")
        }
        
        if isLoaded {
            print("[UI UPDATE] Bringing pathContainer & contentStackView to front")
            view.bringSubviewToFront(pathContainer)
            view.bringSubviewToFront(contentStackView)
            print("[UI UPDATE] Calling setupEditControls")
            setupEditControls()
        }
        
        // Ensure mainToolbar remains visible (it should always be visible)
        mainToolbar.isHidden = false
        view.bringSubviewToFront(mainToolbar)
        print("[UI UPDATE] Ensuring mainToolbar is visible and brought to front.")
        
        // Force layout update
        print("[UI UPDATE] Forcing layoutIfNeeded")
        view.layoutIfNeeded()
        print("[UI UPDATE] updateUIVisibility finished")
    }
    
    // Show or hide edit mode UI (using overlay)
    func showEditModeUI(_ show: Bool) {
        if show {
            // Create edit mode overlay if it doesn't exist
            if editModeOverlay == nil {
                editModeOverlay = EditModeOverlay()
                
                // Set up action handlers
                editModeOverlay?.onSave = { [weak self] in
                    print("Edit overlay - Save button tapped")
                    self?.saveJsonChanges()
                }
                
                editModeOverlay?.onCancel = { [weak self] in
                    print("Edit overlay - Cancel button tapped")
                    self?.cancelEditing()
                }
                
                editModeOverlay?.onFormat = { [weak self] in
                    print("Edit overlay - Format button tapped")
                    self?.formatJson()
                }
                
                editModeOverlay?.onEdit = { [weak self] in
                    print("Edit overlay - Edit button tapped")
                    // Continue editing - hide the overlay and keep edit mode on
                    guard let self = self else { return }
                    
                    // Hide overlay
                    self.editModeOverlay?.hide()
                    
                    // Ensure edit mode is active
                    self.isEditMode = true
                    
                    // Make the text view directly editable
                    self.fileContentView.isEditable = true
                    self.fileContentView.isSelectable = true
                    self.fileContentView.isUserInteractionEnabled = true
                    self.makeTextViewDirectlyEditable()
                    
                    // Ensure UI reflect edit mode
                    self.updateUIForEditMode()
                    
                    // Force keyboard focus
                    DispatchQueue.main.async {
                        self.fileContentView.becomeFirstResponder()
                        print("Edit mode active, text view editable: \(self.fileContentView.isEditable)")
                    }
                }
            }
            
            // Ensure the overlay is created and properly set up
            if editModeOverlay == nil {
                print("Warning: Edit overlay could not be created")
                return
            }
            
            // Show the overlay with animation and bring to front
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.editModeOverlay?.show(in: self.view)
                self.view.bringSubviewToFront(self.editModeOverlay!)
            }
        } else {
            // Hide the overlay
            if let overlay = editModeOverlay {
                overlay.hide()
            }
            
            // Show confirmation toast if was editing
            if fileContentView.isEditable {
                showToast(message: "Edit mode disabled", type: .info)
            }
        }
    }
    
    // Show a toast message
    func showToast(message: String, type: ToastType = .info) {
        showEnhancedToast(message: message, type: type)
    }
}
