//
//  PostTableViewCell.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 5.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

protocol PostCellDelegate {
    func reloadData()
}

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postContentView: UITextView!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    var delegate: PostCellDelegate?
    var id: String?
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        print("Should display additional actions")
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        guard let id = self.id else { return }
        PostsManager.shared.likePost(postId: id) { (post, res) in
            self.delegate?.reloadData()
        }
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        print("Display Post page")
    }
    
    func resetCellDefaultData() {
        self.nameLabel.text = nil
        self.profilePictureView.image = nil
        self.timeStampLabel.text = nil
        self.likeButton?.titleLabel?.text = nil
        self.postContentView.text = nil
    }
    
    func updateLike() {
        let image: UIImage?
        guard let post = self.post else { return }
        if post.likes.contains(AuthManager.shared.userId) {
            image = UIImage(systemName: "hand.thumbsup.fill")
        } else {
            image = UIImage(systemName: "hand.thumbsup")
        }
        self.likeButton?.titleLabel?.text = "(\(post.likes.count))"
        self.likeButton?.setImage(image, for: .normal)
    }
}
