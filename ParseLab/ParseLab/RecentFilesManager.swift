//
//  RecentFilesManager.swift
//  ParseLab
//
//  Created on 4/25/25.
//

import Foundation

class RecentFilesManager {
    // Singleton instance for app-wide access
    static let shared = RecentFilesManager()
    
    // Constants
    private let userDefaultsKey = "ParseLab.RecentFiles"
    private let maxRecentFiles = 10
    
    // Structure to hold file information
    struct RecentFile: Codable {
        let name: String
        let path: String
        let url: URL
        let timestamp: Date
        let isJSON: Bool
        
        // Custom URL encoding/decoding for Codable
        enum CodingKeys: String, CodingKey {
            case name, path, timestamp, isJSON, urlString
        }
        
        init(url: URL, isJSON: Bool) {
            self.url = url
            self.name = url.lastPathComponent
            self.path = url.path
            self.timestamp = Date()
            self.isJSON = isJSON
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            path = try container.decode(String.self, forKey: .path)
            timestamp = try container.decode(Date.self, forKey: .timestamp)
            isJSON = try container.decode(Bool.self, forKey: .isJSON)
            
            let urlString = try container.decode(String.self, forKey: .urlString)
            if let decodedURL = URL(string: urlString) {
                url = decodedURL
            } else {
                // Fallback to creating a file URL from the path if URL construction fails
                url = URL(fileURLWithPath: path)
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(path, forKey: .path)
            try container.encode(timestamp, forKey: .timestamp)
            try container.encode(isJSON, forKey: .isJSON)
            try container.encode(url.absoluteString, forKey: .urlString)
        }
    }
    
    // Private array to store recent files
    private var recentFiles: [RecentFile] = []
    
    private init() {
        loadRecentFiles()
    }
    
    // MARK: - Public Methods
    
    /// Get the list of recent files
    var files: [RecentFile] {
        return recentFiles
    }
    
    /// Add a file to the recent files list
    /// - Parameters:
    ///   - url: The URL of the file
    ///   - isJSON: Whether the file is a JSON file
    func addFile(url: URL, isJSON: Bool) {
        // Remove if already exists
        recentFiles.removeAll { $0.path == url.path }
        
        // Add to the beginning
        let newFile = RecentFile(url: url, isJSON: isJSON)
        recentFiles.insert(newFile, at: 0)
        
        // Trim list if needed
        if recentFiles.count > maxRecentFiles {
            recentFiles = Array(recentFiles.prefix(maxRecentFiles))
        }
        
        // Save changes
        saveRecentFiles()
    }
    
    /// Remove a file from the recent files list
    /// - Parameter index: The index of the file to remove
    func removeFile(at index: Int) {
        guard index >= 0 && index < recentFiles.count else { return }
        recentFiles.remove(at: index)
        saveRecentFiles()
    }
    
    /// Clear all recent files
    func clearAllFiles() {
        recentFiles.removeAll()
        saveRecentFiles()
    }
    
    // MARK: - Private Methods
    
    /// Load recent files from UserDefaults
    private func loadRecentFiles() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                recentFiles = try JSONDecoder().decode([RecentFile].self, from: data)
            } catch {
                print("Error loading recent files: \(error.localizedDescription)")
                recentFiles = []
            }
        }
    }
    
    /// Save recent files to UserDefaults
    private func saveRecentFiles() {
        do {
            let data = try JSONEncoder().encode(recentFiles)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error saving recent files: \(error.localizedDescription)")
        }
    }
}
