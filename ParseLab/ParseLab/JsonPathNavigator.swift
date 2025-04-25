
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
        
        // Set minimum height
        heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
        // Add the root path
        updatePath(["$"])
    }
    
    // MARK: - Public Methods
    
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
