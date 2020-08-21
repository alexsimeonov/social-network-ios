//
//  Post.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 7.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import Foundation
import Firebase

struct Post: Codable {
    var id: String
    var userId: String
    var content: String
    var dateCreated: Date
    var likes: [String]

    init( dict: [String: Any]) {
        self.id = dict["id"] as? String ?? ""
        self.userId = dict["userId"] as? String ?? ""
        self.content = dict["content"] as? String ?? ""
        self.likes = dict["likes"] as? [String] ?? []
        let str = dict["dateCreated"] as? Timestamp ?? Timestamp()
        self.dateCreated = str.dateValue()
    }
}
