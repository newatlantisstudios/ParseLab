//
//  EditableJsonTextView.swift
//  ParseLab
//
//  Created on 4/27/25.
//

import UIKit

/// A custom text view that properly handles touches for JSON editing
@objc public class EditableJsonTextView: UITextView {
    
    // Delegate to handle touch events
    weak var touchDelegate: TextViewTouchHandling?
    
    // Override touch handling to ensure proper editing
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Notify delegate of touch
        touchDelegate?.textViewWasTapped(self)
        
        // If editable, ensure we become first responder
        if isEditable {
            becomeFirstResponder()
        }
    }
    
    // Make sure to handle taps for editing as well
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // If we're in editable mode, make sure we're first responder
        if isEditable && !isFirstResponder {
            becomeFirstResponder()
            print("Touch ended - forcing first responder")
        }
    }
    
    // Ensure we always get touch events
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Always return self for any point inside our bounds
        if self.bounds.contains(point) {
            return self
        }
        return super.hitTest(point, with: event)
    }
    
    // Override to ensure editable state works correctly
    public override var isEditable: Bool {
        didSet {
            print("EditableJsonTextView: isEditable changed to \(isEditable)")
            // Ensure user interaction is enabled when editable
            if isEditable {
                isUserInteractionEnabled = true
                isSelectable = true
            }
        }
    }
    
    // Make sure we properly handle becoming first responder
    public override func becomeFirstResponder() -> Bool {
        print("EditableJsonTextView: attempting to become first responder, editable: \(isEditable)")
        if !isEditable {
            // If we're not editable, make ourselves editable first
            isEditable = true
        }
        return super.becomeFirstResponder()
    }
}
