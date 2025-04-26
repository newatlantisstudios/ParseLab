//
//  ViewController+TraitChange.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

// Extension to handle trait collection changes
extension ViewController {
    // Update layout when trait collection changes (e.g., rotation or size class changes)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Only update if the size class actually changed
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            updateSearchUILayout(for: traitCollection.horizontalSizeClass)
        }
    }
}