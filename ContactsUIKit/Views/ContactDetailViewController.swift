//
//  ContactDetailViewController.swift
//  ContactsUIKit
//
//  Created by Ramona Ruoppo on 25/10/23.
//

import UIKit
import Contacts
import ContactsUI

class ContactDetailViewController: UIViewController {
    var contact: CNContact?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let contact = contact {
            // Define the keys you want to fetch as CNKeyDescriptor instances
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactViewController.descriptorForRequiredKeys(),
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor
            ]

            // Fetch the contact with the required keys
            if let detailedContact = try? CNContactStore().unifiedContact(withIdentifier: contact.identifier, keysToFetch: keysToFetch) {
                let contactViewController = CNContactViewController(for: detailedContact)
                contactViewController.allowsEditing = true
                contactViewController.allowsActions = true

                // Embed the contact view controller in a navigation controller
                let navigationController = UINavigationController(rootViewController: contactViewController)
                addChild(navigationController)
                view.addSubview(navigationController.view)
                navigationController.didMove(toParent: self)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar when the view appears
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar when leaving the view
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
