//
//  UIButton+UpdateImg.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 25.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

extension UIButton {
    func updateCellLike(sender: PostCell?) {
        guard
            let senderUnwrapped = sender,
            let post = senderUnwrapped.post
            else { return }
        updateImage(sender: senderUnwrapped, post: post)
    }
    
    func updatePostViewLike(post: Post, sender: PostVC) {
        updateImage(sender: sender, post: post)
    }
    
    private func updateImage(sender: Any, post: Post) {
        let image: UIImage?
        
        if post.likes.contains(AuthManager.shared.userId) {
            image = UIImage(systemName: "hand.thumbsup.fill")
        } else {
            image = UIImage(systemName: "hand.thumbsup")
        }
        (sender as AnyObject).likesLabel.text = "\(post.likes.count) likes"
        (sender as AnyObject).likeButton.setImage(image, for: .normal)
    }
}
