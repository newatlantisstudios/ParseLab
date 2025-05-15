//
//  SchemaValidationViewController.swift
//  ParseLab
//
//  Created on 4/26/25.
//

import UIKit
import UniformTypeIdentifiers

class SchemaValidationViewController: UIViewController {
    
    // JSON or TOML data to validate
    private var jsonData: Data?
    
    // Schema data to validate against
    private var schemaData: Data?
    
    // Flag to indicate if the data is TOML
    private var isTOMLData: Bool = false
    
    // Schema validators
    private let jsonSchemaValidator = JSONSchemaValidator()
    private let tomlStringData: String? = nil
    
    // UI Components
    private let schemaSourceSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Sample Schema", "Upload Schema"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // Data type label
    private let dataTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sampleTestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load Sample Tests", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let schemaStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Using sample schema"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let uploadSchemaButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload Schema", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
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
    
    // Initialize with JSON or TOML data to validate
    init(jsonData: Data, isTOML: Bool = false) {
        self.jsonData = jsonData
        self.isTOMLData = isTOML
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSampleSchema()
    }
    
    private func setupUI() {
        title = "Schema Validation"
        view.backgroundColor = .systemBackground
        
        // Set the data type label
        dataTypeLabel.text = isTOMLData ? "Data type: TOML" : "Data type: JSON"
        
        // Add UI components
        view.addSubview(dataTypeLabel)
        view.addSubview(schemaSourceSegmentedControl)
        view.addSubview(schemaStatusLabel)
        view.addSubview(uploadSchemaButton)
        view.addSubview(sampleTestButton)
        view.addSubview(validateButton)
        view.addSubview(resultTextView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            dataTypeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dataTypeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            schemaSourceSegmentedControl.topAnchor.constraint(equalTo: dataTypeLabel.bottomAnchor, constant: 12),
            schemaSourceSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            schemaSourceSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            schemaStatusLabel.topAnchor.constraint(equalTo: schemaSourceSegmentedControl.bottomAnchor, constant: 12),
            schemaStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            uploadSchemaButton.topAnchor.constraint(equalTo: schemaStatusLabel.bottomAnchor, constant: 12),
            uploadSchemaButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            sampleTestButton.topAnchor.constraint(equalTo: uploadSchemaButton.bottomAnchor, constant: 12),
            sampleTestButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            validateButton.topAnchor.constraint(equalTo: sampleTestButton.bottomAnchor, constant: 20),
            validateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            validateButton.widthAnchor.constraint(equalToConstant: 200),
            validateButton.heightAnchor.constraint(equalToConstant: 44),
            
            resultTextView.topAnchor.constraint(equalTo: validateButton.bottomAnchor, constant: 20),
            resultTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            resultTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            resultTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // Set up actions
        schemaSourceSegmentedControl.addTarget(self, action: #selector(schemaSourceChanged), for: .valueChanged)
        uploadSchemaButton.addTarget(self, action: #selector(uploadSchemaButtonTapped), for: .touchUpInside)
        sampleTestButton.addTarget(self, action: #selector(sampleTestButtonTapped), for: .touchUpInside)
        validateButton.addTarget(self, action: #selector(validateButtonTapped), for: .touchUpInside)
    }
    
    // Load the sample schema from the app bundle
    private func loadSampleSchema() {
        if let url = Bundle.main.url(forResource: "sample-schema", withExtension: "json", subdirectory: "SampleFiles") {
            do {
                schemaData = try Data(contentsOf: url)
                schemaStatusLabel.text = "Using sample schema"
                schemaStatusLabel.textColor = .systemGreen
            } catch {
                schemaStatusLabel.text = "Error loading sample schema"
                schemaStatusLabel.textColor = .systemRed
            }
        } else {
            schemaStatusLabel.text = "Sample schema not found"
            schemaStatusLabel.textColor = .systemRed
        }
    }
    
    // Handle schema source change
    @objc private func schemaSourceChanged() {
        switch schemaSourceSegmentedControl.selectedSegmentIndex {
        case 0: // Sample schema
            loadSampleSchema()
            uploadSchemaButton.isHidden = true
        case 1: // Upload schema
            schemaData = nil
            schemaStatusLabel.text = "No schema uploaded"
            schemaStatusLabel.textColor = .secondaryLabel
            uploadSchemaButton.isHidden = false
        default:
            break
        }
    }
    
    // Handle schema upload button tap
    @objc private func uploadSchemaButtonTapped() {
        let jsonUTType = UTType(filenameExtension: "json") ?? UTType.json
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [jsonUTType],
            asCopy: true
        )
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    // Handle sample test button tap
    @objc private func sampleTestButtonTapped() {
        // Create and present the sample test view controller
        let sampleTestVC = SampleSchemaTestViewController()
        if let navigationController = navigationController {
            navigationController.pushViewController(sampleTestVC, animated: true)
        } else {
            let navController = UINavigationController(rootViewController: sampleTestVC)
            present(navController, animated: true)
        }
    }
    
    // Handle validate button tap
    @objc private func validateButtonTapped() {
        guard let jsonData = jsonData else {
            resultTextView.text = "Error: No data to validate"
            return
        }
        
        guard let schemaData = schemaData else {
            resultTextView.text = "Error: No schema data to validate against"
            return
        }
        
        if isTOMLData {
            // TOML validation
            do {
                // Convert the data to string if not already done
                guard let tomlString = String(data: jsonData, encoding: .utf8) else {
                    resultTextView.text = "Error: Could not read TOML data as string"
                    resultTextView.textColor = .systemRed
                    return
                }
                
                // Parse schema data into a dictionary
                guard let schema = try JSONSerialization.jsonObject(with: schemaData, options: []) as? [String: Any] else {
                    resultTextView.text = "Error: Invalid schema format"
                    resultTextView.textColor = .systemRed
                    return
                }
                
                // Validate TOML against schema
                let errors = try TOMLSchemaValidator.validate(tomlData: tomlString, schemaData: schema)
                
                if errors.isEmpty {
                    resultTextView.text = "✅ Validation successful. TOML is valid according to the schema."
                    resultTextView.textColor = .systemGreen
                } else {
                    let errorText = errors.map { "❌ \($0.message)" }.joined(separator: "\n\n")
                    resultTextView.text = "Validation failed with \(errors.count) error(s):\n\n\(errorText)"
                    resultTextView.textColor = .systemRed
                }
            } catch {
                resultTextView.text = "Error validating TOML: \(error.localizedDescription)"
                resultTextView.textColor = .systemRed
            }
        } else {
            // JSON validation
            let result = jsonSchemaValidator.validate(jsonData: jsonData, against: schemaData)
            
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
}

// MARK: - UIDocumentPickerDelegate
extension SchemaValidationViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        // Access security-scoped resource
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            // Read schema data
            schemaData = try Data(contentsOf: url)
            schemaStatusLabel.text = "Using schema: \(url.lastPathComponent)"
            schemaStatusLabel.textColor = .systemGreen
        } catch {
            schemaStatusLabel.text = "Error loading schema: \(error.localizedDescription)"
            schemaStatusLabel.textColor = .systemRed
        }
    }
}
