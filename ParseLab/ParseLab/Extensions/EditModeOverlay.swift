//  EditModeOverlay.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension to get parent view controller
extension UIView {
    var parentViewController: UIViewController? {
        // Traverse responder chain to find view controller
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}

/// An overlay UI that appears when editing JSON content
class EditModeOverlay: UIView, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    private let containerView = UIView()
    private let saveButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let formatButton = UIButton(type: .system)
    private let editButton = UIButton(type: .system)
    
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    var onFormat: (() -> Void)?
    var onEdit: (() -> Void)?
    
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
        // Configure self appearance
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.alpha = 0
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = DesignSystem.Colors.background
        containerView.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        
        // Apply shadow to container
        let shadow = DesignSystem.Shadow.medium()
        containerView.layer.shadowColor = shadow.color
        containerView.layer.shadowOpacity = shadow.opacity
        containerView.layer.shadowOffset = shadow.offset
        containerView.layer.shadowRadius = shadow.radius
        containerView.clipsToBounds = false
        
        // Configure save button - completely rebuilt with simpler approach
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.backgroundColor = DesignSystem.Colors.primary
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        
        // Configure text and image more directly
        if #available(iOS 13.0, *) {
            let imageAttachment = NSTextAttachment()
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            imageAttachment.image = UIImage(systemName: "checkmark", withConfiguration: config)?.withTintColor(.white)
            
            let attachmentString = NSAttributedString(attachment: imageAttachment)
            let completeString = NSMutableAttributedString(string: "")
            completeString.append(attachmentString)
            completeString.append(NSAttributedString(string: " Save"))
            
            saveButton.setAttributedTitle(completeString, for: .normal)
        } else {
            saveButton.setTitle("Save", for: .normal)
        }
        
        // Apply shadow and spacing
        let saveShadow = DesignSystem.Shadow.subtle()
        saveButton.layer.shadowColor = saveShadow.color
        saveButton.layer.shadowOpacity = saveShadow.opacity
        saveButton.layer.shadowOffset = saveShadow.offset
        saveButton.layer.shadowRadius = saveShadow.radius
        saveButton.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.small,
            left: DesignSystem.Spacing.medium,
            bottom: DesignSystem.Spacing.small,
            right: DesignSystem.Spacing.medium
        )
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Configure cancel button with the same approach
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = DesignSystem.Colors.backgroundSecondary
        cancelButton.setTitleColor(DesignSystem.Colors.primary, for: .normal)
        cancelButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = DesignSystem.Colors.primary.cgColor
        
        // Configure text and image directly
        if #available(iOS 13.0, *) {
            let imageAttachment = NSTextAttachment()
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            imageAttachment.image = UIImage(systemName: "xmark", withConfiguration: config)?.withTintColor(DesignSystem.Colors.primary)
            
            let attachmentString = NSAttributedString(attachment: imageAttachment)
            let completeString = NSMutableAttributedString(string: "")
            completeString.append(attachmentString)
            completeString.append(NSAttributedString(string: " Cancel"))
            
            cancelButton.setAttributedTitle(completeString, for: .normal)
        } else {
            cancelButton.setTitle("Cancel", for: .normal)
        }
        
        // Apply shadow and spacing
        let cancelShadow = DesignSystem.Shadow.subtle()
        cancelButton.layer.shadowColor = cancelShadow.color
        cancelButton.layer.shadowOpacity = cancelShadow.opacity
        cancelButton.layer.shadowOffset = cancelShadow.offset
        cancelButton.layer.shadowRadius = cancelShadow.radius
        cancelButton.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.small,
            left: DesignSystem.Spacing.medium,
            bottom: DesignSystem.Spacing.small,
            right: DesignSystem.Spacing.medium
        )
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        // Configure format button with the same approach
        formatButton.translatesAutoresizingMaskIntoConstraints = false
        formatButton.backgroundColor = DesignSystem.Colors.backgroundSecondary
        formatButton.setTitleColor(DesignSystem.Colors.primary, for: .normal)
        formatButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        formatButton.layer.borderWidth = 1
        formatButton.layer.borderColor = DesignSystem.Colors.primary.cgColor
        
        // Configure text and image directly
        if #available(iOS 13.0, *) {
            let imageAttachment = NSTextAttachment()
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            imageAttachment.image = UIImage(systemName: "pencil", withConfiguration: config)?.withTintColor(DesignSystem.Colors.primary)
            
            let attachmentString = NSAttributedString(attachment: imageAttachment)
            // Set button text to "Edit" as requested
            var formatButtonText = "Edit"
            
            let completeString = NSMutableAttributedString(string: "")
            completeString.append(attachmentString)
            completeString.append(NSAttributedString(string: " \(formatButtonText)"))
            
            formatButton.setAttributedTitle(completeString, for: .normal)
        } else {
            // Set button text to "Edit" as requested
            var formatButtonText = "Edit"
            
            formatButton.setTitle("Edit", for: .normal)
        }
        
        // Apply shadow and spacing
        let formatShadow = DesignSystem.Shadow.subtle()
        formatButton.layer.shadowColor = formatShadow.color
        formatButton.layer.shadowOpacity = formatShadow.opacity
        formatButton.layer.shadowOffset = formatShadow.offset
        formatButton.layer.shadowRadius = formatShadow.radius
        formatButton.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.small,
            left: DesignSystem.Spacing.medium,
            bottom: DesignSystem.Spacing.small,
            right: DesignSystem.Spacing.medium
        )
        
        formatButton.addTarget(self, action: #selector(formatButtonTapped), for: .touchUpInside)
        
        // Configure edit button with the same approach
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.backgroundColor = DesignSystem.Colors.primary
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        
        // Configure text and image directly
        if #available(iOS 13.0, *) {
            let imageAttachment = NSTextAttachment()
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            imageAttachment.image = UIImage(systemName: "pencil", withConfiguration: config)?.withTintColor(.white)
            
            let attachmentString = NSAttributedString(attachment: imageAttachment)
            let completeString = NSMutableAttributedString(string: "")
            completeString.append(attachmentString)
            completeString.append(NSAttributedString(string: " Edit"))
            
            editButton.setAttributedTitle(completeString, for: .normal)
        } else {
            editButton.setTitle("Edit", for: .normal)
        }
        
        // Apply shadow and spacing
        let editShadow = DesignSystem.Shadow.subtle()
        editButton.layer.shadowColor = editShadow.color
        editButton.layer.shadowOpacity = editShadow.opacity
        editButton.layer.shadowOffset = editShadow.offset
        editButton.layer.shadowRadius = editShadow.radius
        editButton.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.small,
            left: DesignSystem.Spacing.medium,
            bottom: DesignSystem.Spacing.small,
            right: DesignSystem.Spacing.medium
        )
        
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        
        // Add views to hierarchy
        self.addSubview(containerView)
        containerView.addSubview(saveButton)
        containerView.addSubview(cancelButton)
        containerView.addSubview(formatButton)
        containerView.addSubview(editButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -DesignSystem.Spacing.medium),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: DesignSystem.Spacing.medium),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -DesignSystem.Spacing.medium),
            
            saveButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: DesignSystem.Spacing.medium),
            saveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: DesignSystem.Spacing.medium),
            saveButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -DesignSystem.Spacing.medium),
            
            cancelButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: DesignSystem.Spacing.medium),
            cancelButton.leadingAnchor.constraint(equalTo: saveButton.trailingAnchor, constant: DesignSystem.Spacing.small),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -DesignSystem.Spacing.medium),
            
            formatButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: DesignSystem.Spacing.medium),
            formatButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: DesignSystem.Spacing.small),
            formatButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -DesignSystem.Spacing.medium),
            
            editButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: DesignSystem.Spacing.medium),
            editButton.leadingAnchor.constraint(equalTo: formatButton.trailingAnchor, constant: DesignSystem.Spacing.small),
            editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -DesignSystem.Spacing.medium),
            editButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -DesignSystem.Spacing.medium)
        ])
        
        // Add tap gesture to dismiss when tapping outside the container
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        // Make this gesture only handle taps directly on the background, not in subviews
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func saveButtonTapped() {
        onSave?()
    }
    
    @objc private func cancelButtonTapped() {
        onCancel?()
    }
    
    @objc private func formatButtonTapped() {
        onFormat?()
    }
    
    @objc private func editButtonTapped() {
        onEdit?()
    }
    
    @objc private func backgroundTapped(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if !containerView.frame.contains(location) {
            hide()
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Only handle touches directly on the background (not on container or any buttons)
        let location = touch.location(in: self)
        return !containerView.frame.contains(location)
    }
    
    // MARK: - Public Methods
    
    func show(in view: UIView) {
        // Add to view if needed
        if self.superview != view {
            // Ensure old constraints are removed to prevent conflicts
            if self.superview != nil {
                self.removeFromSuperview()
            }
            
            // Reset state before adding
            self.alpha = 0.0
            self.isUserInteractionEnabled = true
            
            // Add to view
            view.addSubview(self)
            
            // Setup constraints - use safe area when available
            if #available(iOS 11.0, *) {
                NSLayoutConstraint.activate([
                    self.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    self.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                    self.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                    self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    self.topAnchor.constraint(equalTo: view.topAnchor),
                    self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    self.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            }
            
            // Update layout immediately
            view.layoutIfNeeded()
        }
        
        // Bring to front
        view.bringSubviewToFront(self)
        
        // Show with animation
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        } completion: { _ in
            // Ensure user interaction is enabled when fully visible
            self.isUserInteractionEnabled = true
            
            // Print visible state for debugging
            print("Edit overlay visible: alpha=\(self.alpha), frame=\(self.frame)")
        }
    }
    
    func hide() {
        // Disable user interaction immediately
        self.isUserInteractionEnabled = false
        
        // Hide with animation
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }) { _ in
            if self.alpha == 0.0 {
                self.removeFromSuperview()
                print("Edit overlay removed from view")
            }
        }
    }
}
