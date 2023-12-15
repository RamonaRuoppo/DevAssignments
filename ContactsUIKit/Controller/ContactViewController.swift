//
//  ContactViewController.swift
//  ContactsUIKit
//
//  Created by Ramona Ruoppo on 24/10/23.
//

import UIKit
import Contacts
import ContactsUI

class ContactViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, CNContactViewControllerDelegate {
    
    @IBOutlet weak var table: UITableView!
    var contacts = [CNContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact List"
        
        let addContactButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactTapped))
        navigationItem.rightBarButtonItem = addContactButton
        
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(table)
        
        fetchContacts()
    }
    
    @objc func addContactTapped() {
        let contactController = CNContactViewController(forNewContact: nil)
        
        contactController.delegate = self
        
        contactController.allowsEditing = true
        contactController.allowsActions = true
        
        contactController.displayedPropertyKeys = [CNContactPostalAddressesKey, CNContactPhoneNumbersKey, CNContactGivenNameKey]
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveContact))
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelContact))
        
        contactController.navigationItem.rightBarButtonItem = saveButton
        contactController.navigationItem.leftBarButtonItem = cancelButton
        
        let navController = UINavigationController(rootViewController: contactController)
        
        navController.view.layoutIfNeeded()
        
        present(navController, animated: true)
    }
    
    @objc func cancelContact() {
        dismiss(animated: true)
    }
    
    
    @objc func saveContact() {
        let store = CNContactStore()
        let contact = CNMutableContact()
        
        // Set the properties of the contact
        contact.givenName = "John"
        contact.familyName = "Doe"
        
        let phoneNumber = CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: "123-456-7890"))
        contact.phoneNumbers = [phoneNumber]
        
        do {
            // Create a save request and save the contact
            let saveRequest = CNSaveRequest()
            saveRequest.add(contact, toContainerWithIdentifier: nil)
            try store.execute(saveRequest)
            
            print("Contact saved successfully.")
            
            dismiss(animated: true, completion: nil)
        } catch {
            // Handle the error if the contact could not be saved
            print("Error saving contact: \(error)")
        }
    }
    
    func fetchContacts() {
        let store = CNContactStore()
        
        // Request access to contacts on a background queue
        DispatchQueue.global().async {
            store.requestAccess(for: .contacts) { (granted, error) in
                if granted {
                    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                    
                    let request = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])
                    
                    do {
                        try store.enumerateContacts(with: request) { (contact, _) in
                            self.contacts.append(contact)
                        }
                        // Update the table on the main thread
                        DispatchQueue.main.async {
                            self.table.reloadData()
                        }
                    } catch {
                        print("Error while retrieving contacts: \(error)")
                    }
                } else {
                    print("Access to contacts denied.")
                }
            }
        }
    }
    
    
    
    // MARK: - UITableViewDataSource
    
    func tableView( tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let contact = contacts[indexPath.row]
        
        // view contact name in the cell
        cell.textLabel?.text = "\(contact.givenName) \(contact.familyName)"
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = contacts[indexPath.row]
        
        let contactDetailVC = ContactDetailViewController()
        
        // Pass the selected contact to the detail view controller
        contactDetailVC.contact = selectedContact
        
        // Push the detail view controller onto the navigation stack
        self.navigationController?.pushViewController(contactDetailVC, animated: true)
        
        // Deselect the selected row after it's tapped
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Handle the deletion of the contact here
            let contact = contacts[indexPath.row]
            deleteContact(contact, at: indexPath)
        }
    }
    
    func deleteContact(_ contact: CNContact, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete Contact",
            message: "Are you sure you want to delete this contact?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            // Perform the contact deletion
            let store = CNContactStore()
            
            let saveRequest = CNSaveRequest()
            saveRequest.delete(contact.mutableCopy() as! CNMutableContact)
            
            do {
                try store.execute(saveRequest)
                // Contact deleted successfully, remove it from the data source and update the table view
                self.contacts.remove(at: indexPath.row)
                self.table.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Error deleting contact: \(error.localizedDescription)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}
