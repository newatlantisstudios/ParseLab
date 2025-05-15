//
//  ViewController+SchemaValidation.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// MARK: - Schema Validation Extensions
extension ViewController {
    
    // Add schema validation button to the UI
    internal func setupSchemaValidation() {
        // Create schema validation button
        let schemaValidateButton = UIButton(type: .system)
        let buttonTitle = "Validate Schema"
        schemaValidateButton.setTitle(buttonTitle, for: .normal)
        schemaValidateButton.translatesAutoresizingMaskIntoConstraints = false
        schemaValidateButton.addTarget(self, action: #selector(schemaValidationTapped), for: .touchUpInside)
        
        // Add to JSON actions stack view after the regular validate button
        if let validateButtonIndex = jsonActionsStackView.arrangedSubviews.firstIndex(of: validateButton) {
            jsonActionsStackView.insertArrangedSubview(schemaValidateButton, at: validateButtonIndex + 1)
        } else {
            jsonActionsStackView.addArrangedSubview(schemaValidateButton)
        }
    }
    
    // Handle schema validation button tap
    @objc internal func schemaValidationTapped() {
        guard let jsonObject = currentJsonObject, isTextModeActive() else {
            self.showToast(message: "Schema validation requires a valid document in text mode", type: .error)
            return
        }
        
        // Check if we're dealing with TOML file
        let isTOMLFile = self.isTOMLFile
        
        // Process according to file type
        do {
            let fileData: Data
            
            if isTOMLFile, let fileUrl = currentFileUrl, 
               let tomlString = try? String(contentsOf: fileUrl, encoding: .utf8) {
                // Use original TOML content for validation
                fileData = tomlString.data(using: .utf8) ?? Data()
            } else {
                // For JSON or YAML (converted to JSON), use the current object
                fileData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            }
            
            // Create and present schema validation view controller
            let schemaVC = SchemaValidationViewController(jsonData: fileData, isTOML: isTOMLFile)
            if let navigationController = navigationController {
                navigationController.pushViewController(schemaVC, animated: true)
            } else {
                let navController = UINavigationController(rootViewController: schemaVC)
                present(navController, animated: true)
            }
        } catch {
            self.showToast(message: "Error preparing document for schema validation: \(error.localizedDescription)", type: .error)
        }
    }
}
