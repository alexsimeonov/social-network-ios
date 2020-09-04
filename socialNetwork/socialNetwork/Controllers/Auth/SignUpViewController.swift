//
//  SignUpViewController.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 3.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit
import FirebaseFirestore

final class SignUpViewController: UIViewController {

    @IBOutlet private weak var firstNameField: UITextField!
    @IBOutlet private weak var lastNameField: UITextField!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction private func signUpTapped(_ sender: UIButton) {
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
}
