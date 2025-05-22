//
//  TipJarViewController.swift
//  ParseLab
//
//  Created on current date.
//

import UIKit
import StoreKit

class TipJarViewController: UIViewController {
    
    // MARK: - Properties
    
    private let tipOptions = [
        ("Small Tip", "$0.99", "com.newatlantisstudios.parselab.tip.small"),
        ("Medium Tip", "$2.99", "com.newatlantisstudios.parselab.tip.medium"),
        ("Large Tip", "$4.99", "com.newatlantisstudios.parselab.tip.large")
    ]
    
    private var tipButtons: [UIButton] = []
    private var products: [Product] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadProducts()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Support ParseLab"
        view.backgroundColor = DesignSystem.Colors.background
        
        // Add close button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        
        // Create main container
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Header label
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = "Thank You for Supporting ParseLab!"
        headerLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        headerLabel.textColor = DesignSystem.Colors.text
        headerLabel.textAlignment = .center
        headerLabel.numberOfLines = 0
        containerView.addSubview(headerLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Your tips help keep the app updated and maintained. Choose a tip amount below:"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = DesignSystem.Colors.textSecondary
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        containerView.addSubview(descriptionLabel)
        
        // Tip buttons container
        let buttonsStackView = UIStackView()
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 16
        buttonsStackView.distribution = .fillEqually
        containerView.addSubview(buttonsStackView)
        
        // Create tip buttons
        for (title, price, productId) in tipOptions {
            let button = createTipButton(title: title, price: price, productId: productId)
            tipButtons.append(button)
            buttonsStackView.addArrangedSubview(button)
        }
        
        // Footer label
        let footerLabel = UILabel()
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.text = "Tips are one-time purchases that support the development of ParseLab."
        footerLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        footerLabel.textColor = DesignSystem.Colors.textSecondary
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        containerView.addSubview(footerLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            buttonsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 180), // 3 buttons * 50 height + 2 * 16 spacing
            
            footerLabel.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 40),
            footerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            footerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func createTipButton(title: String, price: String, productId: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Create title with price
        let fullTitle = "\(title) - \(price)"
        button.setTitle(fullTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        // Style the button
        button.backgroundColor = DesignSystem.Colors.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = DesignSystem.Sizing.cornerRadius
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        
        // Set height
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Add target
        button.addTarget(self, action: #selector(tipButtonTapped(_:)), for: .touchUpInside)
        button.tag = tipOptions.firstIndex(where: { $0.2 == productId }) ?? 0
        
        return button
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func tipButtonTapped(_ sender: UIButton) {
        let selectedTip = tipOptions[sender.tag]
        let productId = selectedTip.2
        
        guard let product = products.first(where: { $0.id == productId }) else {
            showError("Product not available")
            return
        }
        
        Task {
            await purchaseProduct(product)
        }
    }
    
    private func showSuccessMessage() {
        let alert = UIAlertController(
            title: "Thank You!",
            message: "Your tip has been received. Thank you for supporting ParseLab! 💝",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "You're Welcome!", style: .default) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - StoreKit 2 Implementation
    
    private func loadProducts() {
        Task {
            do {
                let productIds = tipOptions.map { $0.2 }
                let products = try await Product.products(for: productIds)
                await MainActor.run {
                    self.products = products
                    self.updateButtonPrices()
                }
            } catch {
                await MainActor.run {
                    self.showError("Failed to load products: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateButtonPrices() {
        for (index, button) in tipButtons.enumerated() {
            let tipOption = tipOptions[index]
            if let product = products.first(where: { $0.id == tipOption.2 }) {
                let fullTitle = "\(tipOption.0) - \(product.displayPrice)"
                button.setTitle(fullTitle, for: .normal)
            }
        }
    }
    
    private func purchaseProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await MainActor.run {
                        self.showSuccessMessage()
                    }
                case .unverified:
                    await MainActor.run {
                        self.showError("Purchase could not be verified")
                    }
                }
            case .userCancelled:
                break
            case .pending:
                await MainActor.run {
                    self.showError("Purchase is pending approval")
                }
            @unknown default:
                await MainActor.run {
                    self.showError("Unknown purchase result")
                }
            }
        } catch {
            await MainActor.run {
                self.showError("Purchase failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
