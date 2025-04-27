//
//  ViewController+Actions.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension for adding buttons to action areas
extension ViewController {
    
    // Add a button to the actions stack view
    func addFileInfoButtonToActions(_ button: UIButton) {
        // Add the button to the actions stack view
        actionsStackView.addArrangedSubview(button)
    }
}
