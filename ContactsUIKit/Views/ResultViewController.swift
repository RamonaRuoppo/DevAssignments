//
//  ResultViewController.swift
//  ContactsUIKit
//
//  Created by Ramona Ruoppo on 25/10/23.
//
import UIKit

class ResultViewController: UIViewController {
    // Property to hold the scanned code
    var scannedCode: String

    // Initialize the view controller with the scanned code
    init(result: String) {
        self.scannedCode = result
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title for the navigation bar
        self.title = "Scanned Code"

        // Set the background color to white
        view.backgroundColor = .white

        // Create a label to display the scanned code
        let codeLabel = UILabel()
        codeLabel.text = scannedCode
        codeLabel.textAlignment = .center
        codeLabel.numberOfLines = 0
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeLabel.textColor = .black

        // Add the label to the view
        view.addSubview(codeLabel)

        // Configure layout constraints for the label
        NSLayoutConstraint.activate([
            codeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            codeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            codeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            codeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Set the right bar button item in the navigation bar
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        let doneBarButtonItem = UIBarButtonItem(customView: doneButton)
        navigationItem.rightBarButtonItem = doneBarButtonItem
        
        // Add a "Open URL" button to open the detected URL
        let openURLButton = UIButton(type: .system)
        openURLButton.setTitle("Open URL", for: .normal)
        openURLButton.addTarget(self, action: #selector(openURLButtonTapped), for: .touchUpInside)
        openURLButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(openURLButton)
        
        NSLayoutConstraint.activate([
            openURLButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openURLButton.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 20)
        ])
    }
    
    @objc func openURLButtonTapped() {
        // Check if the scanned code is a valid URL
        if let url = URL(string: scannedCode), UIApplication.shared.canOpenURL(url) {
            // Open the URL if it's valid
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Display an alert if the scanned code is not a valid URL
            let alertController = UIAlertController(title: "Invalid URL", message: "The scanned code is not a valid URL.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }

    @objc func doneButtonTapped() {
        // Dismiss the view controller when the "Done" button is tapped
        dismiss(animated: true, completion: nil)
    }
}
