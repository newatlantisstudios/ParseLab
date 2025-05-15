//
//  TOMLSchemaValidator.swift
//  ParseLab
//
//  Created on 5/14/25.
//

import Foundation

/// Validator for TOML documents against a schema
class TOMLSchemaValidator {
    
    /// Schema types supported by the validator
    enum SchemaType: String {
        case string
        case integer
        case float
        case boolean
        case array
        case table
        case dateTime
        case date
        case time
        case any
    }
    
    /// Validate a TOML document against a schema
    /// - Parameters:
    ///   - tomlData: The TOML document to validate
    ///   - schemaData: The schema to validate against (in JSON format)
    /// - Returns: An array of validation errors, or an empty array if valid
    static func validate(tomlData: String, schemaData: [String: Any]) throws -> [TOMLSchemaValidationError] {
        var errors: [TOMLSchemaValidationError] = []
        
        do {
            // Parse the TOML document
            let tomlTable = try TOMLParser.parse(tomlData) as? [String: Any] ?? [:]
            
            // Validate the TOML document against the schema
            validateTable(table: tomlTable, schema: schemaData, path: "$", errors: &errors)
            
            // Return validation errors
            return errors
        } catch {
            // Handle parsing errors
            errors.append(TOMLSchemaValidationError(
                type: .other,
                path: "$",
                message: "Failed to parse TOML: \(error.localizedDescription)"
            ))
            return errors
        }
    }
    
    /// Validate a TOML table against a schema
    /// - Parameters:
    ///   - table: The TOML table to validate
    ///   - schema: The schema to validate against
    ///   - path: The current JSON path for error reporting
    ///   - errors: Array to collect validation errors
    private static func validateTable(table: [String: Any], schema: [String: Any], path: String, errors: inout [TOMLSchemaValidationError]) {
        // Check for required properties
        if let required = schema["required"] as? [String] {
            for property in required {
                if table[property] == nil {
                    errors.append(TOMLSchemaValidationError.missingRequiredProperty(path: path, property: property))
                }
            }
        }
        
        // Check properties against schema
        if let properties = schema["properties"] as? [String: [String: Any]] {
            for (property, propertySchema) in properties {
                if let value = table[property] {
                    validateValue(value: value, schema: propertySchema, path: "\(path).\(property)", errors: &errors)
                }
            }
        }
        
        // Optional: Check for additional properties if disallowed
        if let additionalProperties = schema["additionalProperties"] as? Bool, !additionalProperties {
            let schemaPropertiesDict = schema["properties"] as? [String: Any]
            let schemaProperties = Set(schemaPropertiesDict?.keys ?? [String: Any]().keys)
            
            for property in table.keys {
                if !schemaProperties.contains(property) {
                    errors.append(TOMLSchemaValidationError(
                        type: .other,
                        path: path,
                        message: "Additional property '\(property)' not allowed"
                    ))
                }
            }
        }
    }
    
    /// Validate a TOML value against a schema
    /// - Parameters:
    ///   - value: The value to validate
    ///   - schema: The schema to validate against
    ///   - path: The current JSON path for error reporting
    ///   - errors: Array to collect validation errors
    private static func validateValue(value: Any, schema: [String: Any], path: String, errors: inout [TOMLSchemaValidationError]) {
        guard let typeString = schema["type"] as? String,
              let type = SchemaType(rawValue: typeString) else {
            errors.append(TOMLSchemaValidationError(
                type: .other,
                path: path,
                message: "Invalid schema type definition"
            ))
            return
        }
        
        // Validate type
        switch type {
        case .string:
            if !(value is String) {
                errors.append(TOMLSchemaValidationError.invalidType(
                    path: path,
                    expected: "string",
                    found: "\(Swift.type(of: value))"
                ))
            } else if let pattern = schema["pattern"] as? String,
                      let regex = try? NSRegularExpression(pattern: pattern),
                      let stringValue = value as? String {
                let range = NSRange(location: 0, length: stringValue.utf16.count)
                if regex.firstMatch(in: stringValue, range: range) == nil {
                    errors.append(TOMLSchemaValidationError.invalidFormat(
                        path: path,
                        format: "pattern: \(pattern)",
                        value: stringValue
                    ))
                }
            }
            
        case .integer:
            if !(value is Int) {
                errors.append(TOMLSchemaValidationError.invalidType(
                    path: path,
                    expected: "integer",
                    found: "\(Swift.type(of: value))"
                ))
            } else if let minimum = schema["minimum"] as? Int,
                      let intValue = value as? Int,
                      intValue < minimum {
                errors.append(TOMLSchemaValidationError.invalidValue(
                    path: path,
                    expected: "≥ \(minimum)",
                    found: "\(intValue)"
                ))
            } else if let maximum = schema["maximum"] as? Int,
                      let intValue = value as? Int,
                      intValue > maximum {
                errors.append(TOMLSchemaValidationError.invalidValue(
                    path: path,
                    expected: "≤ \(maximum)",
                    found: "\(intValue)"
                ))
            }
            
        case .float:
            if !(value is Double) {
                errors.append(TOMLSchemaValidationError.invalidType(
                    path: path,
                    expected: "float",
                    found: "\(Swift.type(of: value))"
                ))
            }
            
        case .boolean:
            if !(value is Bool) {
                errors.append(TOMLSchemaValidationError.invalidType(
                    path: path,
                    expected: "boolean",
                    found: "\(Swift.type(of: value))"
                ))
            }
            
        case .array:
            if let array = value as? [Any] {
                if let itemsSchema = schema["items"] as? [String: Any] {
                    for (index, item) in array.enumerated() {
                        validateValue(
                            value: item,
                            schema: itemsSchema,
                            path: "\(path)[\(index)]",
                            errors: &errors
                        )
                    }
                }
                
                // Check array length constraints
                if let minItems = schema["minItems"] as? Int, array.count < minItems {
                    errors.append(TOMLSchemaValidationError.invalidValue(
                        path: path,
                        expected: "array with min \(minItems) items",
                        found: "array with \(array.count) items"
                    ))
                }
                
                if let maxItems = schema["maxItems"] as? Int, array.count > maxItems {
                    errors.append(TOMLSchemaValidationError.invalidValue(
                        path: path,
                        expected: "array with max \(maxItems) items",
                        found: "array with \(array.count) items"
                    ))
                }
            } else {
                errors.append(TOMLSchemaValidationError.invalidType(
                    path: path,
                    expected: "array",
                    found: "\(Swift.type(of: value))"
                ))
            }
            
        case .table:
            if let table = value as? [String: Any] {
                validateTable(
                    table: table,
                    schema: schema,
                    path: path,
                    errors: &errors
                )
            } else {
                errors.append(TOMLSchemaValidationError.invalidType(
                    path: path,
                    expected: "table",
                    found: "\(Swift.type(of: value))"
                ))
            }
            
        case .dateTime, .date, .time:
            // Validate date/time format based on RFC 3339
            // This is a simple check; a more robust implementation would parse and validate
            if let dateString = value as? String {
                // Basic date/time format validation
                let isValid: Bool
                
                switch type {
                case .dateTime:
                    // ISO 8601 / RFC 3339 datetime (YYYY-MM-DDThh:mm:ss[.sss]Z or ±hh:mm)
                    let dateTimePattern = "^\\d{4}-\\d{2}-\\d{2}[T ]\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?(Z|[+-]\\d{2}:\\d{2})?$"
                    isValid = dateString.range(of: dateTimePattern, options: .regularExpression) != nil
                    
                case .date:
                    // YYYY-MM-DD
                    let datePattern = "^\\d{4}-\\d{2}-\\d{2}$"
                    isValid = dateString.range(of: datePattern, options: .regularExpression) != nil
                    
                case .time:
                    // hh:mm:ss[.sss]
                    let timePattern = "^\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?$"
                    isValid = dateString.range(of: timePattern, options: .regularExpression) != nil
                    
                default:
                    isValid = false
                }
                
                if !isValid {
                    errors.append(TOMLSchemaValidationError.invalidDateTimeFormat(path: path, value: dateString))
                }
            } else {
                errors.append(TOMLSchemaValidationError.invalidType(
                    path: path,
                    expected: type.rawValue,
                    found: "\(Swift.type(of: value))"
                ))
            }
            
        case .any:
            // Any type is valid
            break
        }
        
        // Check enum constraints
        if let enumValues = schema["enum"] as? [Any] {
            var found = false
            for enumValue in enumValues {
                // Basic equality check - might need more robust comparison for complex types
                if "\(enumValue)" == "\(value)" {
                    found = true
                    break
                }
            }
            
            if !found {
                errors.append(TOMLSchemaValidationError.invalidValue(
                    path: path,
                    expected: "one of \(enumValues)",
                    found: "\(value)"
                ))
            }
        }
    }
}