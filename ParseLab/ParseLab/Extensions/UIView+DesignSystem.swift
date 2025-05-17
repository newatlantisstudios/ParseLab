//
//  UIView+DesignSystem.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

/// A modern design system for consistent UI throughout the app
class DesignSystem {
    // MARK: - Colors
    
    enum Colors {
        // Base colors
        static var primary: UIColor {
            return UIColor(named: "AppTheme") ?? .systemBlue
        }
        
        static var secondary: UIColor {
            return UIColor(named: "AppSecondary") ?? .systemIndigo
        }
        
        // Text colors
        static var text: UIColor {
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return UIColor { traitCollection in
                if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
                    return .white
                } else {
                    return .black
                }
            }
            }
        }
        
        static var textSecondary: UIColor {
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            } else {
                return .darkGray
            }
        }
        
        // Backgrounds
        static var background: UIColor {
            if #available(iOS 13.0, *) {
                return .systemBackground
            } else {
                return .white
            }
        }
        
        static var backgroundSecondary: UIColor {
            if #available(iOS 13.0, *) {
                return .secondarySystemBackground
            } else {
                return UIColor(white: 0.95, alpha: 1.0)
            }
        }
        
        static var backgroundTertiary: UIColor {
            if #available(iOS 13.0, *) {
                return .tertiarySystemBackground
            } else {
                return UIColor(white: 0.97, alpha: 1.0)
            }
        }
        
        // Status colors
        static var success: UIColor {
            if #available(iOS 13.0, *) {
                return .systemGreen
            } else {
                return UIColor(red: 0.30, green: 0.85, blue: 0.39, alpha: 1.0)
            }
        }
        
        static var error: UIColor {
            if #available(iOS 13.0, *) {
                return .systemRed
            } else {
                return UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
            }
        }
        
        static var warning: UIColor {
            if #available(iOS 13.0, *) {
                return .systemOrange
            } else {
                return UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0)
            }
        }
    }
    
    // MARK: - Typography
    
    enum Typography {
        // Title styles
        static func largeTitle() -> UIFont {
            return .systemFont(ofSize: 34, weight: .bold)
        }
        
        static func title1() -> UIFont {
            return .systemFont(ofSize: 28, weight: .bold)
        }
        
        static func title2() -> UIFont {
            return .systemFont(ofSize: 22, weight: .bold)
        }
        
        static func title3() -> UIFont {
            return .systemFont(ofSize: 20, weight: .semibold)
        }
        
        // Body styles
        static func bodyLarge() -> UIFont {
            return .systemFont(ofSize: 17, weight: .regular)
        }
        
        static func bodyMedium() -> UIFont {
            return .systemFont(ofSize: 15, weight: .regular)
        }
        
        static func bodySmall() -> UIFont {
            return .systemFont(ofSize: 13, weight: .regular)
        }
        
        // Code style
        static func code() -> UIFont {
            return .monospacedSystemFont(ofSize: 14, weight: .regular)
        }
        
        static func codeSmall() -> UIFont {
            return .monospacedSystemFont(ofSize: 12, weight: .regular)
        }
        
        static func codeLarge() -> UIFont {
            return .monospacedSystemFont(ofSize: 16, weight: .regular)
        }
    }
    
    // MARK: - Spacing and Sizing
    
    enum Spacing {
        // Standard spacing values
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        
        // Layout margins
        static let layoutMargin: CGFloat = 16
        
        // Insets
        static let standardInsets = UIEdgeInsets(top: medium, left: medium, bottom: medium, right: medium)
        static let compactInsets = UIEdgeInsets(top: small, left: small, bottom: small, right: small)
    }
    
    enum Sizing {
        // Standard button heights
        static let buttonHeight: CGFloat = 44
        static let smallButtonHeight: CGFloat = 36
        
        // Corner radius
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        
        // Icon sizes
        static let iconSize: CGFloat = 24
        static let smallIconSize: CGFloat = 16
        static let largeIconSize: CGFloat = 32
    }
    
    // MARK: - Shadows
    
    enum Shadow {
        // Shadow levels
        static func subtle() -> (color: CGColor, opacity: Float, offset: CGSize, radius: CGFloat) {
            return (UIColor.black.withAlphaComponent(0.1).cgColor, 1.0, CGSize(width: 0, height: 1), 2)
        }
        
        static func medium() -> (color: CGColor, opacity: Float, offset: CGSize, radius: CGFloat) {
            return (UIColor.black.withAlphaComponent(0.2).cgColor, 1.0, CGSize(width: 0, height: 2), 4)
        }
        
        static func prominent() -> (color: CGColor, opacity: Float, offset: CGSize, radius: CGFloat) {
            return (UIColor.black.withAlphaComponent(0.3).cgColor, 1.0, CGSize(width: 0, height: 4), 8)
        }
    }
}

// MARK: - UIView Extensions

extension UIView {
    // Apply a modern card styling with design system
    func applyCardStyle(cornerRadius: CGFloat = DesignSystem.Sizing.cornerRadius, shadowLevel: Int = 1) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = false
        self.backgroundColor = DesignSystem.Colors.backgroundSecondary
        
        // Apply shadow based on level
        switch shadowLevel {
        case 0: break // No shadow
        case 1:
            let shadow = DesignSystem.Shadow.subtle()
            self.layer.shadowColor = shadow.color
            self.layer.shadowOpacity = shadow.opacity
            self.layer.shadowOffset = shadow.offset
            self.layer.shadowRadius = shadow.radius
            
        case 2:
            let shadow = DesignSystem.Shadow.medium()
            self.layer.shadowColor = shadow.color
            self.layer.shadowOpacity = shadow.opacity
            self.layer.shadowOffset = shadow.offset
            self.layer.shadowRadius = shadow.radius
            
        case 3:
            let shadow = DesignSystem.Shadow.prominent()
            self.layer.shadowColor = shadow.color
            self.layer.shadowOpacity = shadow.opacity
            self.layer.shadowOffset = shadow.offset
            self.layer.shadowRadius = shadow.radius
            
        default:
            let shadow = DesignSystem.Shadow.subtle()
            self.layer.shadowColor = shadow.color
            self.layer.shadowOpacity = shadow.opacity
            self.layer.shadowOffset = shadow.offset
            self.layer.shadowRadius = shadow.radius
        }
        
        // Apply border
        self.layer.borderWidth = 0.5
        if #available(iOS 13.0, *) {
            self.layer.borderColor = UIColor.separator.cgColor
        } else {
            self.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    // Apply a container style for grouping related elements
    func applyContainerStyle() {
        applyCardStyle(shadowLevel: 0)
        self.backgroundColor = DesignSystem.Colors.backgroundTertiary
    }
    
    // Apply a floating action button style
    func applyFloatingActionButtonStyle() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.backgroundColor = DesignSystem.Colors.primary
        
        let shadow = DesignSystem.Shadow.prominent()
        self.layer.shadowColor = shadow.color
        self.layer.shadowOpacity = shadow.opacity
        self.layer.shadowOffset = shadow.offset
        self.layer.shadowRadius = shadow.radius
        
        self.clipsToBounds = false
    }
}

// MARK: - UIButton Extensions

extension UIButton {
    // Style edit button
    func applyEditButtonStyle() {
        self.backgroundColor = DesignSystem.Colors.primary
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.semibold)
        self.layer.cornerRadius = 25
        self.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.medium,
            left: DesignSystem.Spacing.large,
            bottom: DesignSystem.Spacing.medium,
            right: DesignSystem.Spacing.large
        )
        
        // Add shadow
        let shadow = DesignSystem.Shadow.prominent()
        self.layer.shadowColor = shadow.color
        self.layer.shadowOpacity = shadow.opacity
        self.layer.shadowOffset = shadow.offset
        self.layer.shadowRadius = shadow.radius
        
        self.clipsToBounds = false
        
        // Add border for extra visibility
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
        
        // Ensure image is visible if present
        if self.imageView?.image != nil {
            self.imageView?.contentMode = .scaleAspectFit
            self.imageView?.tintColor = .white
            
            // Add spacing between image and text
            if self.titleLabel?.text != nil {
                let spacing: CGFloat = 8
                self.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
                self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
                
                // Center the content
                self.contentHorizontalAlignment = .center
            }
        }
    }
    
    // Style primary button
    func applyPrimaryStyle() {
        self.backgroundColor = DesignSystem.Colors.primary
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.semibold)
        self.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        self.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.small,
            left: DesignSystem.Spacing.medium,
            bottom: DesignSystem.Spacing.small,
            right: DesignSystem.Spacing.medium
        )
        
        // Apply shadow
        let shadow = DesignSystem.Shadow.subtle()
        self.layer.shadowColor = shadow.color
        self.layer.shadowOpacity = shadow.opacity
        self.layer.shadowOffset = shadow.offset
        self.layer.shadowRadius = shadow.radius
        
        self.clipsToBounds = false
        
        // Ensure image is visible if present
        if self.imageView?.image != nil {
            self.imageView?.contentMode = .scaleAspectFit
            self.imageView?.tintColor = .white
            
            // Add spacing between image and text
            if self.titleLabel?.text != nil {
                let spacing: CGFloat = 8
                self.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
                self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
                
                // Center the content
                self.contentHorizontalAlignment = .center
            }
        }
    }
    
    // Style secondary button
    func applySecondaryStyle() {
        self.backgroundColor = DesignSystem.Colors.backgroundSecondary
        self.setTitleColor(DesignSystem.Colors.primary, for: .normal)
        self.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.semibold)
        self.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        self.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.small,
            left: DesignSystem.Spacing.medium,
            bottom: DesignSystem.Spacing.small,
            right: DesignSystem.Spacing.medium
        )
        
        // Apply border
        self.layer.borderWidth = 1
        self.layer.borderColor = DesignSystem.Colors.primary.cgColor
        
        // Apply shadow
        let shadow = DesignSystem.Shadow.subtle()
        self.layer.shadowColor = shadow.color
        self.layer.shadowOpacity = shadow.opacity
        self.layer.shadowOffset = shadow.offset
        self.layer.shadowRadius = shadow.radius
        
        self.clipsToBounds = false
        
        // Ensure image is visible if present
        if self.imageView?.image != nil {
            self.imageView?.contentMode = .scaleAspectFit
            self.imageView?.tintColor = DesignSystem.Colors.primary
            
            // Add spacing between image and text
            if self.titleLabel?.text != nil {
                let spacing: CGFloat = 8
                self.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
                self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
                
                // Center the content
                self.contentHorizontalAlignment = .center
            }
        }
    }
    
    // Style icon button
    func applyIconButtonStyle(primaryColor: Bool = false) {
        self.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.small,
            left: DesignSystem.Spacing.small,
            bottom: DesignSystem.Spacing.small,
            right: DesignSystem.Spacing.small
        )
        
        self.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        
        if primaryColor {
            self.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.1)
            self.tintColor = DesignSystem.Colors.primary
        } else {
            self.backgroundColor = DesignSystem.Colors.backgroundSecondary
            self.tintColor = DesignSystem.Colors.text
        }
    }
    
    // Style tab button
    func applyTabStyle(isSelected: Bool = false) {
        self.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.small,
            left: DesignSystem.Spacing.medium,
            bottom: DesignSystem.Spacing.small,
            right: DesignSystem.Spacing.medium
        )
        
        self.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        
        if isSelected {
            self.backgroundColor = DesignSystem.Colors.primary
            self.setTitleColor(.white, for: .normal)
            self.titleLabel?.font = DesignSystem.Typography.bodyMedium().withWeight(.semibold)
        } else {
            self.backgroundColor = DesignSystem.Colors.backgroundSecondary
            self.setTitleColor(DesignSystem.Colors.text, for: .normal)
            self.titleLabel?.font = DesignSystem.Typography.bodyMedium()
        }
    }
    
    // Apply badge style
    func applyBadgeStyle(backgroundColor: UIColor = DesignSystem.Colors.primary) {
        self.backgroundColor = backgroundColor
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = DesignSystem.Typography.bodySmall().withWeight(.semibold)
        self.layer.cornerRadius = self.bounds.height / 2
        self.contentEdgeInsets = UIEdgeInsets(
            top: DesignSystem.Spacing.tiny,
            left: DesignSystem.Spacing.small,
            bottom: DesignSystem.Spacing.tiny,
            right: DesignSystem.Spacing.small
        )
    }
}

// MARK: - Font Extension

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: self.pointSize, weight: weight)
    }
}

// MARK: - UITextField Extensions

extension UITextField {
    // Apply modern styled text field
    func applyModernStyle() {
        self.borderStyle = .none
        self.backgroundColor = DesignSystem.Colors.backgroundTertiary
        self.textColor = DesignSystem.Colors.text
        self.font = DesignSystem.Typography.bodyMedium()
        
        self.layer.cornerRadius = DesignSystem.Sizing.smallCornerRadius
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.separator.cgColor
        
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: DesignSystem.Spacing.medium, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    // Apply search field style
    func applySearchStyle() {
        applyModernStyle()
        
        // Create a search icon
        if let searchIcon = UIImage(systemName: "magnifyingglass") {
            let iconView = UIImageView(image: searchIcon)
            iconView.tintColor = DesignSystem.Colors.textSecondary
            iconView.contentMode = .scaleAspectFit
            iconView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            
            // Add padding
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 20))
            paddingView.addSubview(iconView)
            iconView.center = CGPoint(x: 20, y: 10)
            
            // Set as left view
            self.leftView = paddingView
            self.leftViewMode = .always
        }
    }
}

// MARK: - UITextView Extensions

extension UITextView {
    // Apply modern styled text view
    func applyModernStyle() {
        self.backgroundColor = DesignSystem.Colors.backgroundTertiary
        self.textColor = DesignSystem.Colors.text
        self.font = DesignSystem.Typography.bodyMedium()
        
        self.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.separator.cgColor
        
        // Add insets
        self.textContainerInset = DesignSystem.Spacing.standardInsets
    }
    
    // Apply code view style
    func applyCodeStyle() {
        self.backgroundColor = DesignSystem.Colors.backgroundTertiary
        self.textColor = DesignSystem.Colors.text
        self.font = DesignSystem.Typography.code()
        
        self.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.separator.cgColor
        
        // Add insets
        self.textContainerInset = DesignSystem.Spacing.standardInsets
        
        // Add shadow
        let shadow = DesignSystem.Shadow.subtle()
        self.layer.shadowColor = shadow.color
        self.layer.shadowOpacity = shadow.opacity
        self.layer.shadowOffset = shadow.offset
        self.layer.shadowRadius = shadow.radius
        
        self.clipsToBounds = false
    }
}

// MARK: - UILabel Extensions

extension UILabel {
    // Apply heading style
    func applyHeadingStyle(level: Int = 1) {
        switch level {
        case 1:
            self.font = DesignSystem.Typography.title1()
        case 2:
            self.font = DesignSystem.Typography.title2()
        case 3:
            self.font = DesignSystem.Typography.title3()
        default:
            self.font = DesignSystem.Typography.title3()
        }
        
        self.textColor = DesignSystem.Colors.text
    }
    
    // Apply body text style
    func applyBodyStyle(small: Bool = false) {
        if small {
            self.font = DesignSystem.Typography.bodySmall()
        } else {
            self.font = DesignSystem.Typography.bodyMedium()
        }
        
        self.textColor = DesignSystem.Colors.text
    }
    
    // Apply secondary text style
    func applySecondaryStyle(small: Bool = false) {
        if small {
            self.font = DesignSystem.Typography.bodySmall()
        } else {
            self.font = DesignSystem.Typography.bodyMedium()
        }
        
        self.textColor = DesignSystem.Colors.textSecondary
    }
    
    // Apply accent text style with primary color
    func applyAccentStyle(small: Bool = false) {
        if small {
            self.font = DesignSystem.Typography.bodySmall().withWeight(.semibold)
        } else {
            self.font = DesignSystem.Typography.bodyMedium().withWeight(.semibold)
        }
        
        self.textColor = DesignSystem.Colors.primary
    }
}

// MARK: - UITableView Extensions

extension UITableView {
    // Apply modern list style
    func applyModernStyle() {
        self.backgroundColor = DesignSystem.Colors.backgroundSecondary
        self.separatorColor = UIColor.separator.withAlphaComponent(0.5)
        self.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.separator.cgColor
        
        // Apply shadow
        let shadow = DesignSystem.Shadow.subtle()
        self.layer.shadowColor = shadow.color
        self.layer.shadowOpacity = shadow.opacity
        self.layer.shadowOffset = shadow.offset
        self.layer.shadowRadius = shadow.radius
        
        self.clipsToBounds = false
    }
}
