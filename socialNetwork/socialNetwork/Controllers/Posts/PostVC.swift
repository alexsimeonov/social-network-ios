//
//  PostVC.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 19.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

final class PostVC: UIViewController {
    @IBOutlet private weak var commentsViewHC: NSLayoutConstraint!
    @IBOutlet private weak var postTextView: UITextView!
    @IBOutlet private weak var postTextViewHC: NSLayoutConstraint!
    @IBOutlet private weak var commentsView: UITableView!
    @IBOutlet private weak var postAuthorNameLabel: UILabel!
    @IBOutlet private weak var createdAtLabel: UILabel!
    @IBOutlet private weak var authorProfilePicView: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    
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
        self.configurePostView()
        self.commentsView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        guard let post = self.post else { return }
        CommentsManager.shared.getCommentsForPost(postId: post.id) { [weak self] (result) in
            guard let weakSelf = self else { return }
            
            switch result {
            case .success(let comments):
                weakSelf.comments = comments
                weakSelf.commentsView.reloadData()
            case .failure(let error):
                weakSelf.showAlert(title: "\(error)", message: "Try again later", sender: weakSelf)
            }
            
        }
    }
    
    @IBAction private func likePostTapped(_ sender: UIButton) {
        guard let post = self.post else { return }
        PostsManager.shared.likePost(postId: post.id) { [weak self] (post, didFollow)  in
            guard let self = self else { return }
            self.configurePostView()
        }
    }
    
    private func configureNavbar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(writeComment)
        )
    }
    
    private func configurePostView() {
        guard let post = post else { return }
        self.postTextView.text = post.content
        postTextViewHC.constant = self.postTextView.contentSize.height
        self.likesLabel.text = "\(post.likes.count) likes"
        self.likeButton.updatePostViewLike(post: post, sender: self)
        self.authorProfilePicView.makeRounded()
        UsersManager.shared.getUserById(post.userId) { [weak self] (user) in
            guard let self = self, let url = URL(string: user.profilePicURL) else { return }
            self.authorProfilePicView.loadImage(from: url)
            self.postAuthorNameLabel.text = "\(user.firstName) \(user.lastName)"
            self.createdAtLabel.text = DateManager.shared.formatDate(post.dateCreated as AnyObject)
        }
    }
    
    @objc private func writeComment() {
        performSegue(withIdentifier: "writeComment", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "writeComment" {
            let writeCommentPage = segue.destination as! WriteCommentVC
            writeCommentPage.postId = self.post?.id
            writeCommentPage.delegate = self
        }
    }
    
    // MARK: - InfiniteTalbeView
    
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
    
    func reloadData() {
        self.commentsView.reloadData()
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
                cell.configure(
                    content: currentComment.content,
                    name: "\(user.firstName) \(user.lastName)",
                    createdAt: DateManager.shared.formatDate(currentComment.dateCreated as AnyObject)
                )
            }
        }
        
        return cell
    }
}
