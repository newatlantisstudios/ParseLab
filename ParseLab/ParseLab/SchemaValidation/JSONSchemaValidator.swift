//
//  JSONSchemaValidator.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import Foundation

/// Class to validate JSON against JSON Schema
class JSONSchemaValidator {
    
    /// Validate JSON data against a schema
    /// - Parameters:
    ///   - jsonData: The JSON data to validate
    ///   - schemaData: The JSON Schema data to validate against
    /// - Returns: A result containing either the validated JSON object or validation errors
    func validate(jsonData: Data, against schemaData: Data) -> Result<Any, JSONSchemaValidationErrors> {
        do {
            // Parse JSON and schema
            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: Any] else {
                return .failure(JSONSchemaValidationErrors(errors: [JSONSchemaValidationError(message: "Invalid JSON format", path: "$")]))
            }
            
            guard let schema = try JSONSerialization.jsonObject(with: schemaData, options: .fragmentsAllowed) as? [String: Any] else {
                return .failure(JSONSchemaValidationErrors(errors: [JSONSchemaValidationError(message: "Invalid JSON Schema format", path: "$")]))
            }
            
            // Validate against schema
            var errors: [JSONSchemaValidationError] = []
            validateObject(json, against: schema, path: "$", errors: &errors)
            
            // Return result
            if errors.isEmpty {
                return .success(json)
            } else {
                return .failure(JSONSchemaValidationErrors(errors: errors))
            }
        } catch {
            return .failure(JSONSchemaValidationErrors(errors: [JSONSchemaValidationError(message: "JSON parsing error: \(error.localizedDescription)", path: "$")]))
        }
    }
    
    /// Validate a JSON object against a schema
    /// - Parameters:
    ///   - json: The JSON object to validate
    ///   - schema: The schema to validate against
    ///   - path: The current path in the JSON object
    ///   - errors: The list of errors to add to
    private func validateObject(_ json: [String: Any], against schema: [String: Any], path: String, errors: inout [JSONSchemaValidationError]) {
        // Check required properties
        if let requiredProps = schema["required"] as? [String] {
            for prop in requiredProps {
                if json[prop] == nil {
                    errors.append(JSONSchemaValidationError(message: "Required property missing", path: "\(path).\(prop)"))
                }
            }
        }
        
        // Check properties
        if let properties = schema["properties"] as? [String: [String: Any]] {
            // Check each property against its schema
            for (propName, propSchema) in properties {
                if let propValue = json[propName] {
                    let propPath = "\(path).\(propName)"
                    validateValue(propValue, against: propSchema, path: propPath, errors: &errors)
                }
            }
        }
        
        // Check additional properties
        if let additionalProps = schema["additionalProperties"] as? Bool {
            if !additionalProps {
                // No additional properties allowed
                if let propertiesDict = schema["properties"] as? [String: [String: Any]] {
                    let allowedProps = Set(propertiesDict.keys)
                    for propName in json.keys {
                        if !allowedProps.contains(propName) {
                            errors.append(JSONSchemaValidationError(message: "Additional property not allowed", path: "\(path).\(propName)"))
                        }
                    }
                }
            }
        }
    }
    
    /// Validate a JSON array against a schema
    /// - Parameters:
    ///   - array: The JSON array to validate
    ///   - schema: The schema to validate against
    ///   - path: The current path in the JSON object
    ///   - errors: The list of errors to add to
    private func validateArray(_ array: [Any], against schema: [String: Any], path: String, errors: inout [JSONSchemaValidationError]) {
        // Check min/max items
        if let minItems = schema["minItems"] as? Int, array.count < minItems {
            errors.append(JSONSchemaValidationError(message: "Array has fewer items than required minimum of \(minItems)", path: path))
        }
        
        if let maxItems = schema["maxItems"] as? Int, array.count > maxItems {
            errors.append(JSONSchemaValidationError(message: "Array has more items than allowed maximum of \(maxItems)", path: path))
        }
        
        // Validate items against schema
        if let itemsSchema = schema["items"] as? [String: Any] {
            for (index, item) in array.enumerated() {
                let itemPath = "\(path)[\(index)]"
                validateValue(item, against: itemsSchema, path: itemPath, errors: &errors)
            }
        }
    }
    
    /// Validate any JSON value against a schema
    /// - Parameters:
    ///   - value: The JSON value to validate
    ///   - schema: The schema to validate against
    ///   - path: The current path in the JSON object
    ///   - errors: The list of errors to add to
    private func validateValue(_ value: Any, against schema: [String: Any], path: String, errors: inout [JSONSchemaValidationError]) {
        // Check type
        if let type = schema["type"] as? String {
            let valueType = getJSONType(of: value)
            if type != valueType {
                errors.append(JSONSchemaValidationError(message: "Expected type \(type), found \(valueType)", path: path))
                return
            }
        }
        
        // Validate by type
        switch value {
        case let obj as [String: Any]:
            validateObject(obj, against: schema, path: path, errors: &errors)
            
        case let arr as [Any]:
            validateArray(arr, against: schema, path: path, errors: &errors)
            
        case let str as String:
            validateString(str, against: schema, path: path, errors: &errors)
            
        case let num as NSNumber:
            if CFGetTypeID(num as CFTypeRef) == CFBooleanGetTypeID() {
                // It's a boolean
                validateBoolean(num.boolValue, against: schema, path: path, errors: &errors)
            } else {
                // It's a number
                validateNumber(num.doubleValue, against: schema, path: path, errors: &errors)
            }
            
        default:
            if !(value is NSNull) { // Ignore null values
                errors.append(JSONSchemaValidationError(message: "Unsupported type", path: path))
            }
        }
    }
    
    /// Validate a string against a schema
    /// - Parameters:
    ///   - string: The string to validate
    ///   - schema: The schema to validate against
    ///   - path: The current path in the JSON object
    ///   - errors: The list of errors to add to
    private func validateString(_ string: String, against schema: [String: Any], path: String, errors: inout [JSONSchemaValidationError]) {
        // Check min/max length
        if let minLength = schema["minLength"] as? Int, string.count < minLength {
            errors.append(JSONSchemaValidationError(message: "String is shorter than required minimum length \(minLength)", path: path))
        }
        
        if let maxLength = schema["maxLength"] as? Int, string.count > maxLength {
            errors.append(JSONSchemaValidationError(message: "String is longer than allowed maximum length \(maxLength)", path: path))
        }
        
        // Check pattern
        if let pattern = schema["pattern"] as? String {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let range = NSRange(location: 0, length: string.utf16.count)
                if regex.firstMatch(in: string, options: [], range: range) == nil {
                    errors.append(JSONSchemaValidationError(message: "String does not match pattern", path: path))
                }
            } catch {
                errors.append(JSONSchemaValidationError(message: "Invalid regex pattern in schema", path: path))
            }
        }
        
        // Check enum
        if let enumValues = schema["enum"] as? [String], !enumValues.contains(string) {
            errors.append(JSONSchemaValidationError(message: "Value must be one of: \(enumValues.joined(separator: ", "))", path: path))
        }
    }
    
    /// Validate a number against a schema
    /// - Parameters:
    ///   - number: The number to validate
    ///   - schema: The schema to validate against
    ///   - path: The current path in the JSON object
    ///   - errors: The list of errors to add to
    private func validateNumber(_ number: Double, against schema: [String: Any], path: String, errors: inout [JSONSchemaValidationError]) {
        // Check min/max
        if let minimum = schema["minimum"] as? Double, number < minimum {
            errors.append(JSONSchemaValidationError(message: "Number is less than required minimum \(minimum)", path: path))
        }
        
        if let maximum = schema["maximum"] as? Double, number > maximum {
            errors.append(JSONSchemaValidationError(message: "Number is greater than allowed maximum \(maximum)", path: path))
        }
        
        // Check exclusive min/max
        if let exclusiveMinimum = schema["exclusiveMinimum"] as? Double, number <= exclusiveMinimum {
            errors.append(JSONSchemaValidationError(message: "Number must be greater than \(exclusiveMinimum)", path: path))
        }
        
        if let exclusiveMaximum = schema["exclusiveMaximum"] as? Double, number >= exclusiveMaximum {
            errors.append(JSONSchemaValidationError(message: "Number must be less than \(exclusiveMaximum)", path: path))
        }
        
        // Check multiples
        if let multipleOf = schema["multipleOf"] as? Double, multipleOf > 0 {
            let remainder = number.truncatingRemainder(dividingBy: multipleOf)
            let isMultiple = abs(remainder) < 0.00000001 // Account for floating point precision
            if !isMultiple {
                errors.append(JSONSchemaValidationError(message: "Number must be a multiple of \(multipleOf)", path: path))
            }
        }
    }
    
    /// Validate a boolean against a schema
    /// - Parameters:
    ///   - bool: The boolean to validate
    ///   - schema: The schema to validate against
    ///   - path: The current path in the JSON object
    ///   - errors: The list of errors to add to
    private func validateBoolean(_ bool: Bool, against schema: [String: Any], path: String, errors: inout [JSONSchemaValidationError]) {
        // For now, there's not much to validate for booleans beyond type, which is already handled
    }
    
    /// Get the JSON type of a value
    /// - Parameter value: The value to get the type for
    /// - Returns: The JSON type as a string
    private func getJSONType(of value: Any) -> String {
        switch value {
        case is [String: Any]:
            return "object"
        case is [Any]:
            return "array"
        case is String:
            return "string"
        case let num as NSNumber:
            if CFGetTypeID(num as CFTypeRef) == CFBooleanGetTypeID() {
                return "boolean"
            } else {
                // Could distinguish between integer and number if needed
                return "number"
            }
        case is NSNull:
            return "null"
        default:
            return "unknown"
        }
    }
}
