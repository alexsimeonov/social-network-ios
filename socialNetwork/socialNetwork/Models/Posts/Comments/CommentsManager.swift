//
//  CommentsManager.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 20.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import Foundation
import FirebaseFirestore

class CommentsManager {
    
    static var shared = CommentsManager()
    private init() { }
    private let commentsRef = Firestore.firestore().collection("comments")
    
    func createComment(
        userId: String,
        postId: String,
        content: String,
        completion: @escaping () -> ()
    ) {
        let commentDict = [
            "userId": userId,
            "postId": postId,
            "content": content,
            "dateCreated": Date(),
            ] as [String : Any]
        let newComment = Comment(dict: commentDict)
        
        do {
            let ref = commentsRef.document()
            try ref.setData(from: newComment)
            ref.setData(["id": ref.documentID], merge: true, completion: nil)
            completion()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getCommentsForPost(postId: String, completion: @escaping (_ result: [Comment]) -> ()) {
        DispatchQueue.main.async {
            self.commentsRef
                .whereField("postId", isEqualTo: postId)
                .getDocuments() { (comments, error) in
                    
                guard let comments = comments else {
                    guard let err = error else { return }
                    print(err.localizedDescription)
                    return
                }
                
                do {
                    let postComments = try comments.documents
                        .map() { try ($0.data(as: Comment.self)!) }
                        .sorted() { $0.dateCreated < $1.dateCreated }
                    completion(postComments)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
