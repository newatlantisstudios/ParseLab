//
//  EditOverlayTextView.swift
//  ParseLab
//
//  Created on 4/27/25.
//

import UIKit

@objc public protocol EditOverlayDelegate: AnyObject {
    func didFinishEditing(text: String)
    func didCancelEditing()
}

@objc public class EditOverlayTextView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: EditOverlayDelegate?
    
    private let textView = UITextView()
    private let toolbar = UIToolbar()
    private let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    
    // MARK: - Initialization
    
    init(frame: CGRect, initialText: String) {
        super.init(frame: frame)
        setupView()
        textView.text = initialText
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        // Configure self
        backgroundColor = .systemBackground
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.cornerRadius = 10.0
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 5.0
        
        // Configure text view
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.isEditable = true
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        if #available(iOS 11.0, *) {
            textView.smartDashesType = .no
            textView.smartQuotesType = .no
        }
        
        // Configure toolbar
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.items = [
            cancelButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton
        ]
        
        // Add targets
        doneButton.target = self
        doneButton.action = #selector(doneButtonTapped)
        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonTapped)
        
        // Add subviews
        addSubview(toolbar)
        addSubview(textView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44),
            
            textView.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        delegate?.didFinishEditing(text: textView.text)
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.didCancelEditing()
    }
    
    // MARK: - Public Methods
    
    func show(in view: UIView) {
        // Add to view
        view.addSubview(self)
        
        // Make frame match view's bounds with padding
        frame = view.bounds.insetBy(dx: 20, dy: 100)
        center = view.center
        
        // Bring to front
        view.bringSubviewToFront(self)
        
        // Make keyboard appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.textView.becomeFirstResponder()
        }
    }
    
    func hide() {
        // Hide keyboard
        textView.resignFirstResponder()
        
        // Remove from superview
        removeFromSuperview()
    }
}
