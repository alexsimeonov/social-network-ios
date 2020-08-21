//
//  PostVC.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 19.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

class PostVC: UIViewController {
    
    @IBOutlet weak var commentsViewHC: NSLayoutConstraint!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postTextViewHC: NSLayoutConstraint!
    @IBOutlet weak var commentsView: UITableView!
    @IBOutlet weak var postAuthorNameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var authorProfilePicView: UIImageView!
    
    var post: Post?
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsView.dataSource = self
        configurePostView()
        configureNavbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.commentsView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        guard let post = self.post else { return }
        CommentsManager.shared.getCommentsForPost(postId: post.id) { (comments) in
            DispatchQueue.main.async {
                self.comments = comments
                self.commentsView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.commentsView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "contentSize" {
            if object is UITableView {
                if let newValue = change?[.newKey] {
                    let newSize = newValue as! CGSize
                    self.commentsViewHC.constant = newSize.height
                }
            }
        }
    }
    
    func configurePostView() {
        guard let post = post else { return }
        self.postTextView.text = post.content
        postTextViewHC.constant = self.postTextView.contentSize.height
        self.authorProfilePicView.makeRounded()
        UsersManager.shared.getUserById(post.userId) { (user) in
            guard let url = URL(string: user.profilePicURL) else { return }
            self.authorProfilePicView.loadImage(from: url)
            self.postAuthorNameLabel.text = "\(user.firstName) \(user.lastName)"
            self.createdAtLabel.text = DateManager.shared.formatDate(post.dateCreated as AnyObject)
        }
    }
    
    func configureNavbar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(writeComment)
        )
    }
    
    @objc func writeComment() {
        performSegue(withIdentifier: "writeComment", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "writeComment" {
            let navigation = segue.destination as! UINavigationController
            let writeCommentPage = navigation.topViewController as! WriteCommentVC
            writeCommentPage.postId = self.post?.id
            writeCommentPage.delegate = self
        }
    }
}

// MARK: - TableViewDataSource

extension PostVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
         
        DispatchQueue.main.async {
            let currentComment = self.comments[indexPath.row]
            
            UsersManager.shared.getUserById(currentComment.userId) { (user) in
                cell.profilePicView.makeRounded()
                guard let url = URL(string: user.profilePicURL) else { return }
                cell.profilePicView.loadImage(from: url)
                cell.nameLabel.text = "\(user.firstName) \(user.lastName)"
                cell.createdAtLabel.text = DateManager.shared.formatDate(currentComment.dateCreated as AnyObject)
                cell.textView.text = currentComment.content
            }
        }
        
        return cell
    }
}
