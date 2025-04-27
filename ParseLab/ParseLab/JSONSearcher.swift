//
//  JSONSearcher.swift
//  ParseLab
//
//  Created on 4/25/25.
//

import Foundation
import UIKit

struct JSONSearchResult {
    let path: String
    let keyPath: [String]
    let value: Any
    let isKey: Bool  // Whether the match is in a key or in a value
    let matchRange: NSRange  // Range of the match within the key or value string
    
    var displayText: String {
        // Format the result for display
        if isKey {
            return "Key: \"\(keyPath.last ?? "")\" at path: \(path)"
        } else {
            var valueStr = ""
            if let stringValue = value as? String {
                valueStr = "\"\(stringValue)\""
            } else {
                valueStr = "\(value)"
            }
            return "Value: \(valueStr) at path: \(path)"
        }
    }
}

class JSONSearcher {
    
    /// Search for a string within JSON keys and values
    /// - Parameters:
    ///   - jsonObject: The JSON object to search in
    ///   - searchText: The text to search for
    ///   - searchKeys: Whether to search in keys
    ///   - searchValues: Whether to search in values
    ///   - caseSensitive: Whether the search should be case sensitive
    /// - Returns: Array of search results
    func search(
        jsonObject: Any,
        searchText: String,
        searchKeys: Bool = true,
        searchValues: Bool = true,
        caseSensitive: Bool = false
    ) -> [JSONSearchResult] {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearchText.isEmpty else { return [] }
        
        var results: [JSONSearchResult] = []
        
        // Start recursive search from root
        searchRecursively(
            in: jsonObject,
            for: trimmedSearchText,
            searchInKeys: searchKeys,
            searchInValues: searchValues,
            caseSensitive: caseSensitive,
            currentPath: "$",
            keyPath: ["$"],
            results: &results
        )
        
        return results
    }
    
    /// Recursively search through JSON structure
    private func searchRecursively(
        in json: Any,
        for searchText: String,
        searchInKeys: Bool,
        searchInValues: Bool,
        caseSensitive: Bool,
        currentPath: String,
        keyPath: [String],
        results: inout [JSONSearchResult]
    ) {
        // Define case comparison options
        let stringCompareOptions: NSString.CompareOptions = caseSensitive ? [] : .caseInsensitive
        
        if let dictionary = json as? [String: Any] {
            // Search in dictionary
            for (key, value) in dictionary {
                // Check if key matches search text
                if searchInKeys {
                    let nsKey = key as NSString
                    let range = nsKey.range(of: searchText, options: stringCompareOptions)
                    if range.location != NSNotFound {
                        let newPath = currentPath.isEmpty ? key : "\(currentPath).\(key)"
                        var newKeyPath = keyPath
                        newKeyPath.append(key)
                        results.append(JSONSearchResult(
                            path: newPath,
                            keyPath: newKeyPath,
                            value: value,
                            isKey: true,
                            matchRange: range
                        ))
                    }
                }
                
                // Create new path for nested searching
                let newPath = currentPath.isEmpty ? key : "\(currentPath).\(key)"
                var newKeyPath = keyPath
                newKeyPath.append(key)
                
                // Check if string value matches search text
                if searchInValues, let stringValue = value as? String {
                    let nsStringValue = stringValue as NSString
                    let range = nsStringValue.range(of: searchText, options: stringCompareOptions)
                    if range.location != NSNotFound {
                        results.append(JSONSearchResult(
                            path: newPath,
                            keyPath: newKeyPath,
                            value: stringValue,
                            isKey: false,
                            matchRange: range
                        ))
                    }
                } 
                // Check if number value matches search text
                else if searchInValues, let numberValue = value as? NSNumber, 
                        let numberString = numberAsString(numberValue),
                        numberString.range(of: searchText, options: stringCompareOptions) != nil {
                    results.append(JSONSearchResult(
                        path: newPath,
                        keyPath: newKeyPath,
                        value: numberValue,
                        isKey: false,
                        matchRange: NSRange(location: 0, length: numberString.count)
                    ))
                }
                
                // Recursive search for nested objects and arrays
                searchRecursively(
                    in: value,
                    for: searchText,
                    searchInKeys: searchInKeys,
                    searchInValues: searchInValues,
                    caseSensitive: caseSensitive,
                    currentPath: newPath,
                    keyPath: newKeyPath,
                    results: &results
                )
            }
        } else if let array = json as? [Any] {
            // Search in array
            for (index, value) in array.enumerated() {
                let newPath = "\(currentPath)[\(index)]"
                var newKeyPath = keyPath
                newKeyPath.append("[\(index)]")
                
                // Check if string value matches search text
                if searchInValues, let stringValue = value as? String {
                    let nsStringValue = stringValue as NSString
                    let range = nsStringValue.range(of: searchText, options: stringCompareOptions)
                    if range.location != NSNotFound {
                        results.append(JSONSearchResult(
                            path: newPath,
                            keyPath: newKeyPath,
                            value: stringValue,
                            isKey: false,
                            matchRange: range
                        ))
                    }
                } 
                // Check if number value matches search text
                else if searchInValues, let numberValue = value as? NSNumber, 
                        let numberString = numberAsString(numberValue),
                        numberString.range(of: searchText, options: stringCompareOptions) != nil {
                    results.append(JSONSearchResult(
                        path: newPath,
                        keyPath: newKeyPath,
                        value: numberValue,
                        isKey: false,
                        matchRange: NSRange(location: 0, length: numberString.count)
                    ))
                }
                
                // Recursive search for nested objects and arrays
                searchRecursively(
                    in: value,
                    for: searchText,
                    searchInKeys: searchInKeys,
                    searchInValues: searchInValues,
                    caseSensitive: caseSensitive,
                    currentPath: newPath,
                    keyPath: newKeyPath,
                    results: &results
                )
            }
        }
    }
    
    /// Helper method to convert NSNumber to string consistently
    private func numberAsString(_ number: NSNumber) -> String? {
        // Need to handle special case for booleans which are also NSNumber
        if CFGetTypeID(number) == CFBooleanGetTypeID() {
            return number.boolValue ? "true" : "false"
        } else {
            // For other numbers, use description
            return number.stringValue
        }
    }
}
