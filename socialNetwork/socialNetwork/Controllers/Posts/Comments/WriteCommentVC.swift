//
//  WriteCommentVC.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 20.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

class WriteCommentVC: UIViewController {
    
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var commentContent: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var postId: String?
    var delegate: PostVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    @IBAction func writeCommentTapped(_ sender: UIBarButtonItem) {
        if commentContent.text != "Write a comment" {
            guard let user = UsersManager.shared.loggedUser, let postId = self.postId else { return }
            CommentsManager.shared.createComment(userId: user.id, postId: postId, content: commentContent.text) {
                self.delegate?.reloadData()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func configureView() {
        guard let user = UsersManager.shared.loggedUser else  { return }
        self.nameLabel.text = "\(user.firstName) \(user.lastName)"
        self.profilePicView.makeRounded()
        self.commentContent.delegate = self
        commentContent.text = "Write a comment"
        commentContent.textColor = UIColor.lightGray
        guard let url = URL(string: user.profilePicURL) else { return }
        self.profilePicView.loadImage(from: url)
    }
}

// MARK: - textViewDelegate

extension WriteCommentVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text?.isEmpty != false {
            self.commentContent.text = "Write a comment..."
            self.commentContent.textColor = UIColor.lightGray
        }
    }
}
