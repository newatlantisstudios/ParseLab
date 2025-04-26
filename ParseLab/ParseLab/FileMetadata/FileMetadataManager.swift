//
//  FileMetadataManager.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

class FileMetadataManager {
    // Singleton instance
    static let shared = FileMetadataManager()
    
    // Cache to store file metadata to prevent repeated fetches
    private var metadataCache: [String: FileMetadata] = [:]
    
    // File metadata structure
    struct FileMetadata {
        let url: URL
        let name: String
        let size: Int64
        let modificationDate: Date
        let creationDate: Date
        let fileType: String
        let fileTypeDescription: String
        let icon: UIImage?
        let iconColor: UIColor
        
        // Computed properties for formatted display
        var formattedSize: String {
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useAll]
            formatter.countStyle = .file
            return formatter.string(fromByteCount: size)
        }
        
        var formattedModificationDate: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: modificationDate)
        }
        
        var formattedCreationDate: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: creationDate)
        }
        
        // Dictionary representation of metadata (excluding the icon)
        var dictionary: [String: String] {
            return [
                "Name": name,
                "Size": formattedSize,
                "Modified": formattedModificationDate,
                "Created": formattedCreationDate,
                "Type": fileTypeDescription
            ]
        }
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Get metadata for a file
    /// - Parameter url: The URL of the file
    /// - Returns: FileMetadata if successful, nil otherwise
    func getMetadata(for url: URL) -> FileMetadata? {
        // Check cache first
        if let cachedMetadata = metadataCache[url.path] {
            return cachedMetadata
        }
        
        // Get file attributes
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            
            // Extract file size
            let fileSize = (fileAttributes[.size] as? NSNumber)?.int64Value ?? 0
            
            // Extract modification date
            let modificationDate = (fileAttributes[.modificationDate] as? Date) ?? Date()
            
            // Extract creation date
            let creationDate = (fileAttributes[.creationDate] as? Date) ?? Date()
            
            // Determine file type
            let fileExtension = url.pathExtension.lowercased()
            var fileType = fileExtension.uppercased()
            var fileTypeDescription = "\(fileExtension.uppercased()) File"
            
            if fileExtension.isEmpty {
                fileType = "Unknown"
                fileTypeDescription = "Unknown Type"
            } else if let utType = UTType(filenameExtension: fileExtension) {
                // Try to get a more descriptive type if available
                if let localizedDescription = utType.localizedDescription {
                    fileTypeDescription = localizedDescription
                }
            }
            
            // Create icon
            let iconName = FileTypeIconHelper.getSystemIconName(for: url)
            let icon = UIImage(systemName: iconName)
            let iconColor = FileTypeIconHelper.getColorForFile(url: url)
            
            // Create and cache metadata
            let metadata = FileMetadata(
                url: url,
                name: url.lastPathComponent,
                size: fileSize,
                modificationDate: modificationDate,
                creationDate: creationDate,
                fileType: fileType,
                fileTypeDescription: fileTypeDescription,
                icon: icon,
                iconColor: iconColor
            )
            
            metadataCache[url.path] = metadata
            return metadata
            
        } catch {
            print("Error getting file metadata: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Clear cache for a specific file
    /// - Parameter url: The URL of the file
    func clearCache(for url: URL) {
        metadataCache.removeValue(forKey: url.path)
    }
    
    /// Clear the entire metadata cache
    func clearAllCache() {
        metadataCache.removeAll()
    }
    
    /// Check if a file exists and is accessible
    /// - Parameter url: The URL to check
    /// - Returns: Bool indicating if the file exists and is accessible
    func fileExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
}
