//
//  User.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 7.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import Foundation

struct User: Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var followers: [String]
    var following: [String]
    var profilePicURL: String
    var backgroundPicURL: String
}
