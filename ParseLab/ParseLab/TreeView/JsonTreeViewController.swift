//
//  JsonTreeViewController.swift
//  ParseLab
//
//  Created by x on 4/26/25.
//

import UIKit

protocol JsonTreeViewDelegate: AnyObject {
    func jsonTreeView(didSelectNodeWithPath path: String)
}

class JsonTreeViewController: UIViewController {
    // Table view for displaying the tree
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    // Expose tableView for external configuration
    var publicTableView: UITableView { tableView }
    
    // Root node of the tree
    private var rootNode: JsonTreeNode?
    
    // All currently visible nodes (flat representation for table view)
    private var visibleNodes: [JsonTreeNode] = []
    
    // Delegate for node selection
    weak var delegate: JsonTreeViewDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add table view
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(JsonTreeNodeCell.self, forCellReuseIdentifier: "TreeNodeCell")
    }
    
    // MARK: - Public Methods
    
    // Set the JSON data for the tree view
    func setJsonData(_ json: Any) {
        // Build the tree
        rootNode = JsonTreeNode.buildTree(from: json)
        rootNode?.isExpanded = true
        
        // Update visible nodes
        updateVisibleNodes()
        
        // Reload the table view
        tableView.reloadData()
    }
    
    // Navigate to a specific path
    func navigateToPath(_ path: String) {
        guard let rootNode = rootNode else { return }
        
        // Parse the path into components
        let components = path.components(separatedBy: ".")
        
        // Start from the root node
        var currentNode: JsonTreeNode? = rootNode
        
        // Expand each node in the path
        for component in components.dropFirst() { // Skip the root component
            // Expand the current node if necessary
            currentNode?.isExpanded = true
            
            // Find the child node matching this component
            currentNode = currentNode?.children.first(where: { $0.key == component })
        }
        
        // Update visible nodes
        updateVisibleNodes()
        
        // Reload the table view
        tableView.reloadData()
        
        // Scroll to the target node if found
        if let targetNode = currentNode,
           let index = visibleNodes.firstIndex(where: { $0 === targetNode }) {
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
            
            // Highlight the cell (optional)
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? JsonTreeNodeCell {
                cell.flash()
            }
        }
    }
    
    // Expand all nodes
    func expandAll() {
        expandAllNodes(rootNode)
        updateVisibleNodes()
        tableView.reloadData()
    }
    
    // Collapse all nodes except the root
    func collapseAll() {
        collapseAllNodes(rootNode)
        rootNode?.isExpanded = true // Keep root expanded
        updateVisibleNodes()
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    
    // Update the list of visible nodes for the table view
    private func updateVisibleNodes() {
        visibleNodes = rootNode?.getVisibleNodes() ?? []
    }
    
    // Recursively expand all nodes
    private func expandAllNodes(_ node: JsonTreeNode?) {
        guard let node = node else { return }
        
        node.isExpanded = true
        
        for child in node.children {
            expandAllNodes(child)
        }
    }
    
    // Recursively collapse all nodes
    private func collapseAllNodes(_ node: JsonTreeNode?) {
        guard let node = node else { return }
        
        node.isExpanded = false
        
        for child in node.children {
            collapseAllNodes(child)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension JsonTreeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleNodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TreeNodeCell", for: indexPath) as! JsonTreeNodeCell
        
        if indexPath.row < visibleNodes.count {
            let node = visibleNodes[indexPath.row]
            cell.configure(with: node)
            
            // Set up the expand/collapse action
            cell.toggleAction = { [weak self] in
                guard let self = self else { return }
                
                // Toggle the node's expanded state
                node.toggleExpanded()
                
                // Update visible nodes and reload table
                self.updateVisibleNodes()
                tableView.reloadData()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < visibleNodes.count {
            let node = visibleNodes[indexPath.row]
            
            // If the node is expandable, toggle its expanded state
            if node.isExpandable {
                node.toggleExpanded()
                updateVisibleNodes()
                tableView.reloadData()
            }
            
            // Notify delegate of selection
            delegate?.jsonTreeView(didSelectNodeWithPath: node.path)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
}

// TreeNodeCell is now in a separate file
