//
//  PostsManager.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 5.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class PostsManager {
    static let shared = PostsManager()
    
    private let postsRef = Firestore.firestore().collection("posts")
    private var posts = [Post]()
    private var loggedUserPosts = [Post]()
    private var followingPosts = [Post]()
    private var feedPosts = [Post]()
    
    private init() { }
    
    func createPost(
        userId: String,
        content: String
    ) {
        let postDict = [
            "userId": userId,
            "content": content,
            "dateCreated": Date(),
            "likes": [String]()
            ] as [String : Any]
        
        let newPost = Post(dict: postDict) 
        
        do {
            let ref = postsRef.document()
            try ref.setData(from: newPost)
            ref.setData(["id": ref.documentID], merge: true, completion: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getPostsById(userId: String, completion: @escaping (Result<[Post], NetworkError>) -> ()) {
        self.postsRef.whereField(
            "userId", isEqualTo: userId
        ).getDocuments() { (posts, error) in
            guard let postsUnwrapped = posts else {
                completion(.failure(NetworkError.NotFound))
                return
            }
            
            do {
                let posts = try postsUnwrapped.documents
                    .map() { try ($0.data(as: Post.self)!)}.sorted() { $0 > $1 }
                DispatchQueue.main.async {
                    completion(.success(posts))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.BadRequest))
                }
            }
        }
    }
    
    func getLoggedUserPosts(completion: @escaping (_ result: [Post]) -> ()){
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.postsRef.whereField("userId", isEqualTo: AuthManager.shared.userId ).getDocuments() { (posts, error) in
                guard let postsUnwrapped = posts else {
                    guard let err = error else { return }
                    print("Error getting documents: \(err.localizedDescription)")
                    return
                }
                
                do {
                    weakSelf.loggedUserPosts = try postsUnwrapped.documents
                        .map() { try ($0.data(as: Post.self)!)}.sorted() { $0 > $1 }
                    completion(weakSelf.loggedUserPosts)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getFollowingPosts(completion: @escaping (_ result: [Post]) -> ()) {
        guard let loggedUser = UsersManager.shared.loggedUser else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            if loggedUser.following.count > 0 {
                weakSelf.postsRef.whereField("userId", in: loggedUser.following)
                    .getDocuments() { (results, error) in
                        
                        guard let postsUnwrapped = results else {
                            print(error?.localizedDescription ?? "")
                            return
                        }
                        
                        do {
                            weakSelf.posts = try postsUnwrapped.documents
                                .map() { try $0.data(as: Post.self)! }
                            completion(weakSelf.posts)
                        } catch {
                            print(error.localizedDescription)
                        }
                }
            }
            completion([])
        }
    }
    
    func likePost(postId: String, completion: @escaping(Post, Bool) -> ()) {
        postsRef.document(postId).getDocument() { [weak self] (document, error) in
            guard let weakSelf = self else { return }
            do {
                guard let post = try document?.data(as: Post.self)! else { return }
                if post.likes.contains(AuthManager.shared.userId) {
                    weakSelf.postsRef.document(postId).updateData([
                        "likes": FieldValue.arrayRemove([AuthManager.shared.userId])
                    ])
                    completion(post, false)
                } else {
                    weakSelf.postsRef.document(postId).updateData([
                        "likes": FieldValue.arrayUnion([AuthManager.shared.userId])
                    ])
                    completion(post, true)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func deletePost(withId id: String, completion: @escaping () -> ()) {
        postsRef.document(id).delete() { error in
            guard let errorUnwrapped = error
                else {
                    completion()
                    return
            }
            print(errorUnwrapped) 
        }
    }
}
