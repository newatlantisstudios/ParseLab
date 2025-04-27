//
//  JsonPathNavigator.swift
//  ParseLab
//
//  Created by x on 4/25/25.
//

import UIKit

class JsonPathNavigator: UIView {
    // The current navigation path
    private var currentPath: [String] = []
    
    // Callback for when a breadcrumb is tapped
    var onPathSelected: ((Int) -> Void)?
    
    // Container for the breadcrumb buttons
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = true
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // Stack view to hold the breadcrumb buttons
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        // Set minimum height that can fit in the container
        heightAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
        
        // Add the root path
        updatePath(["$"])
    }
    
    // MARK: - Public Methods
    
    // Set the navigation path (alias for updatePath)
    func setPath(_ path: [String]) {
        updatePath(path)
    }
    
    // Fix ellipsis buttons when view is added to superview
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // Delay the fix to ensure all subviews are added
        DispatchQueue.main.async { [weak self] in
            self?.fixEllipsisButtons()
        }
    }
    
    // Fix any buttons with "..." text
    private func fixEllipsisButtons() {
        for view in self.subviews {
            checkAndFixEllipsisButtons(in: view)
        }
    }
    
    // Recursively check and fix buttons
    private func checkAndFixEllipsisButtons(in view: UIView) {
        if let button = view as? UIButton {
            if button.title(for: .normal) == "..." || button.title(for: .normal)?.contains("...") == true {
                // Replace text with icon
                button.setTitle("", for: .normal)
                if #available(iOS 13.0, *) {
                    button.setImage(UIImage(systemName: "info.circle"), for: .normal)
                    button.tintColor = .systemBlue
                }
                button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            }
        }
        
        // Check subviews recursively
        for subview in view.subviews {
            checkAndFixEllipsisButtons(in: subview)
        }
    }
    
    // Update the navigation path
    func updatePath(_ path: [String]) {
        // Store the current path
        currentPath = path
        
        // Clear existing buttons
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add root button
        addPathButton(title: "Root", index: 0)
        
        // Add buttons for each path segment, skipping the first one which is the root
        for i in 1..<path.count {
            // Add separator
            addSeparator()
            
            // Create the title with appropriate formatting
            let title = path[i]
            addPathButton(title: title, index: i)
        }
        
        // Scroll to the end to show the current location
        DispatchQueue.main.async {
            self.scrollToEnd()
        }
    }
    
    // Reset the path to make sure it's visible
    func resetPath(_ path: [String]) {
        print("Resetting JSON path navigation: \(path)")
        
        // Only update if the path has changed
        if self.currentPath != path {
            updatePath(path)
        }
        
        // Critical: Ensure visibility of this view and its parent containers
        self.isHidden = false
        if let superview = self.superview {
            superview.isHidden = false
            
            // Important: Ensure this view is positioned properly within its parent
            if let viewController = findViewController() as? ViewController {
                // Make sure we're in the path container
                if self.superview != viewController.pathContainer {
                    viewController.pathContainer.addSubview(self)
                    
                    // Setup proper constraints
                    self.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        self.topAnchor.constraint(equalTo: viewController.pathContainer.topAnchor),
                        self.leadingAnchor.constraint(equalTo: viewController.pathContainer.leadingAnchor),
                        self.trailingAnchor.constraint(equalTo: viewController.pathContainer.trailingAnchor),
                        self.bottomAnchor.constraint(equalTo: viewController.pathContainer.bottomAnchor)
                    ])
                }
                
                // Make sure the path container is properly positioned
                if let toolbar = viewController.view.subviews.first(where: { $0.accessibilityIdentifier == "mainToolbar" }) {
                    // Check if top constraint exists and is correct
                    let hasCorrectTopConstraint = viewController.pathContainer.constraints.contains { constraint in
                        if constraint.firstAttribute == .top,
                           let secondItem = constraint.secondItem as? UIView,
                           secondItem == toolbar {
                            return true
                        }
                        return false
                    }
                    
                    // If not correct, fix it
                    if !hasCorrectTopConstraint {
                        // Remove any existing top constraints
                        viewController.pathContainer.constraints.filter { $0.firstAttribute == .top }.forEach { $0.isActive = false }
                        
                        // Add the correct constraint
                        NSLayoutConstraint.activate([
                            viewController.pathContainer.topAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: 8)
                        ])
                    }
                }
                
                // Ensure proper visibility in view hierarchy
                viewController.view.bringSubviewToFront(viewController.pathContainer)
                viewController.pathContainer.bringSubviewToFront(self)
                
                // Force layout update
                viewController.view.setNeedsLayout()
                viewController.view.layoutIfNeeded()
            }
        }
        
        // Scroll to end to show current location
        DispatchQueue.main.async {
            self.scrollToEnd()
        }
    }
    
    // Helper to find parent view controller
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
    // MARK: - Private Helper Methods
    
    private func addPathButton(title: String, index: Int) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: index == currentPath.count - 1 ? .semibold : .regular)
        button.setTitleColor(index == currentPath.count - 1 ? .label : .secondaryLabel, for: .normal)
        button.tag = index
        button.addTarget(self, action: #selector(pathButtonTapped(_:)), for: .touchUpInside)
        
        // Add button padding
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        
        // Add button background and corner radius for current item
        if index == currentPath.count - 1 {
            button.backgroundColor = .systemGray5
            button.layer.cornerRadius = 12
        }
        
        stackView.addArrangedSubview(button)
    }
    
    private func addSeparator() {
        let separatorLabel = UILabel()
        separatorLabel.text = "›"
        separatorLabel.textColor = .tertiaryLabel
        separatorLabel.font = .systemFont(ofSize: 14, weight: .light)
        separatorLabel.setContentHuggingPriority(.required, for: .horizontal)
        stackView.addArrangedSubview(separatorLabel)
    }
    
    @objc private func pathButtonTapped(_ sender: UIButton) {
        // Notify listener that a path was selected
        onPathSelected?(sender.tag)
    }
    
    private func scrollToEnd() {
        let contentWidth = stackView.frame.width
        let scrollViewWidth = scrollView.frame.width
        
        if contentWidth > scrollViewWidth {
            let rightOffset = CGPoint(x: contentWidth - scrollViewWidth, y: 0)
            scrollView.setContentOffset(rightOffset, animated: true)
        }
    }
}
