//
//  CommentsManager.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 20.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import Foundation
import FirebaseFirestore

final class CommentsManager {
    static let shared = CommentsManager()
    
    private let commentsRef = Firestore.firestore().collection("comments")
    
    private init() { }
    
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
    
    func getCommentsForPost(postId: String, completion: @escaping (Result<[Comment], Error>) -> ()) {
        DispatchQueue.main.async {
            self.commentsRef
                .whereField("postId", isEqualTo: postId)
                .getDocuments() { (comments, error) in
                    
                guard let commentsUnwrapped = comments else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.NotFound))
                    }
                    return
                }
                
                do {
                    let postComments = try commentsUnwrapped.documents
                        .map() { try ($0.data(as: Comment.self)!) }
                        .sorted() { $0 < $1 }
                    DispatchQueue.main.async {
                        completion(.success(postComments))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.BadRequest))
                    }
                }
            }
        }
    }
}
