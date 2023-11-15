//
//  ScreenViewController.swift
//  ContactsUIKit
//
//  Created by Ramona Ruoppo on 25/10/23.
//

import UIKit

class ScreenViewController: UIViewController {

    @IBOutlet weak var openScannerLabel: UIButton!
    @IBOutlet weak var contactsButtonLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    // This function is called when the "Open Scanner" button is tapped
    @IBAction func openScannerButton(_ sender: Any) {
        let scannerViewController = ScannerViewController()
        // Push the scanner view controller onto the navigation stack 
        self.navigationController?.pushViewController(scannerViewController, animated: true)
    }
    
    // This function is called when the "Contacts" button is tapped
    @IBAction func contactsButton(_ sender: Any) {
        showContactView()
    }
    
    // This function navigates to the contact view controller
    func showContactView() {
        let contactStoryboard = UIStoryboard(name: "Main", bundle: nil) // Create an instance of the contactViewCcontroller
        let contacViewController = contactStoryboard.instantiateViewController(withIdentifier: "ContactViewController")
        // Push the contact view controller onto the navigation stack
        self.navigationController?.pushViewController(contacViewController, animated: true)
    }

}
