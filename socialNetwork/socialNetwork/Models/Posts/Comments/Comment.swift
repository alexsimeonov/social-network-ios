//
//  Comment.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 20.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import Foundation
import Firebase

struct Comment: Codable {
    static func <(lhs: Comment, rhs: Comment) -> Bool {
        lhs.dateCreated < rhs.dateCreated
    }

    let id: String
    let userId: String
    let postId: String
    let content: String
    let dateCreated: Date

    init( dict: [String: Any]) {
            self.id = dict["id"] as? String ?? ""
            self.userId = dict["userId"] as? String ?? ""
            self.postId = dict["postId"] as? String ?? ""
            self.content = dict["content"] as? String ?? ""
            let str = dict["dateCreated"] as? Timestamp ?? Timestamp()
            self.dateCreated = str.dateValue()
        }
}
