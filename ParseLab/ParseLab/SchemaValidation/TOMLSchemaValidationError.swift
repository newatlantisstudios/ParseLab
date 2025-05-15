//
//  TOMLSchemaValidationError.swift
//  ParseLab
//
//  Created on 5/14/25.
//

import Foundation

/// Represents an error that occurs during TOML schema validation
class TOMLSchemaValidationError: Error {
    
    /// Types of TOML schema validation errors
    enum ErrorType {
        case invalidType
        case missingRequiredProperty
        case invalidFormat
        case invalidValue
        case tableNotFound
        case invalidArrayType
        case invalidDateTimeFormat
        case other
    }
    
    /// The type of error that occurred
    let type: ErrorType
    
    /// The JSON path where the error occurred
    let path: String
    
    /// A human-readable description of the error
    let message: String
    
    /// The expected type or format
    let expected: String?
    
    /// The actual type or value found
    let found: String?
    
    /// Initialize with all properties
    init(type: ErrorType, path: String, message: String, expected: String? = nil, found: String? = nil) {
        self.type = type
        self.path = path
        self.message = message
        self.expected = expected
        self.found = found
    }
    
    /// Convenience initializer for invalid type errors
    static func invalidType(path: String, expected: String, found: String) -> TOMLSchemaValidationError {
        return TOMLSchemaValidationError(
            type: .invalidType,
            path: path,
            message: "Invalid type at '\(path)'",
            expected: expected,
            found: found
        )
    }
    
    /// Convenience initializer for missing property errors
    static func missingRequiredProperty(path: String, property: String) -> TOMLSchemaValidationError {
        return TOMLSchemaValidationError(
            type: .missingRequiredProperty,
            path: path,
            message: "Missing required property '\(property)' at '\(path)'"
        )
    }
    
    /// Convenience initializer for invalid format errors
    static func invalidFormat(path: String, format: String, value: String) -> TOMLSchemaValidationError {
        return TOMLSchemaValidationError(
            type: .invalidFormat,
            path: path,
            message: "Invalid format at '\(path)'",
            expected: format,
            found: value
        )
    }
    
    /// Convenience initializer for invalid value errors
    static func invalidValue(path: String, expected: String, found: String) -> TOMLSchemaValidationError {
        return TOMLSchemaValidationError(
            type: .invalidValue,
            path: path,
            message: "Invalid value at '\(path)'",
            expected: expected,
            found: found
        )
    }
    
    /// Convenience initializer for table not found errors
    static func tableNotFound(path: String, tableName: String) -> TOMLSchemaValidationError {
        return TOMLSchemaValidationError(
            type: .tableNotFound,
            path: path,
            message: "Table '\(tableName)' not found at '\(path)'"
        )
    }
    
    /// Convenience initializer for invalid array type errors
    static func invalidArrayType(path: String, expected: String, found: String) -> TOMLSchemaValidationError {
        return TOMLSchemaValidationError(
            type: .invalidArrayType,
            path: path,
            message: "Invalid array item type at '\(path)'",
            expected: expected,
            found: found
        )
    }
    
    /// Convenience initializer for invalid datetime format errors
    static func invalidDateTimeFormat(path: String, value: String) -> TOMLSchemaValidationError {
        return TOMLSchemaValidationError(
            type: .invalidDateTimeFormat,
            path: path,
            message: "Invalid datetime format at '\(path)'",
            expected: "RFC 3339 datetime",
            found: value
        )
    }
}

/// Collection of TOML schema validation errors
class TOMLSchemaValidationErrors: Error {
    /// Array of validation errors
    let errors: [TOMLSchemaValidationError]
    
    /// Initialize with array of errors
    init(errors: [TOMLSchemaValidationError]) {
        self.errors = errors
    }
    
    /// Create formatted error message
    var localizedDescription: String {
        var result = "TOML Schema Validation Errors:\n"
        for (index, error) in errors.enumerated() {
            result += "[\(index + 1)] \(error.message)"
            if let expected = error.expected, let found = error.found {
                result += " (expected: \(expected), found: \(found))"
            }
            result += "\n"
        }
        return result
    }
}