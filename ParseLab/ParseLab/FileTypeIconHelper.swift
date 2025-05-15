//
//  FileTypeIconHelper.swift
//  ParseLab
//
//  Created on 4/25/25.
//

import UIKit

/// Helper class to get system icons appropriate for different file types
class FileTypeIconHelper {
    
    /// Get a system icon name based on file extension
    /// - Parameter url: The file URL
    /// - Returns: System icon name
    static func getSystemIconName(for url: URL) -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "json":
            return "doc.text.fill"
        case "yaml", "yml":
            return "doc.plaintext.fill"
        case "txt", "text", "md", "markdown":
            return "doc.plaintext"
        case "csv", "xls", "xlsx":
            return "doc.text.viewfinder"
        case "xml", "html", "htm":
            return "doc.text.code"
        case "pdf":
            return "doc.fill"
        case "jpg", "jpeg", "png", "gif", "webp", "heic":
            return "photo"
        default:
            return "doc"
        }
    }
    
    /// Get a system icon image based on file extension
    /// - Parameter url: The file URL
    /// - Returns: UIImage of the system icon
    static func getSystemIcon(for url: URL) -> UIImage? {
        let iconName = getSystemIconName(for: url)
        return UIImage(systemName: iconName)
    }
    
    /// Get a color based on file type for visual distinction
    /// - Parameter url: The file URL
    /// - Returns: UIColor appropriate for the file type
    static func getColorForFile(url: URL) -> UIColor {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "json":
            return .systemBlue
        case "yaml", "yml":
            return .systemIndigo
        case "txt", "text", "md", "markdown":
            return .systemGray
        case "csv", "xls", "xlsx":
            return .systemGreen
        case "xml", "html", "htm":
            return .systemOrange
        case "pdf":
            return .systemRed
        case "jpg", "jpeg", "png", "gif", "webp", "heic":
            return .systemPurple
        default:
            return .systemGray
        }
    }
}
