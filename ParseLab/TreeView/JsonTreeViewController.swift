    // Set the JSON data for the tree view
    func setJsonData(_ json: Any) {
        print("[DEBUG] JsonTreeViewController.setJsonData called") // Add log
        // Restore implementation:
        // Build the tree
        rootNode = JsonTreeNode.buildTree(from: json)
        rootNode?.isExpanded = true
        
        // Update visible nodes
        updateVisibleNodes()
        
        // Reload the table view
        tableView.reloadData()
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[DEBUG] JsonTreeViewController.viewDidLoad called") // Add log
        setupUI()
    } 