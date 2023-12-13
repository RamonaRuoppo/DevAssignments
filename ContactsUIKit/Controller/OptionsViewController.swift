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
        
        self.title = "Options"
    }
    
    @IBAction func openScannerTapped(_ sender: Any) {
        let scannerViewController = ScannerViewController()
        self.navigationController?.pushViewController(scannerViewController, animated: true)
    }
    
    @IBAction func contactsButtonTapped(_ sender: Any) {
        showContactView()
    }
    
    func showContactView() {
        let contactStoryboard = UIStoryboard(name: "Main", bundle: nil) 
        let contacViewController = contactStoryboard.instantiateViewController(withIdentifier: "ContactViewController")
        self.navigationController?.pushViewController(contacViewController, animated: true)
    }

}
