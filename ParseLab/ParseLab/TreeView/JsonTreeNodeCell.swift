
//
//  JsonTreeNodeCell.swift
//  ParseLab
//
//  Created by x on 4/26/25.
//

import UIKit

// MARK: - Tree Node Cell

class JsonTreeNodeCell: UITableViewCell {
    // UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .systemGray
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return button
    }()
    
    private let nodeIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    private let keyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // Node data
    private var node: JsonTreeNode?
    
    // Expand/collapse action
    var toggleAction: (() -> Void)?
    
    // Store constraints that need to be updated on reuse
    private var expandButtonLeadingConstraint: NSLayoutConstraint?
    private var nodeIconLeadingConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(expandButton)
        containerView.addSubview(nodeIconView)
        containerView.addSubview(keyLabel)
        containerView.addSubview(valueLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            expandButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            expandButton.widthAnchor.constraint(equalToConstant: 24),
            expandButton.heightAnchor.constraint(equalToConstant: 24),
            
            nodeIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nodeIconView.widthAnchor.constraint(equalToConstant: 20),
            nodeIconView.heightAnchor.constraint(equalToConstant: 20),
            
            keyLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            keyLabel.leadingAnchor.constraint(equalTo: nodeIconView.trailingAnchor, constant: 4),
            
            valueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -8)
        ])
        
        // Create initial leading constraints (will be updated in configure)
        expandButtonLeadingConstraint = expandButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0)
        expandButtonLeadingConstraint?.isActive = true
        
        nodeIconLeadingConstraint = nodeIconView.leadingAnchor.constraint(equalTo: expandButton.trailingAnchor, constant: 4)
        nodeIconLeadingConstraint?.isActive = true
        
        // Set up expand button action
        expandButton.addTarget(self, action: #selector(expandButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    
    func configure(with node: JsonTreeNode) {
        self.node = node
        
        // Update indentation based on node level (update existing constraint)
        expandButtonLeadingConstraint?.constant = CGFloat(node.level) * 20
        
        // Update expand button appearance
        if node.isExpandable {
            expandButton.isHidden = false
            expandButton.setImage(UIImage(systemName: node.isExpanded ? "chevron.down" : "chevron.right"), for: .normal)
        } else {
            expandButton.isHidden = true
        }
        
        // Set node icon based on type
        let iconName: String
        let iconColor: UIColor
        
        switch node.type {
        case .object:
            iconName = "curlybraces"
            iconColor = .systemBlue
        case .array:
            iconName = "list.bullet"
            iconColor = .systemGreen
        case .string:
            iconName = "text.quote"
            iconColor = .systemOrange
        case .number:
            iconName = "number"
            iconColor = .systemPurple
        case .boolean:
            iconName = "checkmark.circle"
            iconColor = .systemYellow
        case .null:
            iconName = "xmark.circle"
            iconColor = .systemGray
        }
        
        nodeIconView.image = UIImage(systemName: iconName)
        nodeIconView.tintColor = iconColor
        
        // Set key label
        keyLabel.text = node.displayName()
        
        // Set value preview (for non-container types)
        if node.type == .object || node.type == .array {
            valueLabel.text = node.preview
        } else {
            valueLabel.text = node.preview
        }
        
        // Apply styling based on node type
        switch node.type {
        case .object, .array:
            keyLabel.font = .systemFont(ofSize: 14, weight: .medium)
        default:
            keyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        }
    }
    
    // MARK: - Actions
    
    @objc private func expandButtonTapped() {
        toggleAction?()
    }
    
    // Flash the cell background (for highlighting during navigation)
    func flash() {
        let originalColor = backgroundColor
        UIView.animate(withDuration: 0.15, animations: {
            self.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        }) { _ in
            UIView.animate(withDuration: 0.15, animations: {
                self.backgroundColor = originalColor
            })
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset state but don't remove constraints
        // Just reset UI elements to default state
        node = nil
        toggleAction = nil
        expandButton.isHidden = false
        expandButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        keyLabel.text = nil
        valueLabel.text = nil
    }
}
