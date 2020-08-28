//
//  UsersModel.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 3.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class UsersManager {
    static let shared = UsersManager()
    
    private init() { }
    
    private var users = [User]()
    private(set) var loggedUser: User?
    private let usersRef = Firestore.firestore().collection("users")
    
    func createUser(
        firstName: String,
        lastName: String,
        email: String,
        id: String
    ) {
        let newUser = User(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            followers: [],
            following: [],
            profilePicURL: "",
            backgroundPicURL: ""
        )
        
        do {
            try usersRef.document(id).setData(from: newUser)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadLoggedUser(completion: @escaping () -> ()) {
        let userRef = self.usersRef.document(AuthManager.shared.userId)
        userRef.getDocument { (document, error) in
            _ = Result {
                guard let data = document?.data() else { return }
                UsersManager.shared.loggedUser = try JSONDecoder()
                    .decode(User.self, from: JSONSerialization.data(withJSONObject: data, options: .prettyPrinted))
                completion()
            }
        }
    }
    
    func getAllUsers(completion: @escaping ([User]) -> ()) {
        self.usersRef.getDocuments { (users, error) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                guard let users = users else { return }
                let jsonDecoder = JSONDecoder()
                UsersManager.shared.users = users.documents.map() {
                    try! jsonDecoder
                        .decode(User.self, from: JSONSerialization.data(withJSONObject: $0.data(), options: .prettyPrinted)) }
                completion(UsersManager.shared.users)
            }
        }
    }
    
    func getUserById(_ id: String, completion: @escaping (User) -> ()) {
        let userRef = self.usersRef.document(id)
        userRef.getDocument { (document, error) in
            _ = Result {
                guard let data = document?.data() else { return }
                let user = try JSONDecoder()
                    .decode(User.self, from: JSONSerialization.data(withJSONObject: data, options: .prettyPrinted))
                completion(user)
            }
        }
    }

    func follow(user: User, completion: @escaping () -> ()) {
        usersRef.document(user.id).updateData([
            "followers": FieldValue.arrayUnion([AuthManager.shared.userId])
        ])
        usersRef.document(AuthManager.shared.userId).updateData([
            "following": FieldValue.arrayUnion([user.id])
        ])
        completion()
    }
    
    func unfollow(user: User, completion: @escaping () -> ()) {
        usersRef.document(user.id).updateData([
            "followers": FieldValue.arrayRemove([AuthManager.shared.userId])
        ])
        usersRef.document(AuthManager.shared.userId).updateData([
            "following": FieldValue.arrayRemove([user.id])
        ])
        completion()
    }
    
    func updateUserNames(id: String, firstName: String, lastName: String) {
        usersRef.document(id).updateData(["firstName": firstName, "lastName": lastName])
        UsersManager.shared.loggedUser?.firstName = firstName
        UsersManager.shared.loggedUser?.lastName = lastName
    }
    
    func updateProfilePicture(pictureURL: String) {
        let userRef = Firestore.firestore().collection("users").document(AuthManager.shared.userId)
        userRef.updateData([
            "profilePicURL": pictureURL
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func updateBackgroundPicture(pictureURL: String) {
        let userRef = Firestore.firestore().collection("users").document(AuthManager.shared.userId)
        
        userRef.updateData([
            "backgroundPicURL": pictureURL
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
}
