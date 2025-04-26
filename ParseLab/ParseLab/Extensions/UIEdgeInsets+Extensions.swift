//
//  UIEdgeInsets+Extensions.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

extension UIEdgeInsets {
    /// Returns a new UIEdgeInsets with values that are the negative of the receiver's
    func inverted() -> UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
}
