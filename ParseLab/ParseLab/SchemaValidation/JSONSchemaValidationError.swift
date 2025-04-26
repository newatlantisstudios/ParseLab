//
//  JSONSchemaValidationError.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import Foundation

/// Structure to represent a single validation error
public struct JSONSchemaValidationError: Error {
    let message: String
    let path: String
    
    init(message: String, path: String) {
        self.message = message
        self.path = path
    }
    
    var displayDescription: String {
        return "\(path): \(message)"
    }
    
    var localizedDescription: String {
        return displayDescription
    }
}

/// Wrapper error type to hold multiple validation errors
public struct JSONSchemaValidationErrors: Error {
    let errors: [JSONSchemaValidationError]
    
    init(errors: [JSONSchemaValidationError]) {
        self.errors = errors
    }
    
    var localizedDescription: String {
        let descriptions = errors.map { $0.displayDescription }.joined(separator: "\n")
        return "JSON Schema validation failed with \(errors.count) errors:\n\(descriptions)"
    }
}
