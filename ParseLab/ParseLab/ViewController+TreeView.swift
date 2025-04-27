
//
//  ViewController+TreeView.swift
//  ParseLab
//
//  Created by x on 4/26/25.
//

import UIKit

// MARK: - Tree View Integration

extension ViewController {
    
    // Setup tree view controller
    internal func setupTreeViewController() {
        treeViewController = JsonTreeViewController()
        treeViewController.delegate = self
        
        // Add tree view as a child view controller but don't show it initially
        addChild(treeViewController)
        contentStackView.addArrangedSubview(treeViewController.view)
        treeViewController.view.translatesAutoresizingMaskIntoConstraints = false
        treeViewController.didMove(toParent: self)
        treeViewController.view.isHidden = true
        
        // Ensure tree view is properly sized - wrap in async block to make sure views are in hierarchy
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Only add constraints if both views are in the view hierarchy
            if self.contentStackView.superview != nil && self.fileContentView.superview != nil {
                NSLayoutConstraint.activate([
                    self.treeViewController.view.heightAnchor.constraint(equalTo: self.contentStackView.heightAnchor),
                    self.treeViewController.view.widthAnchor.constraint(equalTo: self.fileContentView.widthAnchor)
                ])
            }
        }
        
        // Create tree view control buttons - but do it after a delay to ensure the view hierarchy is set up
        DispatchQueue.main.async { [weak self] in
            self?.setupTreeViewControls()
        }
    }
    
    // Setup control buttons for tree view (expand all, collapse all)
    private func setupTreeViewControls() {
        // Create controls container
        treeViewControlsContainer = UIView()
        treeViewControlsContainer.translatesAutoresizingMaskIntoConstraints = false
        treeViewControlsContainer.backgroundColor = DesignSystem.Colors.background
        treeViewControlsContainer.layer.cornerRadius = 10
        treeViewControlsContainer.layer.shadowColor = UIColor.black.cgColor
        treeViewControlsContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        treeViewControlsContainer.layer.shadowRadius = 3
        treeViewControlsContainer.layer.shadowOpacity = 0.2
        treeViewControlsContainer.isHidden = true
        
        // Create stack view for tree controls
        let treeControlsStack = UIStackView()
        treeControlsStack.axis = .vertical // Change to vertical layout
        treeControlsStack.distribution = .fillEqually
        treeControlsStack.spacing = 8
        treeControlsStack.alignment = .fill // Ensure buttons fill the width
        treeControlsStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Expand all button
        expandAllButton = UIButton(type: .system)
        expandAllButton.setTitle("Expand All", for: .normal)
        expandAllButton.setImage(UIImage(systemName: "list.bullet.indent"), for: .normal)
        expandAllButton.translatesAutoresizingMaskIntoConstraints = false
        expandAllButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        expandAllButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        expandAllButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 0)
        expandAllButton.titleLabel?.lineBreakMode = .byClipping
        expandAllButton.titleLabel?.adjustsFontSizeToFitWidth = false
        expandAllButton.layer.cornerRadius = 6
        expandAllButton.backgroundColor = DesignSystem.Colors.backgroundTertiary
        expandAllButton.tintColor = DesignSystem.Colors.primary
        expandAllButton.addTarget(self, action: #selector(expandAllNodes), for: .touchUpInside)
        
        // Collapse all button
        collapseAllButton = UIButton(type: .system)
        collapseAllButton.setTitle("Collapse All", for: .normal)
        collapseAllButton.setImage(UIImage(systemName: "list.bullet.outdent"), for: .normal)
        collapseAllButton.translatesAutoresizingMaskIntoConstraints = false
        collapseAllButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        collapseAllButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        collapseAllButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 0)
        collapseAllButton.titleLabel?.lineBreakMode = .byClipping
        collapseAllButton.titleLabel?.adjustsFontSizeToFitWidth = false
        collapseAllButton.layer.cornerRadius = 6
        collapseAllButton.backgroundColor = DesignSystem.Colors.backgroundTertiary
        collapseAllButton.tintColor = DesignSystem.Colors.primary
        collapseAllButton.addTarget(self, action: #selector(collapseAllNodes), for: .touchUpInside)
        
        // Add buttons to stack
        treeControlsStack.addArrangedSubview(expandAllButton)
        treeControlsStack.addArrangedSubview(collapseAllButton)
        
        // Add stack to container
        treeViewControlsContainer.addSubview(treeControlsStack)
        
        // Add container to view
        view.addSubview(treeViewControlsContainer)
        
        // Set up constraints for the stack inside the container
        NSLayoutConstraint.activate([
            treeControlsStack.topAnchor.constraint(equalTo: treeViewControlsContainer.topAnchor, constant: 10),
            treeControlsStack.leadingAnchor.constraint(equalTo: treeViewControlsContainer.leadingAnchor, constant: 10),
            treeControlsStack.trailingAnchor.constraint(equalTo: treeViewControlsContainer.trailingAnchor, constant: -10),
            treeControlsStack.bottomAnchor.constraint(equalTo: treeViewControlsContainer.bottomAnchor, constant: -10)
        ])
        
        // Set fixed height for buttons to ensure consistent sizing
        expandAllButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        collapseAllButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        // Set up constraints for the container relative to the view
        // Position controls at the bottom of the screen, aligned to the trailing edge
        NSLayoutConstraint.activate([
            treeViewControlsContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            treeViewControlsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            treeViewControlsContainer.widthAnchor.constraint(equalToConstant: 180),
            treeViewControlsContainer.heightAnchor.constraint(equalToConstant: 94) // Increased height for vertical layout
        ])
        
        // Set content hugging and compression resistance to ensure proper sizing
        treeViewControlsContainer.setContentHuggingPriority(.required, for: .horizontal)
        treeViewControlsContainer.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    // Switch between text view and tree view
    internal func switchToTreeView(_ showTree: Bool) {
        // Update UI visibility
        fileContentView.isHidden = showTree
        jsonMinimap.isHidden = showTree
        treeViewController.view.isHidden = !showTree
        treeViewControlsContainer.isHidden = !showTree
        
        // Ensure the tree view is in the view hierarchy before showing
        if showTree {
            // Make sure the tree view is in the content stack
            if treeViewController.view.superview == nil {
                contentStackView.addArrangedSubview(treeViewController.view)
            }
            
            // Force layout to update constraints
            view.layoutIfNeeded()
            
            // If switching to tree view, load the current JSON data
            if let jsonObject = currentJsonObject {
                // Update tree view with JSON data
                treeViewController.setJsonData(jsonObject)
                
                // Navigate to the currently selected path (if any)
                if currentPath.count > 1 {
                    let pathString = currentPath.joined(separator: ".")
                    treeViewController.navigateToPath(pathString)
                }
            }
        }
    }
    
    // Handle view mode segmented control changes - Marked as deprecated to avoid conflict
    @available(*, deprecated, message: "Use handleViewModeChanged instead")
    @objc internal func viewModeChanged(_ sender: UISegmentedControl) {
        guard currentJsonObject != nil else {
            sender.selectedSegmentIndex = 0 // Revert to Text view
            return
        }
        
        // Switch between text and tree view
        let showTreeView = sender.selectedSegmentIndex == 1
        switchToTreeView(showTreeView)
        
        // When switching to text view, make sure to use the current raw/formatted setting
        if !showTreeView {
            displayJsonInCurrentFormat()
        }
        
        // Show/hide raw view toggle button based on mode
        rawViewToggleButton.isHidden = showTreeView
    }
    
    // MARK: - Tree View Actions
    
    @objc internal func expandAllNodes() {
        treeViewController.expandAll()
    }
    
    @objc internal func collapseAllNodes() {
        treeViewController.collapseAll()
    }
}

// MARK: - JsonTreeViewDelegate

extension ViewController: JsonTreeViewDelegate {
    func jsonTreeView(didSelectNodeWithPath path: String) {
        // Parse the path into components
        let pathComponents = path.components(separatedBy: ".")
        
        // Update current path
        currentPath = pathComponents
        
        // Update path navigator
        jsonPathNavigator.updatePath(currentPath)
        
        // Optional: Populate the text view with the selected node's JSON
        if let jsonObject = currentJsonObject {
            // Find the node at this path
            var currentNode: Any = jsonObject
            
            // Skip the root component ($) when traversing
            for component in currentPath.dropFirst() {
                if component.hasPrefix("[") && component.hasSuffix("]") {
                    // Array index
                    let indexStr = component.dropFirst().dropLast()
                    if let index = Int(indexStr), let array = currentNode as? [Any], index < array.count {
                        currentNode = array[index]
                    } else {
                        // Invalid path
                        return
                    }
                } else {
                    // Object property
                    if let dict = currentNode as? [String: Any], let value = dict[component] {
                        currentNode = value
                    } else {
                        // Invalid path
                        return
                    }
                }
            }
            
            // Only update the text view if it's visible (tree view not active)
            if !fileContentView.isHidden {
                do {
                    // Pretty-print the node
                    let prettyData = try JSONSerialization.data(withJSONObject: currentNode, options: [.prettyPrinted, .sortedKeys])
                    if let prettyText = String(data: prettyData, encoding: .utf8) {
                        let attributedString = jsonHighlighter.highlightJSON(prettyText, font: fileContentView.font)
                        fileContentView.attributedText = attributedString
                    }
                } catch {
                    showErrorMessage("Error formatting JSON node: \(error.localizedDescription)")
                }
            }
        }
    }
}
