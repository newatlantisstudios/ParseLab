//
//  SearchResultCell.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Custom cell class for search results
// Renamed to avoid potential conflict with previous declarations
class SearchResultCellImpl: UITableViewCell {
    
    private let resultLabel = UILabel()
    private let pathLabel = UILabel()
    private let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Configure container view with card-like style
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = DesignSystem.Colors.backgroundSecondary
        containerView.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        
        // Configure result label
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.font = DesignSystem.Typography.bodyMedium().withWeight(.semibold)
        resultLabel.textColor = DesignSystem.Colors.text
        resultLabel.numberOfLines = 1
        
        // Configure path label
        pathLabel.translatesAutoresizingMaskIntoConstraints = false
        pathLabel.font = DesignSystem.Typography.bodySmall()
        pathLabel.textColor = DesignSystem.Colors.textSecondary
        pathLabel.numberOfLines = 1
        
        // Add to view hierarchy
        containerView.addSubview(resultLabel)
        containerView.addSubview(pathLabel)
        contentView.addSubview(containerView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            resultLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            resultLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            resultLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            pathLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 4),
            pathLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            pathLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            pathLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        // Remove default selection style
        selectionStyle = .none
    }
    
    // Configure the cell with a search result
    func configure(with result: JSONSearchResult) {
        // Set result text based on whether it's a key or value
        if result.isKey {
            let key = result.keyPath.last ?? ""
            resultLabel.text = "Key: \(key)"
        } else {
            // Format the value appropriately
            let valueText: String
            if let stringValue = result.value as? String {
                valueText = "\"\(stringValue)\""
            } else {
                valueText = "\(result.value)"
            }
            resultLabel.text = "Value: \(valueText)"
        }
        
        // Set path
        pathLabel.text = "Path: \(result.path)"
    }
}
