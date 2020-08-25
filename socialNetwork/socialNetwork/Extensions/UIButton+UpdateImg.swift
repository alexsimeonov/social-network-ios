//
//  UIButton+UpdateImg.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 25.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

extension UIButton {
    func updateLikeImage(cell: PostCell?) {
        let image: UIImage?
        guard
            let cell = cell,
            let post = cell.post
            else { return }
        
        if post.likes.contains(AuthManager.shared.userId) {
            image = UIImage(systemName: "hand.thumbsup.fill")
        } else {
            image = UIImage(systemName: "hand.thumbsup")
        }
        cell.likesLabel.text = "\(post.likes.count) likes"
        cell.likeButton?.setImage(image, for: .normal)
    }
    
    func updateLikeImage(post: Post, sender: PostVC) {
        let image: UIImage?
        
        if post.likes.contains(AuthManager.shared.userId) {
            image = UIImage(systemName: "hand.thumbsup.fill")
        } else {
            image = UIImage(systemName: "hand.thumbsup")
        }
        sender.likesLabel.text = "\(post.likes.count) likes"
        sender.likeButton?.setImage(image, for: .normal)
    }
}
