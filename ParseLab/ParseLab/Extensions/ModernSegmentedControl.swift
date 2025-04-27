//
//  ModernSegmentedControl.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

/// A modern segmented control with rounded corners and material design style
class ModernSegmentedControl: UIControl {
    
    // MARK: - Properties
    
    public var buttons: [UIButton] = []
    private var selectorView: UIView!
    
    private var selectedIndex: Int = 0 {
        didSet {
            updateSelectorPosition(animated: true)
            sendActions(for: .valueChanged)
        }
    }
    
    var titles: [String] = [] {
        didSet {
            updateView()
        }
    }
    
    var buttonTitleColor: UIColor = DesignSystem.Colors.text {
        didSet {
            updateView()
        }
    }
    
    var selectorColor: UIColor = DesignSystem.Colors.primary {
        didSet {
            selectorView.backgroundColor = selectorColor
        }
    }
    
    var selectorTextColor: UIColor = .white {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    convenience init(titles: [String]) {
        self.init(frame: .zero)
        self.titles = titles
        updateView()
    }
    
    private func commonInit() {
        self.backgroundColor = DesignSystem.Colors.backgroundTertiary
        self.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        self.clipsToBounds = true
        
        // Add selector view
        selectorView = UIView(frame: .zero)
        selectorView.backgroundColor = selectorColor
        selectorView.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius - 2
        self.addSubview(selectorView)
    }
    
    // MARK: - Layout and Updates
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !buttons.isEmpty {
            let buttonWidth = self.bounds.width / CGFloat(buttons.count)
            let buttonHeight = self.bounds.height
            
            for (index, button) in buttons.enumerated() {
                button.frame = CGRect(
                    x: buttonWidth * CGFloat(index),
                    y: 0,
                    width: buttonWidth,
                    height: buttonHeight
                )
                
                // Ensure images fit properly within buttons
                button.imageView?.contentMode = .scaleAspectFit
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.titleLabel?.minimumScaleFactor = 0.8
            }
            
            updateSelectorPosition(animated: false)
        }
    }
    
    private func updateView() {
        // Remove existing buttons
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        
        // Create new buttons
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(buttonTitleColor, for: .normal)
            button.titleLabel?.font = DesignSystem.Typography.bodyMedium()
            // Add proper content insets to ensure images aren't cut off
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            self.addSubview(button)
        }
        
        // Bring selector to front
        self.bringSubviewToFront(selectorView)
        
        // Update initial selection
        updateButtonAppearance()
        setNeedsLayout()
    }
    
    private func updateSelectorPosition(animated: Bool) {
        if buttons.isEmpty { return }
        
        let buttonWidth = self.bounds.width / CGFloat(buttons.count)
        let padding: CGFloat = 4
        // Adjust selector width to account for the increased button content insets
        let horizontalInset: CGFloat = 6 // Half of the horizontal content insets we added (12/2)
        let selectorWidth = buttonWidth - (padding * 2) - (horizontalInset * 2)
        
        let targetFrame = CGRect(
            x: (buttonWidth * CGFloat(selectedIndex)) + padding + horizontalInset,
            y: padding,
            width: selectorWidth,
            height: self.bounds.height - (padding * 2)
        )
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.selectorView.frame = targetFrame
            })
        } else {
            selectorView.frame = targetFrame
        }
        
        updateButtonAppearance()
    }
    
    private func updateButtonAppearance() {
        buttons.enumerated().forEach { index, button in
            if index == selectedIndex {
                button.setTitleColor(selectorTextColor, for: .normal)
                button.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.semibold)
            } else {
                button.setTitleColor(buttonTitleColor, for: .normal)
                button.titleLabel?.font = DesignSystem.Typography.bodyMedium()
            }
        }
    }
    
    // MARK: - User Interaction
    
    @objc private func buttonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
    }
    
    // MARK: - Public Methods
    
    func setSelectedIndex(_ index: Int, animated: Bool = true) {
        guard index < buttons.count else { return }
        selectedIndex = index
        updateSelectorPosition(animated: animated)
    }
    
    var selectedSegmentIndex: Int {
        get {
            return selectedIndex
        }
        set {
            setSelectedIndex(newValue)
        }
    }
}
