//
//  ProfileViewController.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 3.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit
import Firebase

protocol EditProfileViewControllerDelegate {
    func updateProfile(firstName: String, lastName: String)
}

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var backgroundPictureView: UIImageView!
    @IBOutlet weak var postsView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityViewHeight: NSLayoutConstraint!
    @IBOutlet weak var connectionsCollectionView: UICollectionView!
    
    private var user: User?
    private var posts = [Post]()
    private var selectedUserId: String?
    private var selectedPost: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshActivity()
        connectionsCollectionView.dataSource = self
        connectionsCollectionView.delegate = self
        postsView.dataSource = self
        resizeActivityTableView()
        configureProfilePicture()
        refreshProfile() {
            self.postsView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        postsView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    @IBAction func editProfileButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToEditProfile", sender: self)
    }
    
    func refreshProfile(completion: @escaping () -> ()) {
        UsersManager.shared.loadLoggedUser() { [weak self] in
            guard let user = UsersManager.shared.loggedUser else { return }
            if let profilePicURL = URL(string: user.profilePicURL) {
                self?.profilePictureView.loadImage(from: profilePicURL)
            }
            if let backgroundPicURL = URL(string: user.backgroundPicURL) {
                self?.backgroundPictureView.loadImage(from: backgroundPicURL)
            }
            self?.nameLabel.text = "\(user.firstName) \(user.lastName)"
            self?.connectionsCollectionView.reloadData()
            completion()
        }
    }
    
    private func refreshActivity() {
        PostsManager.shared.getLoggedUserPosts() { [weak self] (userPosts) in
            DispatchQueue.main.async {
                self?.posts = userPosts
                self?.postsView.reloadData()
            }
        }
    }
    
    private func configureNavigation() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .done,
            target: self,
            action: #selector(self.logout)
        )
    }
    
    private func configureProfilePicture() {
        profilePictureView.makeRounded()
        profilePictureView.layer.borderWidth = 2
        profilePictureView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditProfile" {
            let displayVC = segue.destination as! EditProfileViewController
            displayVC.delegate = self
            displayVC.user = self.user
        }
        if segue.identifier == "userProfile" {
            if let viewController = segue.destination as? UserProfileVC {
                guard let id = self.selectedUserId else { return }
                viewController.userId = id
            }
        }
        if segue.identifier == "postPage" {
            if let viewController = segue.destination as? PostVC {
                guard let post = self.selectedPost else { return }
                viewController.post = post
            }
        }
    }
    
    @objc private func logout() {
        AuthManager.shared.logout() {
            self.performSegue(withIdentifier: "logout", sender: nil)
        }
    }
}

// MARK: - Infinite scroll TableView

extension ProfileViewController {
    func resizeActivityTableView() {
        postsView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "contentSize" {
            guard let newValue = change?[.newKey]  else { return }
            let newSize = newValue as! CGSize
            activityViewHeight.constant = newSize.height
        }
    }
}

// MARK: - EditProfileViewControllerDelegate

extension ProfileViewController: EditProfileViewControllerDelegate {
    func updateProfile(firstName: String, lastName: String) {
        UsersManager.shared.updateUserNames(id: AuthManager.shared.userId, firstName: firstName, lastName: lastName )
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let user = UsersManager.shared.loggedUser else { return 6 }
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
        guard let user = UsersManager.shared.loggedUser else { return cell }
        UsersManager.shared.getUserById(user.following[indexPath.row]) { user in
            guard let url = URL(string: user.profilePicURL) else { return }
            cell.profilePictureView.loadImage(from: url)
            cell.nameLabel.text = "\(user.firstName) \(user.lastName)"
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileViewController {
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getProperUser(index: indexPath.row)
        performSegue(withIdentifier: "userProfile", sender: nil)
    }
    
    func getProperUser(index: Int) {
        guard let user = UsersManager.shared.loggedUser else { return }
        selectedUserId = user.following[index]
    }
}

// MARK: - PostsTableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.delegate = self
        cell.optionsDelegate = self
        DispatchQueue.main.async {
            cell.id = post.id
            cell.post = post
            cell.profilePictureView.makeRounded()
            let date = DateManager.shared.formatDate(post.dateCreated as AnyObject)
            cell.timeStampLabel.text = date
            cell.postContentView.text = post.content
            cell.likesLabel.text = "\(post.likes.count) likes"
            cell.likeButton.updateCellLike(sender: cell)
            UsersManager.shared.loadLoggedUser() {
                guard let user = UsersManager.shared.loggedUser else { return }
                cell.nameLabel.text = "\(user.firstName) \(user.lastName)"
                guard let url = URL(string: user.profilePicURL) else { return }
                cell.profilePictureView.loadImage(from: url)
            }
        }
        
        return cell
    }
}

// MARK: - PostCellDelegate

extension ProfileViewController: PostCellDelegate {
    func likePost(with id: String, completion: @escaping (Post, Bool) -> ()) {
        PostsManager.shared.likePost(postId: id) { post, didFollow  in
            completion(post, didFollow)
        }
    }
    
    func showComments(post: Post) {
        self.selectedPost = post
        performSegue(withIdentifier: "postPage", sender: self)
    }
    
    func reloadData() {
        self.refreshActivity()
    }
}

extension ProfileViewController: PostOptionsLauncherDelegate {
    func handleMore(postId: String) {
        PostOptionsLauncher.shared.delegate = self
        PostOptionsLauncher.shared.showSettings(view: self.view, postId: postId)
    }
}
