//
//  StoryViewCell.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 6.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

class StoryViewCell: UICollectionViewCell {
    @IBOutlet weak var storyProfilePictureView: UIImageView!
    
    func configure(index: Int) {
        guard let loggedUser = UsersManager.shared.loggedUser else { return }
        UsersManager.shared.getUserById(loggedUser.following[index]) { user in
            if user.profilePicURL == "" {
                self.storyProfilePictureView.image = UIImage(named: "avatar")
            } else {
                guard let url = URL(string: user.profilePicURL) else { return }
                self.storyProfilePictureView.loadImage(from: url)
            }
        }
        self.storyProfilePictureView.makeRounded()
    }
}
