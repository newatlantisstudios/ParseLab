//
//  JsonPathNavigatorModern.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

class JsonPathNavigatorModern: UIView {
    
    // MARK: - Properties
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var pathComponents: [String] = [] {
        didSet {
            updatePathComponents()
        }
    }
    
    var onPathSelected: ((Int) -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.addSubview(scrollView)
        
        // Configure stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        scrollView.addSubview(stackView)
        
        // Set constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    // MARK: - Path Management
    
    func setPath(_ path: [String]) {
        pathComponents = path
    }
    
    private func updatePathComponents() {
        // Remove existing path components
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new path components
        for (index, component) in pathComponents.enumerated() {
            // Add path component button
            let chip = createPathChip(component, index: index)
            stackView.addArrangedSubview(chip)
            
            // Add separator if not the last component
            if index < pathComponents.count - 1 {
                let separator = createSeparator()
                stackView.addArrangedSubview(separator)
            }
        }
        
        // Scroll to end to show latest component
        DispatchQueue.main.async {
            self.scrollView.scrollRectToVisible(CGRect(
                x: self.scrollView.contentSize.width - 1,
                y: 0,
                width: 1,
                height: 1
            ), animated: false)
        }
    }
    
    private func createPathChip(_ title: String, index: Int) -> UIView {
        // Create container
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Create button
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = DesignSystem.Typography.bodyMedium()
        button.setTitleColor(DesignSystem.Colors.primary, for: .normal)
        button.tag = index
        button.addTarget(self, action: #selector(pathComponentTapped(_:)), for: .touchUpInside)
        
        // Add background for last component
        if index == pathComponents.count - 1 {
            button.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.1)
            button.layer.cornerRadius = 8
            button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
            button.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.medium)
        } else {
            button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        }
        
        // Add button to container
        container.addSubview(button)
        
        // Set constraints
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    private func createSeparator() -> UIView {
        // Create separator
        let separatorContainer = UIView()
        separatorContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let separator = UIImageView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            separator.image = UIImage(systemName: "chevron.right")
            separator.tintColor = DesignSystem.Colors.textSecondary
        }
        separator.contentMode = .scaleAspectFit
        
        separatorContainer.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.centerYAnchor.constraint(equalTo: separatorContainer.centerYAnchor),
            separator.centerXAnchor.constraint(equalTo: separatorContainer.centerXAnchor),
            separator.widthAnchor.constraint(equalToConstant: 12),
            separator.heightAnchor.constraint(equalToConstant: 12),
            separatorContainer.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        return separatorContainer
    }
    
    // Properly configure any info button to use the correct icon instead of "..."
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // Find any buttons with ellipsis text and fix them
        fixEllipsisButtons()
    }
    
    private func fixEllipsisButtons() {
        // Scan recursively through all subviews
        for view in self.subviews {
            if let button = view as? UIButton, button.title(for: .normal) == "..." || button.title(for: .normal)?.contains("...") == true {
                // Replace the text with an info icon
                button.setTitle("", for: .normal)
                if #available(iOS 13.0, *) {
                    button.setImage(UIImage(systemName: "info.circle"), for: .normal)
                    button.tintColor = DesignSystem.Colors.primary
                }
                // Add proper padding
                button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            }
            
            // Check button subviews recursively
            scanSubviews(view)
        }
    }
    
    private func scanSubviews(_ view: UIView) {
        for subview in view.subviews {
            if let button = subview as? UIButton, button.title(for: .normal) == "..." || button.title(for: .normal)?.contains("...") == true {
                // Replace the text with an info icon
                button.setTitle("", for: .normal) 
                if #available(iOS 13.0, *) {
                    button.setImage(UIImage(systemName: "info.circle"), for: .normal)
                    button.tintColor = DesignSystem.Colors.primary
                }
                // Add proper padding
                button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            }
            
            // Continue scanning recursively
            scanSubviews(subview)
        }
    }
    
    // MARK: - Actions
    
    @objc private func pathComponentTapped(_ sender: UIButton) {
        onPathSelected?(sender.tag)
    }
}
