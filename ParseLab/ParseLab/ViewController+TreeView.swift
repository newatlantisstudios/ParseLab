
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
        
        // Ensure tree view is properly sized
        NSLayoutConstraint.activate([
            treeViewController.view.heightAnchor.constraint(equalTo: contentStackView.heightAnchor),
            treeViewController.view.widthAnchor.constraint(equalTo: fileContentView.widthAnchor)
        ])
        
        // Create tree view control buttons
        setupTreeViewControls()
    }
    
    // Setup control buttons for tree view (expand all, collapse all)
    private func setupTreeViewControls() {
        // Create controls container
        treeViewControlsContainer = UIView()
        treeViewControlsContainer.translatesAutoresizingMaskIntoConstraints = false
        treeViewControlsContainer.backgroundColor = .systemBackground
        treeViewControlsContainer.layer.cornerRadius = 8
        treeViewControlsContainer.layer.borderWidth = 0.5
        treeViewControlsContainer.layer.borderColor = UIColor.systemGray4.cgColor
        treeViewControlsContainer.isHidden = true
        
        // Create stack view for tree controls
        let treeControlsStack = UIStackView()
        treeControlsStack.axis = .horizontal
        treeControlsStack.distribution = .fillEqually
        treeControlsStack.spacing = 8
        treeControlsStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Expand all button
        expandAllButton = UIButton(type: .system)
        expandAllButton.setTitle("Expand All", for: .normal)
        expandAllButton.setImage(UIImage(systemName: "list.bullet.indent"), for: .normal)
        expandAllButton.translatesAutoresizingMaskIntoConstraints = false
        expandAllButton.addTarget(self, action: #selector(expandAllNodes), for: .touchUpInside)
        
        // Collapse all button
        collapseAllButton = UIButton(type: .system)
        collapseAllButton.setTitle("Collapse All", for: .normal)
        collapseAllButton.setImage(UIImage(systemName: "list.bullet.outdent"), for: .normal)
        collapseAllButton.translatesAutoresizingMaskIntoConstraints = false
        collapseAllButton.addTarget(self, action: #selector(collapseAllNodes), for: .touchUpInside)
        
        // Add buttons to stack
        treeControlsStack.addArrangedSubview(expandAllButton)
        treeControlsStack.addArrangedSubview(collapseAllButton)
        
        // Add stack to container
        treeViewControlsContainer.addSubview(treeControlsStack)
        
        // Add container to view
        view.addSubview(treeViewControlsContainer)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            treeControlsStack.topAnchor.constraint(equalTo: treeViewControlsContainer.topAnchor, constant: 8),
            treeControlsStack.leadingAnchor.constraint(equalTo: treeViewControlsContainer.leadingAnchor, constant: 16),
            treeControlsStack.trailingAnchor.constraint(equalTo: treeViewControlsContainer.trailingAnchor, constant: -16),
            treeControlsStack.bottomAnchor.constraint(equalTo: treeViewControlsContainer.bottomAnchor, constant: -8),
            
            treeViewControlsContainer.topAnchor.constraint(equalTo: navigationContainerView.bottomAnchor, constant: 8),
            treeViewControlsContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            treeViewControlsContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            treeViewControlsContainer.heightAnchor.constraint(equalToConstant: 44)
        ])
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
    
    // Handle view mode segmented control changes
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
                    displayError("Error formatting JSON node: \(error.localizedDescription)")
                }
            }
        }
    }
}
