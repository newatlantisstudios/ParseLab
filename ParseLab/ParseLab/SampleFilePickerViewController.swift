//
//  SampleFilePickerViewController.swift
//  ParseLab
//
//  Created for better sample file selection UI
//

import UIKit

struct SampleFile {
    let name: String
    let displayName: String
    let fileExtension: String
    let category: String
    let description: String
    var icon: String {
        switch fileExtension {
        case "json": return "doc.text"
        case "yaml", "yml": return "doc.plaintext"
        case "toml": return "doc"
        case "ini": return "doc.text.magnifyingglass"
        case "csv": return "tablecells"
        case "xml": return "chevron.left.slash.chevron.right"
        case "plist": return "list.bullet.rectangle"
        default: return "doc"
        }
    }
}

class SampleFilePickerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let sampleFiles: [SampleFile] = [
        // JSON files
        SampleFile(name: "sample", displayName: "Sample JSON", fileExtension: "json", 
                  category: "JSON", description: "Basic JSON structure example"),
        
        // YAML files
        SampleFile(name: "sample-config", displayName: "Sample YAML Config", fileExtension: "yaml", 
                  category: "YAML", description: "Configuration example in YAML"),
        SampleFile(name: "valid-person", displayName: "Sample YAML Person", fileExtension: "yaml", 
                  category: "YAML", description: "Person data in YAML format"),
        
        // TOML files
        SampleFile(name: "sample-config", displayName: "Sample TOML Config", fileExtension: "toml", 
                  category: "TOML", description: "Configuration example in TOML"),
        SampleFile(name: "sample-person", displayName: "Sample TOML Person", fileExtension: "toml", 
                  category: "TOML", description: "Person data in TOML format"),
        SampleFile(name: "test-validation", displayName: "TOML Validation Test", fileExtension: "toml", 
                  category: "TOML", description: "TOML validation test data"),
        
        // INI files
        SampleFile(name: "sample-config", displayName: "Sample INI Config", fileExtension: "ini", 
                  category: "INI", description: "Configuration example in INI"),
        SampleFile(name: "sample-person", displayName: "Sample INI Person", fileExtension: "ini", 
                  category: "INI", description: "Person data in INI format"),
        
        // CSV files
        SampleFile(name: "sample-data", displayName: "Sample CSV Data", fileExtension: "csv", 
                  category: "CSV", description: "Tabular data in CSV format"),
        
        // XML files
        SampleFile(name: "sample-person", displayName: "Sample XML Person", fileExtension: "xml", 
                  category: "XML", description: "Person data in XML format"),
        SampleFile(name: "sample-library", displayName: "Sample XML Library", fileExtension: "xml", 
                  category: "XML", description: "Library data in XML format"),
        
        // PLIST files
        SampleFile(name: "sample-info", displayName: "Sample PLIST Info", fileExtension: "plist", 
                  category: "Property List", description: "Info property list example")
    ]
    
    private var filteredFiles: [SampleFile] = []
    private var groupedFiles: [String: [SampleFile]] = [:]
    
    weak var delegate: SampleFilePickerDelegate?
    
    // MARK: - UI Elements
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let segmentedControl = UISegmentedControl()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        filteredFiles = sampleFiles
        groupFilesByCategory()
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = DesignSystem.Colors.background
        
        // Navigation bar setup
        title = "Choose Sample File"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // Search bar setup
        searchBar.placeholder = "Search sample files..."
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = DesignSystem.Colors.backgroundSecondary
        
        // Segmented control for filtering
        let categories = ["All", "JSON", "YAML", "TOML", "Other"]
        segmentedControl.removeAllSegments()
        for (index, category) in categories.enumerated() {
            segmentedControl.insertSegment(withTitle: category, at: index, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        
        // Table view setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = DesignSystem.Colors.background
        tableView.separatorStyle = .singleLine
        tableView.register(SampleFileCell.self, forCellReuseIdentifier: "SampleFileCell")
        
        view.addSubview(searchBar)
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Search bar
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Segmented control
            segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func filterChanged() {
        filterFiles()
    }
    
    // MARK: - Helper Methods
    
    private func filterFiles() {
        let searchText = searchBar.text?.lowercased() ?? ""
        let selectedCategory = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) ?? "All"
        
        filteredFiles = sampleFiles.filter { file in
            let matchesSearch = searchText.isEmpty || 
                file.displayName.lowercased().contains(searchText) ||
                file.description.lowercased().contains(searchText) ||
                file.category.lowercased().contains(searchText)
            
            let matchesCategory = selectedCategory == "All" || 
                (selectedCategory == "Other" && !["JSON", "YAML", "TOML"].contains(file.category)) ||
                file.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
        
        groupFilesByCategory()
        tableView.reloadData()
    }
    
    private func groupFilesByCategory() {
        groupedFiles = Dictionary(grouping: filteredFiles) { $0.category }
    }
}

// MARK: - UITableViewDataSource

extension SampleFilePickerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedFiles.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = Array(groupedFiles.keys.sorted())[section]
        return groupedFiles[category]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(groupedFiles.keys.sorted())[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SampleFileCell", for: indexPath) as! SampleFileCell
        
        let category = Array(groupedFiles.keys.sorted())[indexPath.section]
        if let files = groupedFiles[category] {
            let file = files[indexPath.row]
            cell.configure(with: file)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SampleFilePickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let category = Array(groupedFiles.keys.sorted())[indexPath.section]
        if let files = groupedFiles[category] {
            let file = files[indexPath.row]
            delegate?.sampleFilePicker(self, didSelectFile: file)
            dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

// MARK: - UISearchBarDelegate

extension SampleFilePickerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFiles()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Protocol

protocol SampleFilePickerDelegate: AnyObject {
    func sampleFilePicker(_ picker: SampleFilePickerViewController, didSelectFile file: SampleFile)
}

// MARK: - Custom Cell

class SampleFileCell: UITableViewCell {
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let extensionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Icon setup
        iconImageView.tintColor = DesignSystem.Colors.primary
        iconImageView.contentMode = .scaleAspectFit
        
        // Title label
        titleLabel.font = DesignSystem.Typography.bodyMedium().withWeight(.semibold)
        titleLabel.textColor = DesignSystem.Colors.text
        
        // Description label
        descriptionLabel.font = DesignSystem.Typography.bodySmall()
        descriptionLabel.textColor = DesignSystem.Colors.textSecondary
        
        // Extension label
        extensionLabel.font = DesignSystem.Typography.bodySmall().withWeight(.medium)
        extensionLabel.textColor = .white
        extensionLabel.backgroundColor = DesignSystem.Colors.primary
        extensionLabel.layer.cornerRadius = 4
        extensionLabel.textAlignment = .center
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(extensionLabel)
        
        // Layout
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        extensionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            extensionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            extensionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            extensionLabel.widthAnchor.constraint(equalToConstant: 48),
            extensionLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: extensionLabel.leadingAnchor, constant: -8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with file: SampleFile) {
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: file.icon)
        }
        titleLabel.text = file.displayName
        descriptionLabel.text = file.description
        extensionLabel.text = file.fileExtension.uppercased()
    }
}