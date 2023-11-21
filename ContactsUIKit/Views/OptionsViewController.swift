//
//  ScreenViewController.swift
//  ContactsUIKit
//
//  Created by Ramona Ruoppo on 25/10/23.
//

import UIKit

class OptionsViewController: UIViewController {

    @IBOutlet weak var openScannerLabel: UIButton!
    @IBOutlet weak var contactsButtonLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Options"
        
        
    }
    
    // This function is called when the "Open Scanner" button is tapped
    @IBAction func openScannerButton(_ sender: Any) {
        let scannerViewController = ScannerViewController()
        self.navigationController?.pushViewController(scannerViewController, animated: true)
    }
    
    // This function is called when the "Contacts" button is tapped
    @IBAction func contactsButton(_ sender: Any) {
        showContactView()
    }
    
    func showContactView() {
        let contactStoryboard = UIStoryboard(name: "Main", bundle: nil) // Create an instance of the contactViewCcontroller
        let contacViewController = contactStoryboard.instantiateViewController(withIdentifier: "ContactViewController")
        self.navigationController?.pushViewController(contacViewController, animated: true)
    }

}
