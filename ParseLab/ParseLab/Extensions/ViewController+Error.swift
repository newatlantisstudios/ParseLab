//
//  ViewController+Error.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension for error handling methods
extension ViewController {
    // Display error messages using a toast or alert
    internal func showErrorMessage(_ message: String) {
        showEnhancedToast(message: message, type: ToastType.error)
    }
}
