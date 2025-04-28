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
        // Ensure tree view is properly sized - wrap in async block to make sure views are in hierarchy
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("[DEBUG] setupTreeViewController async block: Initializing treeViewController")
            self.treeViewController = JsonTreeViewController()
            self.treeViewController.delegate = self
            
            // Configure table view for proper dynamic sizing
            self.treeViewController.publicTableView.rowHeight = UITableView.automaticDimension
            self.treeViewController.publicTableView.estimatedRowHeight = 44
            
            print("[DEBUG] setupTreeViewController async block: treeViewController initialized: \(self.treeViewController != nil)")
            
            // Create the container view for the tree
            self.treeViewContainer = UIView()
            self.treeViewContainer.translatesAutoresizingMaskIntoConstraints = false
            self.treeViewContainer.isHidden = true // Start hidden
            self.treeViewContainer.clipsToBounds = true // Ensure tree doesn't draw outside container

            // Add the container to the stack view
            contentStackView.addArrangedSubview(self.treeViewContainer)

            // Note: We'll dynamically add the tree view controller as a child only when needed
            // rather than keeping it in the view hierarchy all the time
            
            // Create tree view control buttons - but do it after a delay to ensure the view hierarchy is set up
            DispatchQueue.main.async { [weak self] in
                self?.setupTreeViewControls()
            }
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
    @objc func switchToTreeView(animated: Bool = true) {
        isTreeViewVisible = true
        print("[DEBUG] switchToTreeView: isTreeViewVisible set to true")
        guard isViewLoaded else {
            print("[DEBUG] switchToTreeView: View not loaded yet - retrying later")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.switchToTreeView(animated: animated)
            }
            return
        }
        print("[DEBUG] switchToTreeView: Switching to tree view")
        isTreeViewVisible = true
        guard let treeVC = treeViewController, treeViewContainer != nil else {
            print("[DEBUG] switchToTreeView: Tree view controller or container missing")
            return
        }
        if let minimapWidthConstraint = minimapWidthConstraint {
            minimapWidthConstraint.isActive = false
        }
        contentStackView.arrangedSubviews.forEach { contentStackView.removeArrangedSubview($0); $0.removeFromSuperview() }
        contentStackView.addArrangedSubview(treeViewContainer)
        treeViewContainer.isHidden = false
        treeViewContainer.alpha = 1.0
        print("[DEBUG] switchToTreeView: treeViewContainer.isHidden = \(self.treeViewContainer.isHidden)")
        print("[DEBUG] switchToTreeView: contentStackView.arrangedSubviews = \(self.contentStackView.arrangedSubviews)")
        if treeVC.view.superview != treeViewContainer {
            print("[DEBUG] switchToTreeView: Adding treeViewController.view to treeViewContainer")
            treeViewContainer.addSubview(treeVC.view)
            treeVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                treeVC.view.topAnchor.constraint(equalTo: treeViewContainer.topAnchor),
                treeVC.view.leadingAnchor.constraint(equalTo: treeViewContainer.leadingAnchor),
                treeVC.view.trailingAnchor.constraint(equalTo: treeViewContainer.trailingAnchor),
                treeVC.view.bottomAnchor.constraint(equalTo: treeViewContainer.bottomAnchor)
            ])
        }
        print("[DEBUG] switchToTreeView: treeViewContainer.subviews = \(treeViewContainer.subviews)")
        contentStackView.setNeedsLayout()
        contentStackView.layoutIfNeeded()
        if treeVC.parent == nil {
            print("[DEBUG] switchToTreeView: Adding tree view controller as child")
            addChild(treeVC)
            treeViewContainer.addSubview(treeVC.view)
            treeVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                treeVC.view.topAnchor.constraint(equalTo: treeViewContainer.topAnchor),
                treeVC.view.leadingAnchor.constraint(equalTo: treeViewContainer.leadingAnchor),
                treeVC.view.trailingAnchor.constraint(equalTo: treeViewContainer.trailingAnchor),
                treeVC.view.bottomAnchor.constraint(equalTo: treeViewContainer.bottomAnchor)
            ])
            treeVC.didMove(toParent: self)
        }
        updateTreeWithCurrentJson()
        treeViewControlsContainer.isHidden = false
        let animationBlock = { [weak self] in
            guard let self = self else { return }
            self.treeViewContainer.alpha = 1
            self.fileContentView.alpha = 0
            self.navigationContainerView.isHidden = false
        }
        let completionBlock = { [weak self] (finished: Bool) in
            guard let self = self, finished, let treeVC = self.treeViewController else { return }
            self.fileContentView.isHidden = true
            self.updateModeButtonsUI(selectedMode: 1)
            if let minimapWidthConstraint = self.minimapWidthConstraint {
                minimapWidthConstraint.isActive = true
            }
            self.contentStackView.setNeedsLayout()
            self.contentStackView.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.3, animations: animationBlock, completion: completionBlock)
        } else {
            animationBlock()
            completionBlock(true)
        }
    }
    
    @objc func switchToTextView(animated: Bool = true) {
        print("[DEBUG] switchToTextView: called, isTreeViewVisible = \(isTreeViewVisible)")
        print("[DEBUG] switchToTextView: Switching to text view")
        isTreeViewVisible = false
        guard let treeVC = treeViewController else {
            print("[DEBUG] switchToTextView: Tree view controller missing")
            return
        }
        fileContentView.isHidden = false
        fileContentView.alpha = 0
        contentStackView.arrangedSubviews.forEach { contentStackView.removeArrangedSubview($0); $0.removeFromSuperview() }
        contentStackView.addArrangedSubview(fileContentView)
        fileContentView.isHidden = false
        let animationBlock = { [weak self] in
            guard let self = self else { return }
            self.treeViewContainer.alpha = 0
            self.fileContentView.alpha = 1
            self.navigationContainerView.isHidden = true
        }
        let completionBlock = { [weak self] (finished: Bool) in
            guard let self = self, finished, let treeVC = self.treeViewController else { return }
            self.treeViewControlsContainer.isHidden = true
            self.treeViewContainer.constraints.forEach { constraint in
                if constraint.firstItem === treeVC.view || constraint.secondItem === treeVC.view {
                    self.treeViewContainer.removeConstraint(constraint)
                }
            }
            treeVC.willMove(toParent: nil)
            treeVC.view.removeFromSuperview()
            treeVC.removeFromParent()
            self.treeViewContainer.isHidden = true
            self.updateModeButtonsUI(selectedMode: 0)
            self.fileContentView.isHidden = false
            self.fileContentView.alpha = 1.0
            self.view.bringSubviewToFront(self.fileContentView)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            print("[DEBUG PATCH] Forced fileContentView visible and brought to front")
            print("[DEBUG] switchToTextView completion: Frame after layout: \(self.fileContentView.frame), Hidden: \(self.fileContentView.isHidden)")
            if let minimapWidthConstraint = self.minimapWidthConstraint {
                minimapWidthConstraint.isActive = true
            }
            self.contentStackView.setNeedsLayout()
            self.contentStackView.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.3, animations: animationBlock, completion: completionBlock)
        } else {
            animationBlock()
            completionBlock(true)
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
        if showTreeView {
            switchToTreeView()
        } else {
            switchToTextView()
        }
        
        // When switching to text view, make sure to use the current raw/formatted setting
        if !showTreeView {
            displayJsonInCurrentFormat()
        }
        
        // Show/hide raw view toggle button based on mode
        rawViewToggleButton.isHidden = showTreeView
    }
    
    // MARK: - Tree View Actions
    
    @objc internal func expandAllNodes() {
        treeViewController?.expandAll()
    }
    
    @objc internal func collapseAllNodes() {
        treeViewController?.collapseAll()
    }
    
    // Update the tree view with the current JSON data
    private func updateTreeWithCurrentJson() {
        guard let treeVC = treeViewController, let jsonObject = currentJsonObject else {
            print("[DEBUG] updateTreeWithCurrentJson: No JSON data or tree view available")
            return
        }
        
        print("[DEBUG] updateTreeWithCurrentJson: Setting JSON data on tree view")
        treeVC.setJsonData(jsonObject)
        
        // Navigate to the current path if it exists
        if currentPath.count > 1 {
            let pathString = currentPath.joined(separator: ".")
            print("[DEBUG] updateTreeWithCurrentJson: Navigating to path: \(pathString)")
            treeVC.navigateToPath(pathString)
        }
    }
    
    // MARK: - Button Actions
    
    @objc func switchToTreeButtonTapped() {
        switchToTreeView()
    }
    
    @objc func switchToTextButtonTapped() {
        switchToTextView()
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
            if !isTreeViewVisible {
                do {
                    // Pretty-print the node
                    let prettyData = try JSONSerialization.data(withJSONObject: currentNode, options: [.prettyPrinted, .sortedKeys])
                    if let prettyText = String(data: prettyData, encoding: .utf8) {
                        // Fallback: assign plain text if highlight is not available
                        fileContentView.text = prettyText
                    }
                } catch {
                    showErrorMessage("Error formatting JSON node: \(error.localizedDescription)")
                }
            }
        }
    }
}
