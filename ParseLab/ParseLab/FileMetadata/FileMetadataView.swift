//
//  FileMetadataView.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

class FileMetadataView: UIView {
    
    // UI Components
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fill
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let fileIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let filenameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fileSizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lastModifiedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fileTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        // Clear any existing subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        // Add header stack with icon and filename
        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        headerStack.addArrangedSubview(fileIconView)
        headerStack.addArrangedSubview(filenameLabel)
        
        // Add all elements to the main stack
        stackView.addArrangedSubview(headerStack)
        stackView.addArrangedSubview(fileTypeLabel)
        stackView.addArrangedSubview(fileSizeLabel)
        stackView.addArrangedSubview(lastModifiedLabel)
        
        addSubview(stackView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            // Set width constraint for the file icon
            fileIconView.widthAnchor.constraint(equalToConstant: 24),
            fileIconView.heightAnchor.constraint(equalToConstant: 24),
            
            // Make sure file name can wrap if too long
            filenameLabel.widthAnchor.constraint(lessThanOrEqualTo: stackView.widthAnchor, constant: -36)
        ])
        
        // Add some padding to the view itself
        layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    // MARK: - Public Methods
    
    /// Clear all existing subviews
    private func clearCustomDataLabels() {
        // Remove any custom data labels that might have been added previously
        for subview in stackView.arrangedSubviews where 
            subview != fileTypeLabel && 
            subview != fileSizeLabel && 
            subview != lastModifiedLabel &&
            !(subview is UIStackView) {
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
    
    /// Update the view with file metadata
    /// - Parameter url: The URL of the file
    func updateWithFileURL(_ url: URL) {
        // Clear any previous custom data
        clearCustomDataLabels()
        
        // Set icon and filename
        fileIconView.image = UIImage(systemName: FileTypeIconHelper.getSystemIconName(for: url))
        fileIconView.tintColor = FileTypeIconHelper.getColorForFile(url: url)
        filenameLabel.text = url.lastPathComponent
        
        // Get file attributes
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            
            // Format file size
            if let fileSize = fileAttributes[.size] as? NSNumber {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useAll]
                formatter.countStyle = .file
                fileSizeLabel.text = "Size: \(formatter.string(fromByteCount: fileSize.int64Value))"
            } else {
                fileSizeLabel.text = "Size: Unknown"
            }
            
            // Format last modified date
            if let modificationDate = fileAttributes[.modificationDate] as? Date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                lastModifiedLabel.text = "Modified: \(dateFormatter.string(from: modificationDate))"
            } else {
                lastModifiedLabel.text = "Modified: Unknown"
            }
            
            // Set file type
            let fileExtension = url.pathExtension.uppercased()
            if fileExtension.isEmpty {
                fileTypeLabel.text = "Type: Unknown"
            } else {
                fileTypeLabel.text = "Type: \(fileExtension) File"
            }
            
        } catch {
            fileSizeLabel.text = "Size: Error retrieving"
            lastModifiedLabel.text = "Modified: Error retrieving"
            fileTypeLabel.text = "Type: Unknown"
        }
    }
    
    /// Update the view with file metadata including custom data
    /// - Parameters:
    ///   - url: The URL of the file
    ///   - customData: Dictionary of additional metadata to display
    func updateWithFileURL(_ url: URL, customData: [String: String]) {
        // First update with standard file metadata
        updateWithFileURL(url)
        
        // Then add custom data entries after a separator
        if !customData.isEmpty {
            // Add a separator
            let separator = UIView()
            separator.backgroundColor = .systemGray4
            separator.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.heightAnchor.constraint(equalToConstant: 1),
                separator.widthAnchor.constraint(equalTo: stackView.widthAnchor)
            ])
            
            // Add each custom data item
            for (key, value) in customData {
                let customLabel = UILabel()
                customLabel.font = .systemFont(ofSize: 14)
                customLabel.textColor = .secondaryLabel
                customLabel.text = "\(key): \(value)"
                customLabel.translatesAutoresizingMaskIntoConstraints = false
                stackView.addArrangedSubview(customLabel)
            }
        }
        
        // Force layout update
        layoutIfNeeded()
    }
}
