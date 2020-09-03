//
//  AuthManger.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 3.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()

    private(set) var userId = ""
    
    private init() { }
    
    func register(
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        sender: SignUpViewController
    ) {
        Auth.auth().createUser(
        withEmail: email,
        password: password
        ) { (authResult, error) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                let id = authResult?.user.uid
                AuthManager.shared.userId = id!
                UsersManager.shared.createUser(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    id: id!
                )
                
                DispatchQueue.main.async {
                    sender.performSegue(withIdentifier: "signupToFeed", sender: sender)
                }
            }
        }
    }
    
    func login(
        email: String,
        password: String,
        sender: LoginViewController
    ) {
        Auth.auth().signIn(
        withEmail: email,
        password: password
        ) { (authResult, error) in
            if let err = error {
                let alert = UIAlertController(
                    title: "Error",
                    message: "\(err.localizedDescription)",
                    preferredStyle: UIAlertController.Style.alert
                )
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
                sender.present(alert, animated: true, completion: nil)
                print(err.localizedDescription)
            } else {
                guard let result = authResult else { return }
                AuthManager.shared.userId = result.user.uid
                UsersManager.shared.loadLoggedUser() {
                    sender.performSegue(withIdentifier: "loginToFeed", sender: sender)
                }
            }
        }
    }
    
    func logout(completion: @escaping () -> ()) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            completion()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
