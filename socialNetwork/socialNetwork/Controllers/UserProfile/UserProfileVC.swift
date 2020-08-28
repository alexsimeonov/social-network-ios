//
//  UserProfileVC.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 19.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

class UserProfileVC: UIViewController {
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var connectionsCollection: UICollectionView!
    @IBOutlet weak var postsView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var userId: String?
    var user: User?
    var posts: [Post]?
    var selectedPost: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureData()
        configureProfile()
    }
    
    private func configureProfile() {
        guard let id = self.userId else { return }
        
        UsersManager.shared.getUserById(id) { [weak self] user in
            self?.user = user
            self?.navigationItem.title = "\(user.firstName) \(user.lastName)"
            self?.nameLabel.text = "\(user.firstName) \(user.lastName)"
            self?.configureProfilePicture(user: user)
            self?.configureBackgroundPicture(user: user)
            self?.connectionsCollection.reloadData()
        }
        self.reloadPosts(id: id)
    }
    
    private func reloadPosts(id: String) {
        PostsManager.shared.getPostsById(userId: id) { [weak self] posts in
            self?.posts = posts
            self?.postsView.reloadData()
        }
    }
    
    private func configureProfilePicture(user: User) {
        profileView.makeRounded()
        profileView.layer.borderWidth = 2
        profileView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        guard let url = URL(string: user.profilePicURL) else { return }
        self.profileView.loadImage(from: url)
    }
    
    private func configureBackgroundPicture(user: User) {
        guard let url = URL(string: user.backgroundPicURL) else { return }
        self.backgroundView.loadImage(from: url)
    }
    
    private func configureData() {
        postsView.dataSource = self
        connectionsCollection.dataSource = self
        connectionsCollection.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postPage" {
            if let viewController = segue.destination as? PostVC {
                guard let post = self.selectedPost else { return }
                viewController.post = post
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension UserProfileVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let user = user else { return 6 }
        let count = user.following.count
        
        return count <= 6 ? count : 6
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "connectionCell",
            for: indexPath
            ) as! ConnectionsCollectionCell
        guard let user = user else { return cell }
        UsersManager.shared.getUserById(user.following[indexPath.row]) { user in
            guard let url = URL(string: user.profilePicURL) else { return }
            cell.profilePictureView?.loadImage(from: url)
            cell.nameLabel?.text = "\(user.firstName) \(user.lastName)"
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 40
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width - 40) / 3
        return CGSize(width: width, height: width + 20)
    }
}

// MARK: - PostsTableViewDataSource

extension UserProfileVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let posts = posts else { return 0 }
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        guard let posts = posts else { return cell}
        let post = posts[indexPath.row]
        cell.delegate = self
        DispatchQueue.main.async {
            cell.id = post.id
            cell.post = post
            UsersManager.shared.getUserById(post.userId) { (user) in
                cell.nameLabel.text = "\(user.firstName) \(user.lastName)"
                guard let url = URL(string: user.profilePicURL) else { return }
                cell.profilePictureView.loadImage(from: url)
            }
            let date = DateManager.shared.formatDate(post.dateCreated as AnyObject)
            cell.timeStampLabel.text = date
            cell.profilePictureView.makeRounded()
            cell.postContentView.text = post.content
            cell.likesLabel.text = "\(post.likes.count) likes"
            cell.likeButton.updateLikeImage(cell: cell)
        }
        return cell
    }
}

// MARK: - PostCellDelegate

extension UserProfileVC: PostCellDelegate {
    func likePost(with id: String, completion: @escaping (Post, Bool) -> ()) {
        PostsManager.shared.likePost(postId: id) { (post, didFollow)  in
            completion(post, didFollow)
        }
    }
    
    func showComments(post: Post) {
        self.selectedPost = post
        performSegue(withIdentifier: "postPage", sender: self)
    }
    
    func reloadData() {
        guard let user = user else { return }
        self.reloadPosts(id: user.id)
    }
}
