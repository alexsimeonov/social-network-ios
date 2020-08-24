//
//  SignUpViewController.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 3.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SignUpViewController: UIViewController {
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        guard let firstName = firstNameField.text else { return }
        guard let lastName = lastNameField.text else { return }
        
        guard let email = self.emailField.text, let password = self.passwordField.text else { return }
        DispatchQueue.main.async {
            AuthManager.shared.register(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                sender: self
            )
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
