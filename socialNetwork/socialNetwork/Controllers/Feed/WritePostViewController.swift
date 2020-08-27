//
//  WritePostViewController.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 5.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

class WritePostViewController: UIViewController {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var profilePictureView: UIImageView!
    @IBOutlet private weak var postContentField: UITextView!
    
    var initialText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard
            let user = UsersManager.shared.loggedUser,
            let url = URL(string: user.profilePicURL) else { return }
        profilePictureView.loadImage(from: url)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if initialText != nil && postContentField.text == initialText {
            postContentField.becomeFirstResponder()
        }
    }
    
    @IBAction func postButtonTapped(_ sender: UIBarButtonItem) {
        PostsManager.shared.createPost(
            userId: AuthManager.shared.userId,
            content: postContentField.text!
        )
        navigationController?.popViewController(animated: true)
    }
    
    private func prepareView() {
        postContentField.delegate = self
        profilePictureView.image = UIImage(named: "avatar")
        profilePictureView.makeRounded()
        guard let user = UsersManager.shared.loggedUser else { return }
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        
        if let initialText = initialText {
            postContentField.text = initialText
        } else {
            postContentField.text = "Write what's on your mind..."
            postContentField.textColor = UIColor.lightGray
        }
    }
}

// MARK: - textViewDelegate

extension WritePostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text?.isEmpty != false {
            postContentField.text = "Write what's on your mind..."
            postContentField.textColor = UIColor.lightGray
        }
    }
}
