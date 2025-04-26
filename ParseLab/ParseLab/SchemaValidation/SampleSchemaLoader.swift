//
//  SampleSchemaLoader.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import Foundation

/// Helper class to load and manage sample schemas and test files
class SampleSchemaLoader {
    static let shared = SampleSchemaLoader()
    
    // List of available sample schemas
    let availableSampleSchemas = [
        "sample-schema.json"
    ]
    
    // List of sample JSON files for testing
    let availableSampleFiles = [
        "valid-person.json",
        "invalid-person.json"
    ]
    
    /// Load a sample schema by name
    /// - Parameter name: The schema filename
    /// - Returns: The schema data if found
    func loadSampleSchema(named name: String) -> Data? {
        return loadFile(named: name, subdirectory: "SampleFiles")
    }
    
    /// Load a sample JSON file by name
    /// - Parameter name: The JSON filename
    /// - Returns: The JSON data if found
    func loadSampleJsonFile(named name: String) -> Data? {
        return loadFile(named: name, subdirectory: "SampleFiles")
    }
    
    /// Load a file from the app bundle
    /// - Parameters:
    ///   - name: The filename
    ///   - subdirectory: The subdirectory in the bundle
    /// - Returns: The file data if found
    private func loadFile(named name: String, subdirectory: String) -> Data? {
        guard let fileExtension = name.components(separatedBy: ".").last,
              let filename = name.components(separatedBy: ".").dropLast().joined(separator: ".") as String?,
              let url = Bundle.main.url(forResource: filename, withExtension: fileExtension, subdirectory: subdirectory) else {
            return nil
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Error loading file \(name): \(error.localizedDescription)")
            return nil
        }
    }
}
