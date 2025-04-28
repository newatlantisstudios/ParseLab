//
//  ViewController.swift
//  ParseLab
//
//  Created by x on 4/8/25.
//

import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    // Core components
    internal let jsonHighlighter = JSONHighlighter()
    internal let jsonSearcher = JSONSearcher()
    internal var currentJsonObject: Any? = nil
    
    // Path and file management
    internal var currentPath: [String] = ["$"]
    internal var currentFileUrl: URL? = nil
    internal var originalJsonContent: String? = nil
    internal var originalAttributedText: NSAttributedString? = nil
    private var textViewContentOffset: CGPoint = .zero
    private var recentFilesMenu: UIMenu?
    
    // View mode state
    internal var isRawViewMode = false
    internal var isEditMode = false
    internal var isTreeViewVisible: Bool = false
    
    // Search results
    internal var searchResults: [JSONSearchResult] = []
    internal var fileMetadataVisible: Bool = false
    
    // Add this property to track minimap toggle state
    var isMinimapVisible: Bool = false
    
    // MARK: - UI Elements
    
    // Primary UI Elements
    internal var mainToolbar: UIView = ModernToolbar()
    internal var actionsBar: ModernToolbar = ModernToolbar()
    internal var pathContainer: UIView = UIView()
    internal var editFab: UIView?
    internal var openButton: UIButton = UIButton(type: .system)
    internal var loadSampleButton: UIButton = UIButton(type: .system)
    internal var validateButton: UIButton = UIButton(type: .system)
    internal var formatJsonButton: UIButton = UIButton(type: .system)
    internal var searchToggleButton: UIButton = UIButton(type: .system)
    internal var minimapToggleButton: UIButton = UIButton(type: .system)
    internal var actionsStackView: UIStackView = UIStackView()
    internal var jsonActionsStackView: UIStackView = UIStackView()
    internal var jsonActionsToolbar: UIView = UIView()
    internal var jsonActionsSecondRowStackView: UIStackView = UIStackView()
    internal var viewModeSegmentedControl: UISegmentedControl
    internal var textModeButton: UIButton!
    internal var treeModeButton: UIButton!
    internal var fileContentView: UITextView
    internal let contentStackView: UIStackView
    
    // JSON Path Navigation
    internal let jsonPathNavigator: JsonPathNavigator
    internal var navigationContainerView: UIView
    
    // Search UI
    internal let searchContainerView: UIView
    internal let searchTextField: UITextField
    internal let searchOptionsStackView: UIStackView
    internal let searchKeysSwitch: UISwitch
    internal let searchKeysLabel: UILabel
    internal let searchValuesSwitch: UISwitch
    internal let searchValuesLabel: UILabel
    internal let caseSensitiveSwitch: UISwitch
    internal let caseSensitiveLabel: UILabel
    internal let searchButton: UIButton
    internal let searchResultsTableView: UITableView
    internal let closeSearchButton: UIButton
    
    // Edit Controls
    internal var rawViewToggleButton: UIButton!
    internal var editToggleButton: UIButton!
    internal var saveButton: UIButton!
    internal var cancelButton: UIButton!
    internal var editModeOverlay: EditModeOverlay!
    internal var tempEditTextView: UITextView? // Temporary text view for direct editing
    
    // File Metadata
    internal var fileMetadataView: FileMetadataView!
    internal var fileInfoButton: UIView!  // This can be our custom InfoButtonView
    internal var originalContentStackTopConstraint: NSLayoutConstraint?
    internal var metadataToContentConstraint: NSLayoutConstraint!
    
    // Constraints storage
    internal var fileContentViewConstraints: [NSLayoutConstraint] = []
    internal var minimapWidthConstraint: NSLayoutConstraint?
    
    // Tree View
    internal var treeViewController: JsonTreeViewController!
    internal var treeViewContainer: UIView! // New container view
    internal var treeViewControlsContainer: UIView!
    internal var expandAllButton: UIButton!
    internal var collapseAllButton: UIButton!
    
    // MARK: - Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        // Initialize UI elements using factory methods
        viewModeSegmentedControl = UISegmentedControl(items: ["Text", "Tree"])
        viewModeSegmentedControl.selectedSegmentIndex = 0
        viewModeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        fileContentView = EditableJsonTextView()
        fileContentView.isEditable = false
        fileContentView.translatesAutoresizingMaskIntoConstraints = false
        
        // We'll set up the touch delegate after super.init
        
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.spacing = 8
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        jsonPathNavigator = JsonPathNavigator()
        jsonPathNavigator.translatesAutoresizingMaskIntoConstraints = false
        
        navigationContainerView = UIView()
        navigationContainerView.translatesAutoresizingMaskIntoConstraints = false
        navigationContainerView.isHidden = true
        
        searchContainerView = UIView()
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.isHidden = true
        
        searchTextField = UITextField()
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholder = "Search JSON keys and values..."
        
        searchOptionsStackView = UIStackView()
        searchOptionsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        searchKeysSwitch = UISwitch()
        searchKeysSwitch.translatesAutoresizingMaskIntoConstraints = false
        searchKeysSwitch.isOn = true
        
        searchKeysLabel = UILabel()
        searchKeysLabel.translatesAutoresizingMaskIntoConstraints = false
        searchKeysLabel.text = "Keys"
        
        searchValuesSwitch = UISwitch()
        searchValuesSwitch.translatesAutoresizingMaskIntoConstraints = false
        searchValuesSwitch.isOn = true
        
        searchValuesLabel = UILabel()
        searchValuesLabel.translatesAutoresizingMaskIntoConstraints = false
        searchValuesLabel.text = "Values"
        
        caseSensitiveSwitch = UISwitch()
        caseSensitiveSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        caseSensitiveLabel = UILabel()
        caseSensitiveLabel.translatesAutoresizingMaskIntoConstraints = false
        caseSensitiveLabel.text = "Case Sensitive"
        
        searchButton = UIButton(type: .system)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.setTitle("Search", for: .normal)
        
        searchResultsTableView = UITableView()
        searchResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        searchResultsTableView.isHidden = true
        
        closeSearchButton = UIButton(type: .system)
        closeSearchButton.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // Set up touch delegate now that super.init has been called
        (fileContentView as? EditableJsonTextView)?.touchDelegate = self
    }
    
    required init?(coder: NSCoder) {
        // Initialize UI elements using direct initialization
        viewModeSegmentedControl = UISegmentedControl(items: ["Text", "Tree"])
        viewModeSegmentedControl.selectedSegmentIndex = 0
        viewModeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        fileContentView = EditableJsonTextView()
        fileContentView.isEditable = false
        fileContentView.translatesAutoresizingMaskIntoConstraints = false
        
        // We'll set up the touch delegate after super.init
        
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.spacing = 8
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        jsonPathNavigator = JsonPathNavigator()
        jsonPathNavigator.translatesAutoresizingMaskIntoConstraints = false
        
        navigationContainerView = UIView()
        navigationContainerView.translatesAutoresizingMaskIntoConstraints = false
        navigationContainerView.isHidden = true
        
        searchContainerView = UIView()
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.isHidden = true
        
        searchTextField = UITextField()
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholder = "Search JSON keys and values..."
        
        searchOptionsStackView = UIStackView()
        searchOptionsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        searchKeysSwitch = UISwitch()
        searchKeysSwitch.translatesAutoresizingMaskIntoConstraints = false
        searchKeysSwitch.isOn = true
        
        searchKeysLabel = UILabel()
        searchKeysLabel.translatesAutoresizingMaskIntoConstraints = false
        searchKeysLabel.text = "Keys"
        
        searchValuesSwitch = UISwitch()
        searchValuesSwitch.translatesAutoresizingMaskIntoConstraints = false
        searchValuesSwitch.isOn = true
        
        searchValuesLabel = UILabel()
        searchValuesLabel.translatesAutoresizingMaskIntoConstraints = false
        searchValuesLabel.text = "Values"
        
        caseSensitiveSwitch = UISwitch()
        caseSensitiveSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        caseSensitiveLabel = UILabel()
        caseSensitiveLabel.translatesAutoresizingMaskIntoConstraints = false
        caseSensitiveLabel.text = "Case Sensitive"
        
        searchButton = UIButton(type: .system)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.setTitle("Search", for: .normal)
        
        searchResultsTableView = UITableView()
        searchResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        searchResultsTableView.isHidden = true
        
        closeSearchButton = UIButton(type: .system)
        closeSearchButton.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(coder: coder)
        
        // Set up touch delegate now that super.init has been called
        (fileContentView as? EditableJsonTextView)?.touchDelegate = self
    }

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[LOG] ViewController: viewDidLoad START")
        
        // Set app theme color
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        // Core components initialization
        // No need to initialize jsonHighlighter and jsonSearcher again as they are non-optional constants
        
        // Set up modern UI
        print("[LOG] ViewController: viewDidLoad - Calling setupModernUI")
        setupModernUI()
        
        // Setup notifications including keyboard handling
        print("[LOG] ViewController: viewDidLoad - Calling setupNotifications")
        setupNotifications()
        
        // Initialize UI controls that might be nil
        print("[LOG] ViewController: viewDidLoad - Calling initializeControlButtons")
        initializeControlButtons()
        
        // Set up tree view controller - with dispatch to ensure previous setup is complete
        print("[LOG] ViewController: viewDidLoad - Scheduling setupTreeViewController")
        DispatchQueue.main.async {
            print("[LOG] ViewController: viewDidLoad - Dispatch START - setupTreeViewController")
            self.setupTreeViewController()
            print("[LOG] ViewController: viewDidLoad - Dispatch END - setupTreeViewController")
        }
        
        // Set up schema validation - with dispatch to ensure previous setup is complete
        print("[LOG] ViewController: viewDidLoad - Scheduling setupSchemaValidation")
        DispatchQueue.main.async {
            print("[LOG] ViewController: viewDidLoad - Dispatch START - setupSchemaValidation")
            self.setupSchemaValidation()
            print("[LOG] ViewController: viewDidLoad - Dispatch END - setupSchemaValidation")
        }
        
        // Clear text view initially and show welcome message
        print("[LOG] ViewController: viewDidLoad - Scheduling initial UI setup")
        DispatchQueue.main.async { [weak self] in
            print("[LOG] ViewController: viewDidLoad - Dispatch START - initial UI setup")
            guard let self = self else { return }
            
            // Use the enhanced welcome message
            self.fileContentView.attributedText = self.createWelcomeMessage()
            
            // Ensure layout is correctly applied at startup
            print("[LOG] ViewController: viewDidLoad - Dispatch - layoutIfNeeded")
            self.view.layoutIfNeeded()
            
            // Fix any buttons displaying "..." text instead of an icon
            print("[LOG] ViewController: viewDidLoad - Dispatch - fixEllipsisButtons")
            self.fixEllipsisButtons(in: self.view)
            
            // Replace standard text view with our bounded text view
            print("[LOG] ViewController: viewDidLoad - Dispatch - Scheduling replaceWithBoundedTextView")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                 print("[LOG] ViewController: viewDidLoad - Dispatch After - replaceWithBoundedTextView START")
                self?.replaceWithBoundedTextView()
                // After replacement, set hugging/resistance priorities
                self?.fileContentView.setContentHuggingPriority(.required, for: .vertical)
                self?.fileContentView.setContentCompressionResistancePriority(.required, for: .vertical)
                print("[DEBUG] viewDidLoad: Set vertical hugging/resistance for fileContentView")
                 print("[LOG] ViewController: viewDidLoad - Dispatch After - replaceWithBoundedTextView END")
            }
            print("[LOG] ViewController: viewDidLoad - Dispatch END - initial UI setup")
        }
        print("[LOG] ViewController: viewDidLoad END")
    }
    
    // Fix buttons displaying ellipsis text instead of proper icon
    internal func fixEllipsisButtons(in view: UIView) {
        // Check if this view is a button with "..." text
        if let button = view as? UIButton {
            if button.title(for: .normal) == "..." || button.title(for: .normal)?.contains("...") == true {
                // Replace the text with an icon
                button.setTitle("", for: .normal) // Remove text
                if #available(iOS 13.0, *) {
                    button.setImage(UIImage(systemName: "info.circle"), for: .normal)
                    button.tintColor = .systemBlue
                }
                // Add proper padding
                button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                
                // Log that we fixed a button
                print("Fixed an ellipsis button")
            }
        }
        
        // Recursively check all subviews
        for subview in view.subviews {
            fixEllipsisButtons(in: subview)
        }
    }
    
    // Initialize controls that might be nil
    private func initializeControlButtons() {
        // Create raw view toggle button if it doesn't exist
        if rawViewToggleButton == nil {
            rawViewToggleButton = UIButton(type: .system)
            rawViewToggleButton.setTitle("Raw", for: .normal)
            rawViewToggleButton.translatesAutoresizingMaskIntoConstraints = false
            rawViewToggleButton.addTarget(self, action: #selector(toggleRawView), for: .touchUpInside)
            jsonActionsStackView.addArrangedSubview(rawViewToggleButton)
        }
        
        // Create edit toggle button if it doesn't exist
        if editToggleButton == nil {
            editToggleButton = UIButton(type: .system)
            editToggleButton.setTitle("Edit", for: .normal)
            editToggleButton.translatesAutoresizingMaskIntoConstraints = false
            editToggleButton.addTarget(self, action: #selector(toggleEditMode), for: .touchUpInside)
            jsonActionsStackView.addArrangedSubview(editToggleButton)
        }
        
        // Create save button if it doesn't exist
        if saveButton == nil {
            saveButton = UIButton(type: .system)
            saveButton.setTitle("Save", for: .normal)
            saveButton.translatesAutoresizingMaskIntoConstraints = false
            saveButton.addTarget(self, action: #selector(saveJsonChanges), for: .touchUpInside)
            saveButton.isHidden = true
            jsonActionsStackView.addArrangedSubview(saveButton)
        }
        
        // Create cancel button if it doesn't exist
        if cancelButton == nil {
            cancelButton = UIButton(type: .system)
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.addTarget(self, action: #selector(cancelEditing), for: .touchUpInside)
            cancelButton.isHidden = true
            jsonActionsStackView.addArrangedSubview(cancelButton)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // Check if text mode is active (vs tree view)
    internal func isTextModeActive() -> Bool {
        // Based on the viewModeSegmentedControl selection
        return viewModeSegmentedControl.selectedSegmentIndex == 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[LOG] ViewController: viewWillAppear START")
        
        // Ensure the navigation container and actions bar are hidden initially -> REMOVED unwanted hiding
        print("[LOG] ViewController: viewWillAppear - Checking initial UI state (should be handled by updateUIVisibility)")
        // pathContainer.isHidden = true // REMOVED: Visibility handled by updateUIVisibilityForJsonLoaded
        // actionsBar.isHidden = true // REMOVED: Visibility handled by updateUIVisibilityForJsonLoaded
        searchContainerView.isHidden = true // Keep search hidden initially
        searchResultsTableView.isHidden = true // Keep search hidden initially
        if let editFab = self.editFab {
            editFab.isHidden = true // Keep editFab hidden initially if not loaded
        }
        
        // Force layout update to fix any spacing issues
        print("[LOG] ViewController: viewWillAppear - layoutIfNeeded")
        view.layoutIfNeeded()
        print("[LOG] ViewController: viewWillAppear END")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("[LOG] ViewController: viewDidAppear START")
        
        // Ensure any ellipsis buttons are fixed after the view fully appears
        print("[LOG] ViewController: viewDidAppear - Scheduling final UI fixes")
        DispatchQueue.main.async { [weak self] in
            print("[LOG] ViewController: viewDidAppear - Dispatch START - final UI fixes")
            guard let self = self else { return }
            
            // Fix any buttons with "..." text
            print("[LOG] ViewController: viewDidAppear - Dispatch - fixEllipsisButtons")
            self.fixEllipsisButtons(in: self.view)
            
            // Fix any layout constraint issues
            // print("[LOG] ViewController: viewDidAppear - Dispatch - fixAllConstraintIssues")
            // self.view.fixAllConstraintIssues() // DISABLED: Causes toolbar layout issues
            
            // Instead of manually setting visibility, call the central update function
            print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from ViewController.swift (viewDidAppear), isLoaded: \(self.currentJsonObject != nil)")
            self.updateUIVisibilityForJsonLoaded(self.currentJsonObject != nil)
            
            // Explicitly ensure mainToolbar is always visible and frontmost
            self.mainToolbar.isHidden = false
            self.view.bringSubviewToFront(self.mainToolbar)
            
            print("[LOG] ViewController: viewDidAppear - Dispatch END - final UI fixes")
        }
        print("[LOG] ViewController: viewDidAppear END")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update text container width to fix JSON overflow issues
        updateTextContainerWidth()
        
        // Ensure toolbar buttons remain visible after layout changes
        if let toolbar = self.mainToolbar as? SimpleTwoButtonToolbar {
            toolbar.leftButton.isHidden = false
            toolbar.rightButton.isHidden = false
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "ParseLab" // More generic title
        
        // Set app theme color
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            navigationController?.navigationBar.tintColor = UIColor(named: "AppTheme")
        } else {
            view.backgroundColor = .white
        }
        
        // Initialize UI components that were missing
        actionsStackView = UIStackView()
        actionsStackView.axis = .horizontal
        actionsStackView.distribution = .fillProportionally
        actionsStackView.spacing = 16
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        jsonActionsStackView = UIStackView()
        jsonActionsStackView.axis = .horizontal
        jsonActionsStackView.distribution = .fillProportionally
        jsonActionsStackView.spacing = 16
        jsonActionsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        jsonActionsToolbar = UIView()
        jsonActionsToolbar.translatesAutoresizingMaskIntoConstraints = false
        jsonActionsToolbar.applyCardStyle()
        jsonActionsToolbar.isHidden = true // Initially hidden
        
        jsonActionsSecondRowStackView = UIStackView()
        jsonActionsSecondRowStackView.axis = .horizontal
        jsonActionsSecondRowStackView.distribution = .fillProportionally
        jsonActionsSecondRowStackView.spacing = 16
        jsonActionsSecondRowStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up all UI components
        setupUIComponents()
        
        // Set up the Recent Files menu
        updateRecentFilesMenu()
        
        // Set up the editing controls
        setupEditControls()

        // Ensure the view extends under the navigation bar and status bar
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        
        // Add toolbar for main actions
        mainToolbar.applyCardStyle()
        mainToolbar.backgroundColor = .secondarySystemBackground
        view.addSubview(mainToolbar)

        // Setup action buttons at the top
        actionsStackView.addArrangedSubview(openButton)
        actionsStackView.addArrangedSubview(loadSampleButton)
        view.addSubview(actionsStackView)
        mainToolbar.addSubview(actionsStackView)
        
        // Add the JSON actions toolbar to the view
        view.addSubview(jsonActionsToolbar)
        jsonActionsToolbar.addSubview(jsonActionsSecondRowStackView)
        
        // Add first row JSON-specific controls
        jsonActionsStackView.addArrangedSubview(validateButton)
        
        // Add second row JSON-specific controls
        jsonActionsSecondRowStackView.addArrangedSubview(searchToggleButton)
        jsonActionsSecondRowStackView.addArrangedSubview(minimapToggleButton)
        jsonActionsSecondRowStackView.addArrangedSubview(viewModeSegmentedControl)
        
        // Setup the raw view toggle
        setupRawViewToggle()
        
        // Set minimum width for jsonActionsStackView to prevent truncation
        jsonActionsStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: view.bounds.width * 0.8).isActive = true
        
        // Set minimum width for jsonActionsSecondRowStackView to prevent truncation
        jsonActionsSecondRowStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: view.bounds.width * 0.8).isActive = true
        
        view.addSubview(searchContainerView)
        view.addSubview(searchResultsTableView)
        
        // Set up navigation container with breadcrumbs
        navigationContainerView.addSubview(jsonPathNavigator)
        view.addSubview(navigationContainerView)
        
        // Set up content stack view with text view and minimap
        contentStackView.addArrangedSubview(fileContentView)
        view.addSubview(contentStackView)

        let layoutGuide = view.safeAreaLayoutGuide

        // Create and store a variable for content stack view's top constraint
        let contentStackTopConstraint = contentStackView.topAnchor.constraint(equalTo: navigationContainerView.bottomAnchor, constant: 16)
        
        // Store the constraint for later use with file metadata view
        self.originalContentStackTopConstraint = contentStackTopConstraint
        
        NSLayoutConstraint.activate([
            // Main actions toolbar
            mainToolbar.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 16),
            mainToolbar.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
            mainToolbar.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16),
            mainToolbar.heightAnchor.constraint(equalToConstant: 60),
            
            // Actions stack view inside toolbar
            actionsStackView.topAnchor.constraint(equalTo: mainToolbar.topAnchor, constant: 8),
            actionsStackView.leadingAnchor.constraint(equalTo: mainToolbar.leadingAnchor, constant: 16),
            actionsStackView.trailingAnchor.constraint(equalTo: mainToolbar.trailingAnchor, constant: -16),
            actionsStackView.bottomAnchor.constraint(equalTo: mainToolbar.bottomAnchor, constant: -8),
            
            // JSON actions toolbar
            jsonActionsStackView.topAnchor.constraint(equalTo: mainToolbar.bottomAnchor, constant: 16),
            jsonActionsStackView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            
            // Second row JSON actions inside toolbar
            jsonActionsToolbar.topAnchor.constraint(equalTo: jsonActionsStackView.bottomAnchor, constant: 16),
            jsonActionsToolbar.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
            jsonActionsToolbar.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16),
            jsonActionsToolbar.heightAnchor.constraint(equalToConstant: 60),
            
            jsonActionsSecondRowStackView.topAnchor.constraint(equalTo: jsonActionsToolbar.topAnchor, constant: 8),
            jsonActionsSecondRowStackView.leadingAnchor.constraint(equalTo: jsonActionsToolbar.leadingAnchor, constant: 16),
            jsonActionsSecondRowStackView.trailingAnchor.constraint(equalTo: jsonActionsToolbar.trailingAnchor, constant: -16),
            jsonActionsSecondRowStackView.bottomAnchor.constraint(equalTo: jsonActionsToolbar.bottomAnchor, constant: -8),
            
            navigationContainerView.topAnchor.constraint(equalTo: jsonActionsToolbar.bottomAnchor, constant: 16),
            navigationContainerView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
            navigationContainerView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16),
            navigationContainerView.heightAnchor.constraint(equalToConstant: 44),
            
            // Search container basic position
            searchContainerView.topAnchor.constraint(equalTo: navigationContainerView.topAnchor),
            searchContainerView.leadingAnchor.constraint(equalTo: navigationContainerView.leadingAnchor),
            searchContainerView.trailingAnchor.constraint(equalTo: navigationContainerView.trailingAnchor),
            
            // Search results table view
            searchResultsTableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 12),
            searchResultsTableView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
            searchResultsTableView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16),
            searchResultsTableView.heightAnchor.constraint(equalToConstant: 300),  // Increased height
            
            jsonPathNavigator.topAnchor.constraint(equalTo: navigationContainerView.topAnchor),
            jsonPathNavigator.leadingAnchor.constraint(equalTo: navigationContainerView.leadingAnchor),
            jsonPathNavigator.trailingAnchor.constraint(equalTo: navigationContainerView.trailingAnchor),
            jsonPathNavigator.bottomAnchor.constraint(equalTo: navigationContainerView.bottomAnchor),
            
            // Use the stored constraint for content stack view's top anchor
            contentStackTopConstraint,
            contentStackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -16),
            
            // REMOVED: Explicit width constraint for minimap
            // jsonMinimap.widthAnchor.constraint(equalToConstant: 100)  // Increased width for better visibility
        ])

        // Setup button targets
        setupButtonActions()
        
        // Setup search UI
        setupSearchUI()
        
        // Set up search results table view
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
        
        // Set up navigation callbacks
        jsonPathNavigator.onPathSelected = { [weak self] index in
            guard let self = self, index < self.currentPath.count else { return }
            // Truncate the path to the selected index
            let newPath = Array(self.currentPath.prefix(index + 1))
            self.navigateToPath(newPath)
        }
        
        // Show/hide the JSON actions toolbar
        for subview in view.subviews {
            if let toolbar = subview as? UIView, toolbar != mainToolbar && toolbar != jsonActionsStackView && toolbar != actionsStackView && toolbar != contentStackView {
                // This is the JSON actions toolbar
                toolbar.isHidden = true
            }
        }
        
        // Set up scroll observation for minimap updates
        fileContentView.delegate = self
        
        // Set initial layout based on current size class
        updateLayoutForSizeClass()
    }

    // MARK: - Search Button Actions
    
    @objc private func searchButtonTapped() {
        // Use the disambiguated handler from ViewControllerEventHandlers.swift
        handleSearchButtonTapped()
    }
}

// MARK: - UITextViewDelegate for Minimap Updates and Editing

extension ViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === fileContentView {
            // Store current offset
            textViewContentOffset = scrollView.contentOffset
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // When editing begins, make sure edit mode is enabled
        if !isEditMode && textView === fileContentView {
            isEditMode = true
            updateUIForEditMode()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Real-time validation could be added here
        // For now, we'll just update the text view
    }
}

// MARK: - UITextFieldDelegate for Search

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            performSearch(searchButton)
            return true
        }
        return true
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource for Search Results

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    // cellForRowAt is defined in ViewController+SearchUI.swift
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get the selected result and navigate to its path
        let result = searchResults[indexPath.row]
        navigateToJsonPath(result.path)
        
        // Hide search UI after navigation
        searchContainerView.isHidden = true
        searchResultsTableView.isHidden = true
        navigationContainerView.isHidden = false
    }
}
