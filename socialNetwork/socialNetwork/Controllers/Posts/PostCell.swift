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
    @IBOutlet weak var moreButton: UIButton!
    
    var delegate: PostCellDelegate?
    var optionsDelegate: PostOptionsLauncherDelegate?
    var id: String?
    var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        guard let post = self.post else { return }
        self.optionsDelegate?.handleMore(postId: post.id)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        guard let post = post else { return }
        self.delegate?.likePost(with: post.id) { [weak self] (post, didFollow) in
            self?.likeButton.updateCellLike(sender: self)
            self?.delegate?.reloadData()
        }
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        guard let post = self.post else { return }
        self.delegate?.showComments(post: post)
    }
    
    override func prepareForReuse() {
        self.profilePictureView.cancelImageLoad()
        self.profilePictureView.image = UIImage(named: "avatar")
        self.nameLabel.text = ""
        self.timeStampLabel.text = ""
        self.postContentView.text = ""
        self.likesLabel.text = "likes"
    }
}
