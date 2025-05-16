import UIKit

/// A dedicated UI manager for CSV files that ensures toolbar buttons are always visible
class CSVToolbarManager {
    
    // Parent view controller
    private weak var viewController: ViewController?
    
    // Toolbar view
    private var toolbarView: UIView?
    
    // Flag to track visibility
    private var isToolbarVisible = false
    
    // Initialize with a view controller
    init(viewController: ViewController) {
        self.viewController = viewController
    }
    
    /// Create and show a dedicated toolbar for CSV files
    func showCSVToolbar() {
        guard let viewController = viewController else { 
            print("[CSV TOOLBAR DEBUG] No view controller available")
            return 
        }
        
        print("[CSV TOOLBAR DEBUG] Showing CSV toolbar")
        print("[CSV TOOLBAR DEBUG] Main actions bar hidden state before: \(viewController.actionsBar.isHidden)")
        
        // Hide the default toolbar
        viewController.actionsBar.isHidden = true
        print("[CSV TOOLBAR DEBUG] Main actions bar hidden state after: \(viewController.actionsBar.isHidden)")
        
        // Create a container for our toolbar
        let toolbarContainer = UIView()
        toolbarContainer.translatesAutoresizingMaskIntoConstraints = false
        toolbarContainer.backgroundColor = DesignSystem.Colors.backgroundSecondary
        toolbarContainer.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        toolbarContainer.clipsToBounds = false
        
        // Apply shadow and border
        let shadow = DesignSystem.Shadow.subtle()
        toolbarContainer.layer.shadowColor = shadow.color
        toolbarContainer.layer.shadowOffset = shadow.offset
        toolbarContainer.layer.shadowOpacity = shadow.opacity
        toolbarContainer.layer.shadowRadius = shadow.radius
        toolbarContainer.clipsToBounds = false
        toolbarContainer.layer.borderWidth = 0.5
        toolbarContainer.layer.borderColor = UIColor.separator.cgColor
        
        // Add the container to the view
        viewController.view.addSubview(toolbarContainer)
        
        // Position it where the actions bar would be
        let mainToolbar = viewController.mainToolbar
        NSLayoutConstraint.activate([
            toolbarContainer.topAnchor.constraint(equalTo: mainToolbar.bottomAnchor, constant: DesignSystem.Spacing.medium),
            toolbarContainer.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor, constant: DesignSystem.Spacing.small),
            toolbarContainer.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor, constant: -DesignSystem.Spacing.small),
            toolbarContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
        
        // Create the buttons
        let validateButton = createStyledButton(systemName: "checkmark.circle")
        let editButton = createStyledButton(systemName: "pencil")
        let searchButton = createStyledButton(systemName: "magnifyingglass")
        let tableViewButton = createStyledButton(systemName: "tablecells")
        
        // Add tooltips/accessibility labels for debugging and accessibility
        validateButton.accessibilityLabel = "Validate"
        editButton.accessibilityLabel = "Edit"
        searchButton.accessibilityLabel = "Search"
        tableViewButton.accessibilityLabel = "Table View"
        
        print("[DEBUG] Created CSV toolbar buttons: validate, edit, search, table view")
        
        // Add actions to the buttons
        validateButton.addTarget(viewController, action: #selector(viewController.validateJsonTapped), for: .touchUpInside)
        editButton.addTarget(viewController, action: #selector(viewController.toggleEditMode), for: .touchUpInside)
        searchButton.addTarget(viewController, action: #selector(viewController.handleSearchButtonTapped), for: .touchUpInside)
        tableViewButton.addTarget(viewController, action: #selector(viewController.tableViewButtonTapped), for: .touchUpInside)
        
        // Create left, center, and right stacks for proper button organization
        let leftStack = UIStackView(arrangedSubviews: [validateButton, editButton])
        let centerStack = UIStackView()
        let rightStack = UIStackView(arrangedSubviews: [searchButton, tableViewButton])
        
        [leftStack, centerStack, rightStack].forEach { stack in
            stack.axis = .horizontal
            stack.spacing = DesignSystem.Spacing.small
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Create the main stack view to hold all button stacks
        let mainStack = UIStackView(arrangedSubviews: [leftStack, centerStack, rightStack])
        mainStack.axis = .horizontal
        mainStack.distribution = .equalSpacing
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.isUserInteractionEnabled = true
        
        // Add to container
        toolbarContainer.addSubview(mainStack)
        
        // Layout main stack
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: toolbarContainer.topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(equalTo: toolbarContainer.bottomAnchor, constant: -8),
            mainStack.leadingAnchor.constraint(equalTo: toolbarContainer.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: toolbarContainer.trailingAnchor, constant: -12),
        ])
        
        // Store reference
        self.toolbarView = toolbarContainer
        self.isToolbarVisible = true
        
        // Debug button visibility
        print("[DEBUG] Left stack buttons: \(leftStack.arrangedSubviews.count)")
        print("[DEBUG] Right stack buttons: \(rightStack.arrangedSubviews.count)")
        print("[DEBUG] TableView button frame: \(tableViewButton.frame)")
        print("[DEBUG] TableView button isHidden: \(tableViewButton.isHidden)")
        
        // Force layout update
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
    }
    
    /// Hide the custom toolbar
    func hideCSVToolbar() {
        print("[CSV TOOLBAR DEBUG] Hiding CSV toolbar")
        print("[CSV TOOLBAR DEBUG] Current toolbar view: \(toolbarView != nil ? "exists" : "nil")")
        print("[CSV TOOLBAR DEBUG] Is toolbar visible: \(isToolbarVisible)")
        
        if let toolbar = toolbarView {
            print("[CSV TOOLBAR DEBUG] Removing toolbar from superview")
            toolbar.removeFromSuperview()
        }
        
        toolbarView = nil
        isToolbarVisible = false
        
        // Make the default toolbar visible again
        print("[CSV TOOLBAR DEBUG] Main actions bar hidden state before restore: \(viewController?.actionsBar.isHidden ?? true)")
        viewController?.actionsBar.isHidden = false
        print("[CSV TOOLBAR DEBUG] Main actions bar hidden state after restore: \(viewController?.actionsBar.isHidden ?? true)")
    }
    
    /// Create a styled button exactly matching the JSON toolbar
    private func createStyledButton(systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal) // Icon only
        
        // Set icon - exactly matching JSON toolbar
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium) // Adjusted size
            let icon = UIImage(systemName: systemName, withConfiguration: config)
            button.setImage(icon, for: .normal)
            button.imageView?.contentMode = .center
            button.tintColor = DesignSystem.Colors.primary
        }
        
        // Square padding - matching JSON toolbar exactly
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.backgroundColor = DesignSystem.Colors.backgroundTertiary
        button.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        
        // Content priorities - exactly matching JSON toolbar
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return button
    }
}