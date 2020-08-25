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
    func showComments(post: Post)
    func likePost(with id: String, completion: @escaping (Post, Bool) -> ())
}

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postContentView: UITextView!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    var delegate: PostCellDelegate?
    var id: String?
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        self.profilePictureView.cancelImageLoad()
        self.profilePictureView.image = UIImage(named: "avatar")
        self.nameLabel.text = ""
        self.timeStampLabel.text = ""
        self.postContentView.text = ""
        self.likesLabel.text = "likes"
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        print("Should display additional actions")
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        guard let post = post else { return }
        self.delegate?.likePost(with: post.id) { post, didFollow in
            self.likeButton.updateLikeImage(cell: self)
            self.delegate?.reloadData()
        }
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        print("Display Post page")
        guard let post = self.post else { return }
        print(post)
        self.delegate?.showComments(post: post)
    }
}
