//
//  ViewController+UIElements.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension containing UI element declarations
extension ViewController {
    
    // MARK: - General UI Elements
    
    // Primary actions toolbar at the top
    func createActionsToolbar() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DesignSystem.Colors.backgroundSecondary
        view.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        return view
    }

    func createOpenButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Open File", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true  // Allow menu for recent files
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "folder"), for: .normal)
        }
        return button
    }
    
    func createActionsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = DesignSystem.Spacing.medium
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func createJsonActionsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = DesignSystem.Spacing.small
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true // Initially hidden
        return stackView
    }
    
    func createLoadSampleButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Load Sample", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "doc.text"), for: .normal)
        }
        return button
    }
    
    func createValidateButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Validate", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }
        return button
    }
    
    func createSearchToggleButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        }
        return button
    }
    
    func createMinimapToggleButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Minimap", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "sidebar.right"), for: .normal)
        }
        return button
    }
    
    func createViewModeSegmentedControl() -> UISegmentedControl {
        let items = ["Text", "Tree"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }

    func createFileContentView() -> UITextView {
        let textView = UITextView()
        textView.isEditable = false // Default to non-editable, will toggle when in edit mode
        textView.font = DesignSystem.Typography.code()
        textView.backgroundColor = DesignSystem.Colors.backgroundTertiary
        textView.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.contentInset = DesignSystem.Spacing.standardInsets
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }
    
    func createContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = DesignSystem.Spacing.small
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - JSON Path Navigation Elements
    
    func createJsonMinimap() -> JsonMinimap {
        let minimap = JsonMinimap()
        minimap.translatesAutoresizingMaskIntoConstraints = false
        minimap.backgroundColor = DesignSystem.Colors.backgroundSecondary
        minimap.isHidden = true // Initially hidden until JSON is loaded
        return minimap
    }
    
    func createJsonPathNavigator() -> JsonPathNavigator {
        let navigator = JsonPathNavigator()
        navigator.translatesAutoresizingMaskIntoConstraints = false
        return navigator
    }
    
    func createNavigationContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DesignSystem.Colors.backgroundSecondary
        view.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.isHidden = true // Initially hidden
        return view
    }
    
    // MARK: - Search UI Elements
    
    func createSearchContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DesignSystem.Colors.background
        view.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        view.isHidden = true // Initially hidden
        return view
    }
    
    func createSearchTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Search JSON keys and values..."
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        return textField
    }
    
    func createSearchOptionsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = DesignSystem.Spacing.small
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func createSearchKeysSwitch() -> UISwitch {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.isOn = true
        if #available(iOS 13.0, *) {
            switchControl.onTintColor = DesignSystem.Colors.primary
        }
        return switchControl
    }
    
    func createSearchKeysLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Keys"
        label.font = DesignSystem.Typography.bodyMedium()
        return label
    }
    
    func createSearchValuesSwitch() -> UISwitch {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.isOn = true
        if #available(iOS 13.0, *) {
            switchControl.onTintColor = DesignSystem.Colors.primary
        }
        return switchControl
    }
    
    func createSearchValuesLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Values"
        label.font = DesignSystem.Typography.bodyMedium()
        return label
    }
    
    func createCaseSensitiveSwitch() -> UISwitch {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.isOn = false
        if #available(iOS 13.0, *) {
            switchControl.onTintColor = DesignSystem.Colors.primary
        }
        return switchControl
    }
    
    func createCaseSensitiveLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Case Sensitive"
        label.font = DesignSystem.Typography.bodyMedium()
        return label
    }
    
    func createSearchButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Search", for: .normal)
        button.backgroundColor = DesignSystem.Colors.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        button.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.medium)
        button.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.small,
            left: DesignSystem.Spacing.medium,
            bottom: DesignSystem.Spacing.small,
            right: DesignSystem.Spacing.medium
        )
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        }
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        return button
    }
    
    func createSearchResultsTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = DesignSystem.Colors.background
        tableView.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        tableView.layer.borderWidth = 0.5
        tableView.layer.borderColor = UIColor.systemGray4.cgColor
        tableView.isHidden = true // Initially hidden
        tableView.separatorStyle = .none // Will use custom cells
        return tableView
    }
    
    func createCloseSearchButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
        button.tintColor = .systemGray
        return button
    }
}

// MARK: - UI Fixes

// Fix for buttons showing "..." text instead of ellipsis icon
extension ViewController {
    func fixEllipsisButtons() {
        // Recursively find and fix buttons showing "..." text
        func fixButtons(in view: UIView) {
            // Check if this view is a button with "..." text
            if let button = view as? UIButton, button.title(for: .normal) == "..." {
                // Apply proper styling for icon-only button
                button.setTitle("", for: .normal) // Remove text
                if #available(iOS 13.0, *) {
                    let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
                    let ellipsisIcon = UIImage(systemName: "ellipsis", withConfiguration: config)
                    button.setImage(ellipsisIcon, for: .normal)
                    button.imageView?.contentMode = .center
                    button.tintColor = DesignSystem.Colors.primary
                }
                button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                button.backgroundColor = DesignSystem.Colors.backgroundTertiary
                button.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
                
                // Try to set fixed size for proper aspect ratio if possible
                if button.translatesAutoresizingMaskIntoConstraints == false {
                    NSLayoutConstraint.activate([
                        button.widthAnchor.constraint(equalToConstant: 44),
                        button.heightAnchor.constraint(equalToConstant: 44)
                    ])
                }
                
                // Better alignment
                button.setContentHuggingPriority(.required, for: .horizontal)
                button.setContentCompressionResistancePriority(.required, for: .horizontal)
            }
            
            // Check all subviews
            for subview in view.subviews {
                fixButtons(in: subview)
            }
        }
        
        // Start recursion from the main view
        fixButtons(in: self.view)
    }
}

// MARK: - Custom Cells

class SearchResultCell: UITableViewCell {
    private let containerView = UIView()
    private let keyIconView = UIImageView()
    private let titleLabel = UILabel()
    private let pathLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        // Configure container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = DesignSystem.Colors.backgroundTertiary
        containerView.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        
        // Configure icon
        keyIconView.translatesAutoresizingMaskIntoConstraints = false
        keyIconView.contentMode = .scaleAspectFit
        keyIconView.tintColor = DesignSystem.Colors.primary
        
        // Configure labels
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = DesignSystem.Typography.bodyMedium().withWeight(.medium)
        titleLabel.textColor = DesignSystem.Colors.text
        titleLabel.numberOfLines = 1
        
        pathLabel.translatesAutoresizingMaskIntoConstraints = false
        pathLabel.font = DesignSystem.Typography.bodySmall()
        pathLabel.textColor = DesignSystem.Colors.textSecondary
        pathLabel.numberOfLines = 1
        
        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubview(keyIconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(pathLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DesignSystem.Spacing.tiny),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSystem.Spacing.small),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSystem.Spacing.small),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DesignSystem.Spacing.tiny),
            
            keyIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: DesignSystem.Spacing.small),
            keyIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            keyIconView.widthAnchor.constraint(equalToConstant: DesignSystem.Sizing.iconSize),
            keyIconView.heightAnchor.constraint(equalToConstant: DesignSystem.Sizing.iconSize),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: DesignSystem.Spacing.small),
            titleLabel.leadingAnchor.constraint(equalTo: keyIconView.trailingAnchor, constant: DesignSystem.Spacing.small),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -DesignSystem.Spacing.small),
            
            pathLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignSystem.Spacing.tiny),
            pathLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            pathLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            pathLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -DesignSystem.Spacing.small)
        ])
        
        // Remove selection styling
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    func configure(with result: JSONSearchResult) {
        titleLabel.text = result.displayText
        pathLabel.text = "Path: \(result.path)"
        
        if #available(iOS 13.0, *) {
            if result.isKey {
                keyIconView.image = UIImage(systemName: "key.fill")
            } else {
                keyIconView.image = UIImage(systemName: "doc.text.fill")
            }
        }
        
        // Add a subtle highlight effect on selection
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.1)
        self.selectedBackgroundView = selectedBackgroundView
    }
}
