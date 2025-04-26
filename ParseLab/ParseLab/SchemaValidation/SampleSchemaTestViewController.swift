//
//  SampleSchemaTestViewController.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit

class SampleSchemaTestViewController: UIViewController {
    
    // UI components
    private let sampleFilesSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Valid Person", "Invalid Person"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let jsonTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let schemaTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let validateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Validate", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let resultTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // JSON Schema validator
    private let schemaValidator = JSONSchemaValidator()
    
    // Current selected files
    private var currentJsonData: Data?
    private var currentSchemaData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSampleFiles()
    }
    
    private func setupUI() {
        title = "JSON Schema Test"
        view.backgroundColor = .systemBackground
        
        // Create labels
        let jsonLabel = createLabel(text: "JSON Document:")
        let schemaLabel = createLabel(text: "JSON Schema:")
        let resultLabel = createLabel(text: "Validation Result:")
        
        // Add UI components
        view.addSubview(sampleFilesSegmentedControl)
        view.addSubview(jsonLabel)
        view.addSubview(jsonTextView)
        view.addSubview(schemaLabel)
        view.addSubview(schemaTextView)
        view.addSubview(validateButton)
        view.addSubview(resultLabel)
        view.addSubview(resultTextView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            sampleFilesSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sampleFilesSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sampleFilesSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            jsonLabel.topAnchor.constraint(equalTo: sampleFilesSegmentedControl.bottomAnchor, constant: 20),
            jsonLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            jsonTextView.topAnchor.constraint(equalTo: jsonLabel.bottomAnchor, constant: 8),
            jsonTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            jsonTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            jsonTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
            
            schemaLabel.topAnchor.constraint(equalTo: jsonTextView.bottomAnchor, constant: 20),
            schemaLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            schemaTextView.topAnchor.constraint(equalTo: schemaLabel.bottomAnchor, constant: 8),
            schemaTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            schemaTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            schemaTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
            
            validateButton.topAnchor.constraint(equalTo: schemaTextView.bottomAnchor, constant: 20),
            validateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            validateButton.widthAnchor.constraint(equalToConstant: 200),
            validateButton.heightAnchor.constraint(equalToConstant: 44),
            
            resultLabel.topAnchor.constraint(equalTo: validateButton.bottomAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            resultTextView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 8),
            resultTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            resultTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            resultTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // Set up actions
        sampleFilesSegmentedControl.addTarget(self, action: #selector(sampleFileChanged), for: .valueChanged)
        validateButton.addTarget(self, action: #selector(validateButtonTapped), for: .touchUpInside)
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func loadSampleFiles() {
        // Load the sample schema
        currentSchemaData = SampleSchemaLoader.shared.loadSampleSchema(named: "sample-schema.json")
        if let schemaData = currentSchemaData, let jsonString = String(data: schemaData, encoding: .utf8) {
            let prettyString = formatJsonStringIfPossible(jsonString)
            schemaTextView.text = prettyString
        } else {
            schemaTextView.text = "Error loading schema"
        }
        
        // Load the first sample file
        loadSelectedSampleFile()
    }
    
    @objc private func sampleFileChanged() {
        loadSelectedSampleFile()
    }
    
    private func loadSelectedSampleFile() {
        let filenames = SampleSchemaLoader.shared.availableSampleFiles
        let selectedIndex = sampleFilesSegmentedControl.selectedSegmentIndex
        
        guard selectedIndex >= 0, selectedIndex < filenames.count else { return }
        
        let filename = filenames[selectedIndex]
        currentJsonData = SampleSchemaLoader.shared.loadSampleJsonFile(named: filename)
        
        if let jsonData = currentJsonData, let jsonString = String(data: jsonData, encoding: .utf8) {
            let prettyString = formatJsonStringIfPossible(jsonString)
            jsonTextView.text = prettyString
        } else {
            jsonTextView.text = "Error loading JSON file"
        }
        
        // Clear previous validation results
        resultTextView.text = ""
    }
    
    private func formatJsonStringIfPossible(_ jsonString: String) -> String {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return jsonString
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            if let prettyString = String(data: prettyData, encoding: .utf8) {
                return prettyString
            }
        } catch {
            // If parsing fails, return the original string
        }
        
        return jsonString
    }
    
    @objc private func validateButtonTapped() {
        guard let jsonData = currentJsonData else {
            resultTextView.text = "Error: No JSON data to validate"
            return
        }
        
        guard let schemaData = currentSchemaData else {
            resultTextView.text = "Error: No schema data to validate against"
            return
        }
        
        // Perform validation
        let result = schemaValidator.validate(jsonData: jsonData, against: schemaData)
        
        switch result {
        case .success:
            resultTextView.text = "✅ Validation successful. JSON is valid according to the schema."
            resultTextView.textColor = .systemGreen
        case .failure(let errors):
            let errorText = errors.errors.map { "❌ \($0.displayDescription)" }.joined(separator: "\n\n")
            resultTextView.text = "Validation failed with \(errors.errors.count) error(s):\n\n\(errorText)"
            resultTextView.textColor = .systemRed
        }
    }
}
