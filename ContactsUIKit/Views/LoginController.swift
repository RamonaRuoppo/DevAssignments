//
//  ViewController.swift
//  ContactsUIKit
//
//  Created by Ramona Ruoppo on 24/10/23.
//

import UIKit
import Contacts
import ContactsUI
import LocalAuthentication

class LoginController: UIViewController, CNContactPickerDelegate {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageLogin: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var faceIDLabel: UILabel!
    
    var context = LAContext()
    
    var loginAttempts = 0
    var isShowingAlert = false

    enum AuthenticationState {
        case loggedin, loggedout
    }
    
    // Current authentication state
    @MainActor
    var state = AuthenticationState.loggedout {
        
        // Update the UI on a change.
        didSet {
            if  state == .loggedin {
                loginAttempts = 0
                showScannerView() // Switch to the scanner view when logged in
            }
            
            faceIDLabel?.isHidden = (state == .loggedin) || (context.biometryType != .faceID)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The biometryType, which affects this app's UI when state changes, is only meaningful after running canEvaluatePolicy
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        
        // Set the initial app state
        state = .loggedout
        loginButton?.setTitle("Login", for: .normal) // Set the initial button label
        
        NotificationCenter.default.addObserver(self, selector: #selector(didTakeScreenshot(notification:)), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    @objc func didTakeScreenshot(notification: Notification) {
        let alert = UIAlertController(title: "Screenshot Detected", message: "Screenshots are not allowed in this app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
        print("Screenshot taken")
    }
    
    @IBAction func tapButton(_ sender: UIButton) {
        
        if state == .loggedin {
            state = .loggedout
            descriptionLabel.text = "Tap the button below to authenticate with FaceID and login"
            loginButton.setTitle("Login", for: .normal) // Change the button label to "Login" when logged out

        } else {
            context = LAContext()

            // check if we have the needed hardware support
            var error: NSError?
            guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
                print(error?.localizedDescription ?? "Can't evaluate policy")

                // Fall back to a asking for username and password
                if !isShowingAlert {
                    isShowingAlert = true
                    showUsernamePasswordAlert()
                }
                return
            }
            
            
            Task {
                do {
                    try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Log in to your account")
                    state = .loggedin
                    loginButton.setTitle("Logout", for: .normal) // Change the button label to "Logout" when logged in
                    descriptionLabel.text = ""
                } catch let error {
                    print(error.localizedDescription)
                    // Increment the login attempts
                    loginAttempts += 1
                    print(loginAttempts) // Check
                    
                    // Attempts counter
                    if loginAttempts >= 3 {
                        // Fall back to a asking for username and password.
                        self.showUsernamePasswordAlert()
                    }
                }
            }
        }
    }
    
    // Handle the fallback to username and password input
    func showUsernamePasswordAlert() {
        let alertController = UIAlertController(title: "Enter Username and Password", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Username"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let loginAction = UIAlertAction(title: "Log In", style: .default) { (action) in
            if let username = alertController.textFields?[0].text,
               let password = alertController.textFields?[1].text {
                
                // If valid, update the UI to indicate a successful login
                if self.validateCredentials(username: username, password: password) {
                    self.loginButton.setTitle("Logout", for: .normal)
                } else {
                    self.showUsernamePasswordAlert()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(loginAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
       
    // Simulate credential validation
    func validateCredentials(username: String, password: String) -> Bool {
        // Replace this logic with actual credential validation
        if username.lowercased() == "ramona" && password == "123456" {
            self.state = .loggedin
            return true // Valid credentials
        } else {
            self.state = .loggedout
            showAlertForInvalidCredentials()
            return false // Invalid credentials
        }
    }
    
    func showAlertForInvalidCredentials() {
        let alertController = UIAlertController(
            title: "Invalid Credentials",
            message: "The username or password is incorrect. Please try again.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showContactView() {
        let contactStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let contacViewController = contactStoryboard.instantiateViewController(withIdentifier: "ContactViewController")
        self.navigationController?.pushViewController(contacViewController, animated: true)
    }
    
    func showScannerView() {
        let contactStoryboard = UIStoryboard(name: "Main", bundle: nil) 
        let contacViewController = contactStoryboard.instantiateViewController(withIdentifier: "ScannerViewController")
        self.navigationController?.pushViewController(contacViewController, animated: true)
    }
}

