//
//  SimpleModalEditor.swift
//  ParseLab
//
//  Created on 4/27/25.
//

import UIKit

protocol SimpleModalEditorDelegate: AnyObject {
    func modalEditorDidSave(_ editor: SimpleModalEditor, editedText: String)
    func modalEditorDidCancel(_ editor: SimpleModalEditor)
}

class SimpleModalEditor: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: SimpleModalEditorDelegate?
    private var textToEdit: String
    
    // UI Elements
    private let textView = UITextView()
    private let headerView = UIView() // Custom view instead of UIToolbar
    private let saveButton = UIButton()
    private let cancelButton = UIButton()
    private let formatButton = UIButton()
    
    // MARK: - Initialization
    
    init(textToEdit: String) {
        self.textToEdit = textToEdit
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        self.textToEdit = ""
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }
    
    // MARK: - UI Setup
    
    private func setupCustomUI() {
        // Configure view
        view.backgroundColor = .white
        
        // Configure header view (replacing toolbar)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        
        // Configure buttons - using plain UIButtons
        // Cancel button
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 1.0), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        // Format button
        formatButton.translatesAutoresizingMaskIntoConstraints = false
        formatButton.setTitle("Edit", for: .normal)
        formatButton.setTitleColor(UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 1.0), for: .normal)
        formatButton.addTarget(self, action: #selector(formatButtonTapped), for: .touchUpInside)
        
        // Save button
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 1.0), for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Add buttons to header view with simple layout
        headerView.addSubview(cancelButton)
        headerView.addSubview(formatButton)
        headerView.addSubview(saveButton)
        
        // Configure text view
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = textToEdit
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.isEditable = true
        textView.isSelectable = true
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.keyboardType = .default
        if #available(iOS 11.0, *) {
            textView.smartDashesType = .no
            textView.smartQuotesType = .no
        }
        
        // Add subviews
        view.addSubview(headerView)
        view.addSubview(textView)
        
        // Setup constraints with fixed values
        NSLayoutConstraint.activate([
            // Header view
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44),
            
            // Cancel button (left side)
            cancelButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            cancelButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Format button (center)
            formatButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            formatButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Save button (right side)
            saveButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            saveButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Text view
            textView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func saveButtonTapped() {
        delegate?.modalEditorDidSave(self, editedText: textView.text)
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        // Notify delegate first, before dismissal starts
        delegate?.modalEditorDidCancel(self)
        
        // Dismiss with animation
        dismiss(animated: true) { [weak self] in
            // After dismissal is complete, ensure UI is properly restored in parent
            if let parentVC = self?.presentingViewController as? ViewController {
                // Access UI on main thread to be safe
                DispatchQueue.main.async {
                    // LOGGING REMOVED: Removal of duplicate toolbars is no longer needed
                    
                    // LOGGING REMOVED: Removing constraints is no longer needed
                    
                    // REMOVED: Call to replaceWithSimplifiedToolbar
                    // The main ViewController should handle its own layout consistency.
                    print("[LOG] modalEditorDidCancel: Toolbar replacement logic removed.")
                    
                    // Ensure JSON data is displayed
                    if parentVC.currentJsonObject != nil {
                        // Use the viewController's existing methods to refresh view
                        print("[LOG] modalEditorDidCancel: Calling refreshJsonView.")
                        parentVC.refreshJsonView()
                        parentVC.fileContentView.isHidden = false
                    }
                    
                    // Force update UI state (visibility of toolbars, etc.)
                    print("[DEBUG] Calling updateUIVisibilityForJsonLoaded from SimpleModalEditor.swift (modalEditorDidCancel), isLoaded: \(parentVC.currentJsonObject != nil)")
                    parentVC.updateUIVisibilityForJsonLoaded(parentVC.currentJsonObject != nil)
                    
                    // Force layout update
                    print("[LOG] modalEditorDidCancel: Forcing layoutIfNeeded.")
                    parentVC.view.setNeedsLayout()
                    parentVC.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc private func formatButtonTapped() {
        do {
            // Try to parse the JSON
            let jsonData = textView.text.data(using: .utf8)!
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
            
            // Format with pretty printing
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            if let prettyText = String(data: prettyData, encoding: .utf8) {
                textView.text = prettyText
            }
        } catch {
            // Show an alert if JSON is invalid
            let alert = UIAlertController(title: "Invalid JSON", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
