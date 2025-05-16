import UIKit

class CSVTableViewController: UIViewController {
    private var csvDocument: CSVDocument?
    private var tableView: UITableView!
    private var toolbarHeight: CGFloat = 44.0
    private var toolbar: UIToolbar!
    
    init(csvDocument: CSVDocument) {
        self.csvDocument = csvDocument
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add a safety timeout to dismiss the view if it becomes unresponsive
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) { [weak self] in
            if self?.presentingViewController != nil && self?.view.window != nil {
                // Add a top-level emergency close button in case the toolbar is broken
                let closeButton = UIButton(type: .system)
                closeButton.setTitle("Close", for: .normal)
                closeButton.setTitleColor(.white, for: .normal)
                closeButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
                closeButton.layer.cornerRadius = 8
                closeButton.translatesAutoresizingMaskIntoConstraints = false
                closeButton.addTarget(self, action: #selector(CSVTableViewController.closeTapped), for: .touchUpInside)
                
                self?.view.addSubview(closeButton)
                
                if let strongSelf = self {
                    NSLayoutConstraint.activate([
                        closeButton.topAnchor.constraint(equalTo: strongSelf.view.safeAreaLayoutGuide.topAnchor, constant: 8),
                        closeButton.trailingAnchor.constraint(equalTo: strongSelf.view.trailingAnchor, constant: -8),
                        closeButton.widthAnchor.constraint(equalToConstant: 80),
                        closeButton.heightAnchor.constraint(equalToConstant: 40)
                    ])
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set title to the filename if available
        if let filePath = csvDocument?.filePath {
            title = filePath.lastPathComponent
        } else {
            title = "CSV View"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Make sure constraints are updated properly
        updateConstraints()
        view.layoutIfNeeded()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        // Create toolbar
        toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        // Add toolbar items
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        let addRowButton = UIBarButtonItem(image: UIImage(systemName: "plus.rectangle"), style: .plain, target: self, action: #selector(addRowTapped))
        let addColumnButton = UIBarButtonItem(image: UIImage(systemName: "plus.square"), style: .plain, target: self, action: #selector(addColumnTapped))
        let exportButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(exportTapped))
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(sortTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [closeButton, flexibleSpace, addRowButton, addColumnButton, flexibleSpace, sortButton, exportButton]
        
        // Create table view
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CSVHeaderCell.self, forCellReuseIdentifier: "CSVHeaderCell")
        tableView.register(CSVDataCell.self, forCellReuseIdentifier: "CSVDataCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        view.addSubview(tableView)
        
        updateConstraints()
    }
    
    private func updateConstraints() {
        // First, remove constraints related only to the toolbar and tableView
        view.constraints.forEach { constraint in
            if (constraint.firstItem === toolbar || constraint.secondItem === toolbar ||
                constraint.firstItem === tableView || constraint.secondItem === tableView) {
                constraint.isActive = false
            }
        }
        
        // Toolbar constraints
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight)
        ])
        
        // TableView constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
    }
    
    func loadCSVDocument(_ document: CSVDocument) {
        self.csvDocument = document
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        // Dismiss the view controller
        dismiss(animated: true)
    }
    
    @objc private func addRowTapped() {
        guard let document = csvDocument else { return }
        
        let alertController = UIAlertController(title: "Add Row", message: "Add a new row to the CSV", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            document.addRow(values: Array(repeating: "", count: document.columnCount))
            self?.tableView.reloadData()
        })
        
        present(alertController, animated: true)
    }
    
    @objc private func addColumnTapped() {
        guard let document = csvDocument else { return }
        
        let alertController = UIAlertController(title: "Add Column", message: "Enter a header name for the new column", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Header Name"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let headerName = alertController.textFields?.first?.text, !headerName.isEmpty else { return }
            document.addColumn(header: headerName)
            self?.tableView.reloadData()
        })
        
        present(alertController, animated: true)
    }
    
    @objc private func exportTapped() {
        guard let document = csvDocument else { return }
        
        let csvString = document.toCSVString()
        
        // Create a temporary file URL
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent("export.csv")
        
        do {
            try csvString.write(to: tempFileURL, atomically: true, encoding: .utf8)
            
            // Show activity view controller for sharing
            let activityVC = UIActivityViewController(activityItems: [tempFileURL], applicationActivities: nil)
            activityVC.popoverPresentationController?.barButtonItem = toolbar.items?.last
            present(activityVC, animated: true)
        } catch {
            let alert = UIAlertController(title: "Export Failed", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc private func sortTapped() {
        guard let document = csvDocument, !document.headers.isEmpty else { return }
        
        let alertController = UIAlertController(title: "Sort", message: "Choose a column to sort by", preferredStyle: .actionSheet)
        
        for (index, header) in document.headers.enumerated() {
            alertController.addAction(UIAlertAction(title: header, style: .default) { [weak self] _ in
                self?.sortRows(by: index)
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = toolbar.items?[3] // Sort button
        }
        
        present(alertController, animated: true)
    }
    
    private func sortRows(by columnIndex: Int) {
        guard let document = csvDocument, columnIndex < document.columnCount else { return }
        
        // Create alert to choose sort direction
        let alertController = UIAlertController(title: "Sort Direction", message: "Choose a sort direction", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Ascending", style: .default) { [weak self] _ in
            self?.performSort(by: columnIndex, ascending: true)
        })
        
        alertController.addAction(UIAlertAction(title: "Descending", style: .default) { [weak self] _ in
            self?.performSort(by: columnIndex, ascending: false)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = toolbar.items?[3] // Sort button
        }
        
        present(alertController, animated: true)
    }
    
    private func performSort(by columnIndex: Int, ascending: Bool) {
        guard let document = csvDocument else { return }
        
        document.rows.sort { row1, row2 in
            let value1 = columnIndex < row1.count ? row1[columnIndex] : ""
            let value2 = columnIndex < row2.count ? row2[columnIndex] : ""
            
            // Check if values can be parsed as numbers
            if let num1 = Double(value1), let num2 = Double(value2) {
                return ascending ? num1 < num2 : num1 > num2
            }
            
            // Otherwise sort as strings
            return ascending ? value1 < value2 : value1 > value2
        }
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CSVTableViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (csvDocument?.rowCount ?? 0) + 1 // +1 for headers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let document = csvDocument else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            // Header row
            let cell = tableView.dequeueReusableCell(withIdentifier: "CSVHeaderCell", for: indexPath) as! CSVHeaderCell
            cell.configure(with: document.headers)
            return cell
        } else {
            // Data row
            let cell = tableView.dequeueReusableCell(withIdentifier: "CSVDataCell", for: indexPath) as! CSVDataCell
            let rowIndex = indexPath.row - 1 // Adjust for header row
            let rowData = rowIndex < document.rows.count ? document.rows[rowIndex] : []
            cell.configure(with: rowData, delegate: self, rowIndex: rowIndex)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 50 : 44
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row > 0 // Allow editing for data rows only
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let document = csvDocument else { return }
            let rowIndex = indexPath.row - 1 // Adjust for header row
            
            if document.deleteRow(at: rowIndex) {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

// MARK: - CSVDataCellDelegate

extension CSVTableViewController: CSVDataCellDelegate {
    func didChangeValue(at rowIndex: Int, columnIndex: Int, newValue: String) {
        _ = csvDocument?.setValue(row: rowIndex, column: columnIndex, value: newValue)
    }
}

// MARK: - CSVHeaderCell

class CSVHeaderCell: UITableViewCell {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        contentView.addSubview(scrollView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 1
        stackView.distribution = .fillEqually
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    func configure(with headers: [String]) {
        // Clear existing headers
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add header labels
        for header in headers {
            let containerView = UIView()
            containerView.backgroundColor = .systemGray6
            
            let label = UILabel()
            label.text = header
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textAlignment = .center
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
                label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
                label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5)
            ])
            
            // Set a minimum width for each header
            NSLayoutConstraint.activate([
                containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
            
            stackView.addArrangedSubview(containerView)
        }
        
        // Update content size for horizontal scrolling
        let totalWidth = CGFloat(headers.count) * 100
        scrollView.contentSize = CGSize(width: max(totalWidth, scrollView.frame.width), height: scrollView.frame.height)
    }
}

// MARK: - CSVDataCellDelegate

protocol CSVDataCellDelegate: AnyObject {
    func didChangeValue(at rowIndex: Int, columnIndex: Int, newValue: String)
}

// MARK: - CSVDataCell

class CSVDataCell: UITableViewCell, UITextFieldDelegate {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var textFields: [UITextField] = []
    private weak var delegate: CSVDataCellDelegate?
    private var rowIndex: Int = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        contentView.addSubview(scrollView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 1
        stackView.distribution = .fillEqually
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    func configure(with rowData: [String], delegate: CSVDataCellDelegate, rowIndex: Int) {
        self.delegate = delegate
        self.rowIndex = rowIndex
        
        // Clear existing fields
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        textFields.removeAll()
        
        // Add text fields for each cell
        for (columnIndex, value) in rowData.enumerated() {
            let containerView = UIView()
            containerView.backgroundColor = columnIndex % 2 == 0 ? .systemBackground : .systemGray6
            
            let textField = UITextField()
            textField.text = value
            textField.font = UIFont.systemFont(ofSize: 14)
            textField.textAlignment = .center
            textField.borderStyle = .roundedRect
            textField.delegate = self
            textField.tag = columnIndex
            textField.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(textField)
            
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
                textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
                textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
                textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5)
            ])
            
            // Set a minimum width for each cell
            NSLayoutConstraint.activate([
                containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
            
            stackView.addArrangedSubview(containerView)
            textFields.append(textField)
        }
        
        // Update content size for horizontal scrolling
        let totalWidth = CGFloat(rowData.count) * 100
        scrollView.contentSize = CGSize(width: max(totalWidth, scrollView.frame.width), height: scrollView.frame.height)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let columnIndex = textField.tag
        let newValue = textField.text ?? ""
        delegate?.didChangeValue(at: rowIndex, columnIndex: columnIndex, newValue: newValue)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}