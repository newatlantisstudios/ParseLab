import UIKit

// A modular toolbar manager that can dynamically update buttons based on file type
class ModularToolbarManager {
    
    // Reference to the view controller
    private weak var viewController: ViewController?
    
    // The toolbar container
    private var toolbar: ModernToolbar
    
    // Button references (shared across different file types)
    private var validateButton: UIButton!
    private var editButton: UIButton!
    private var searchButton: UIButton!
    private var textButton: UIButton!
    private var treeButton: UIButton!
    private var tableViewButton: UIButton!
    private var fileInfoButton: UIView?
    
    // View mode control
    private var viewModeControl: UIView?
    
    // File type enum
    enum FileType {
        case json
        case yaml
        case toml
        case ini
        case xml
        case csv
    }
    
    init(viewController: ViewController, toolbar: ModernToolbar) {
        self.viewController = viewController
        self.toolbar = toolbar
        setupButtons()
    }
    
    // Create all the buttons that might be used
    private func setupButtons() {
        // Check if buttons already exist on the view controller
        if let existingValidateButton = viewController?.validateButton {
            validateButton = existingValidateButton
            print("[MODULAR TOOLBAR] Using existing validate button from view controller")
        } else {
            validateButton = createButton(systemName: "checkmark.circle")
            validateButton.addTarget(viewController, action: #selector(ViewController.validateJsonTapped), for: .touchUpInside)
            viewController?.validateButton = validateButton
        }
        
        if let existingEditButton = viewController?.editToggleButton {
            editButton = existingEditButton
            print("[MODULAR TOOLBAR] Using existing edit button from view controller")
        } else {
            editButton = createButton(systemName: "pencil")
            editButton.addTarget(viewController, action: #selector(ViewController.toggleEditMode), for: .touchUpInside)
            viewController?.editToggleButton = editButton
        }
        
        if let existingSearchButton = viewController?.searchToggleButton {
            searchButton = existingSearchButton
            print("[MODULAR TOOLBAR] Using existing search button from view controller")
        } else {
            searchButton = createButton(systemName: "magnifyingglass")
            searchButton.addTarget(viewController, action: #selector(ViewController.handleSearchButtonTapped), for: .touchUpInside)
            viewController?.searchToggleButton = searchButton
        }
        
        if let existingTextButton = viewController?.textModeButton {
            textButton = existingTextButton
            print("[MODULAR TOOLBAR] Using existing text button from view controller")
        } else {
            textButton = createButton(systemName: "doc")
            textButton.tag = 0
            textButton.addTarget(viewController, action: #selector(ViewController.buttonModeChanged(_:)), for: .touchUpInside)
            viewController?.textModeButton = textButton
        }
        
        if let existingTreeButton = viewController?.treeModeButton {
            treeButton = existingTreeButton
            print("[MODULAR TOOLBAR] Using existing tree button from view controller")
        } else {
            treeButton = createButton(systemName: "list.bullet")
            treeButton.tag = 1
            treeButton.addTarget(viewController, action: #selector(ViewController.buttonModeChanged(_:)), for: .touchUpInside)
            viewController?.treeModeButton = treeButton
        }
        
        // Table view button (used by CSV)
        tableViewButton = createButton(systemName: "tablecells")
        tableViewButton.addTarget(viewController, action: #selector(ViewController.tableViewButtonTapped), for: .touchUpInside)
        
        print("[MODULAR TOOLBAR] Button setup complete")
        print("[MODULAR TOOLBAR] Validate button has \(validateButton.allTargets.count) targets")
    }
    
    // Create a styled button
    private func createButton(systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            let icon = UIImage(systemName: systemName, withConfiguration: config)
            button.setImage(icon, for: .normal)
            button.imageView?.contentMode = .center
            button.tintColor = DesignSystem.Colors.primary
        }
        
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.backgroundColor = DesignSystem.Colors.backgroundTertiary
        button.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Add height constraint to ensure button is visible
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        return button
    }
    
    // Create the view mode control (text/tree buttons)
    private func createViewModeControl() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = DesignSystem.Colors.backgroundTertiary
        container.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        container.clipsToBounds = true
        
        // Update button states
        textButton.backgroundColor = DesignSystem.Colors.primary
        textButton.tintColor = .white
        treeButton.backgroundColor = .clear
        treeButton.tintColor = DesignSystem.Colors.text
        
        // Set up button stack
        let buttonStack = UIStackView(arrangedSubviews: [textButton, treeButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 0
        
        container.addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: container.topAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        return container
    }
    
    // Configure toolbar for specific file type
    func configureForFileType(_ fileType: FileType) {
        print("[MODULAR TOOLBAR] Configuring for file type: \(fileType)")
        print("[MODULAR TOOLBAR] Toolbar hidden before: \(toolbar.isHidden), alpha: \(toolbar.alpha)")
        
        // Clear all items first
        toolbar.setLeftItems([])
        toolbar.setCenterItems([])
        toolbar.setRightItems([])
        
        print("[MODULAR TOOLBAR] After clearing - stacks count: left=\(toolbar.leftStackView.arrangedSubviews.count), center=\(toolbar.centerStackView.arrangedSubviews.count), right=\(toolbar.rightStackView.arrangedSubviews.count)")
        
        // Ensure buttons are visible
        validateButton.isHidden = false
        validateButton.isEnabled = true
        editButton.isHidden = false
        editButton.isEnabled = true
        searchButton.isHidden = false
        searchButton.isEnabled = true
        
        // Common elements for all file types
        var leftItems: [UIView] = [validateButton, editButton]
        var centerItems: [UIView] = []
        var rightItems: [UIView] = [searchButton]
        
        // Configure based on file type
        switch fileType {
        case .json, .yaml, .toml, .ini, .xml:
            // Add text/tree mode control
            viewModeControl = createViewModeControl()
            centerItems = [viewModeControl!]
            print("[MODULAR TOOLBAR] Added view mode control for \(fileType)")
            
        case .csv:
            // Replace tree button with table view button
            viewModeControl = nil
            rightItems.insert(tableViewButton, at: 0)
            print("[MODULAR TOOLBAR] Added table view button for CSV")
        }
        
        // Add file info button if available
        if let infoButton = viewController?.fileInfoButton {
            rightItems.append(infoButton)
            print("[MODULAR TOOLBAR] Added file info button")
        }
        
        // Set the items
        toolbar.setLeftItems(leftItems)
        toolbar.setCenterItems(centerItems)
        toolbar.setRightItems(rightItems)
        
        print("[MODULAR TOOLBAR] After setting items - left: \(leftItems.count), center: \(centerItems.count), right: \(rightItems.count)")
        print("[MODULAR TOOLBAR] Stack views count after setting: left=\(toolbar.leftStackView.arrangedSubviews.count), center=\(toolbar.centerStackView.arrangedSubviews.count), right=\(toolbar.rightStackView.arrangedSubviews.count)")
        
        // Debug all buttons
        print("[MODULAR TOOLBAR] Validate button - hidden: \(validateButton.isHidden), enabled: \(validateButton.isEnabled), has action: \(validateButton.allTargets.count > 0)")
        print("[MODULAR TOOLBAR] Edit button - hidden: \(editButton.isHidden), enabled: \(editButton.isEnabled), has action: \(editButton.allTargets.count > 0)")
        print("[MODULAR TOOLBAR] Search button - hidden: \(searchButton.isHidden), enabled: \(searchButton.isEnabled), has action: \(searchButton.allTargets.count > 0)")
        
        // Debug left items specifically
        print("[MODULAR TOOLBAR] Left items debug:")
        for (index, item) in leftItems.enumerated() {
            if let button = item as? UIButton {
                print("  Item \(index): button with \(button.allTargets.count) targets, hidden: \(button.isHidden)")
            } else {
                print("  Item \(index): \(type(of: item)), hidden: \(item.isHidden)")
            }
        }
        
        // Ensure toolbar is visible
        toolbar.isHidden = false
        toolbar.alpha = 1.0
        print("[MODULAR TOOLBAR] Toolbar visibility set - hidden: \(toolbar.isHidden), alpha: \(toolbar.alpha)")
        
        // Force layout update
        toolbar.setNeedsLayout()
        toolbar.layoutIfNeeded()
        
        // Bring to front
        viewController?.view.bringSubviewToFront(toolbar)
        
        print("[MODULAR TOOLBAR] Configuration complete - toolbar frame: \(toolbar.frame)")
        print("[MODULAR TOOLBAR] Configuration complete - toolbar bounds: \(toolbar.bounds)")
        print("[MODULAR TOOLBAR] Configuration complete - toolbar superview: \(toolbar.superview?.description ?? "nil")")
        
        // Debug stack view layouts
        print("[MODULAR TOOLBAR] Left stack: frame=\(toolbar.leftStackView.frame), count=\(toolbar.leftStackView.arrangedSubviews.count)")
        print("[MODULAR TOOLBAR] Center stack: frame=\(toolbar.centerStackView.frame), count=\(toolbar.centerStackView.arrangedSubviews.count)")
        print("[MODULAR TOOLBAR] Right stack: frame=\(toolbar.rightStackView.frame), count=\(toolbar.rightStackView.arrangedSubviews.count)")
    }
    
    // Clean up any state
    func reset() {
        print("[MODULAR TOOLBAR] Resetting toolbar")
        toolbar.setLeftItems([])
        toolbar.setCenterItems([])
        toolbar.setRightItems([])
        viewModeControl = nil
    }
}