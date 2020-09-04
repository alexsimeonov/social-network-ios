//
//  FeedViewController.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 3.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit
import Firebase

final class FeedViewController: UIViewController, PostOptionsLauncherDelegate {
    @IBOutlet private weak var postsView: UITableView!
    @IBOutlet private weak var storiesCollectionView: UICollectionView!
    
    private var posts = [Post]()
    private var selectedPost: Post?
    private let blackView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureStories()
        configurePosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populatePostsTable()
        storiesCollectionView.reloadData()
    }
    
    @objc private func writePost() {
        self.performSegue(withIdentifier: "toWritePost", sender: nil)
    }
    
    // MARK: - Configure
    
    private func configureNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .camera,
            target: nil,
            action: nil
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(writePost)
        )
    }
    
    private func configurePosts() {
        postsView.dataSource = self
        postsView.delegate = self
    }
    
    private func configureStories() {
        storiesCollectionView.dataSource = self
        storiesCollectionView.delegate = self
    }
    
    private func populatePostsTable() {
        PostsManager.shared.getFollowingPosts() { [weak self] (followingPosts) in
            self?.posts = followingPosts
        }
        
        PostsManager.shared.getLoggedUserPosts() { [weak self] (userPosts) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async {
                weakSelf.posts = (weakSelf.posts + userPosts)
                    .sorted() { $0 > $1 }
                weakSelf.postsView.reloadData()
            }
        }
    }
    
    func handleMore(postId: String) {
        PostOptionsLauncher.shared.delegate = self
        PostOptionsLauncher.shared.showSettings(view: self.view, postId: postId)
    }
}

// MARK: - TableViewDataSource -> PostsTableView

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        cell.delegate = self
        cell.optionsDelegate = self
        let post = posts[indexPath.row]
        cell.post = post
        UsersManager.shared.getUserById(post.userId) { (user) in
            DispatchQueue.main.async {
                cell.moreButton.isHidden = user.id != AuthManager.shared.userId
                cell.configure(
                    name: "\(user.firstName) \(user.lastName)",
                    content: post.content,
                    date: DateManager.shared.formatDate(post.dateCreated as AnyObject),
                    likes: post.likes.count
                )
                cell.profilePictureView.makeRounded()
                cell.likeButton.updateCellLike(sender: cell)
                guard let url = URL(string: user.profilePicURL) else { return }
                cell.profilePictureView.loadImage(from: url)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPost = self.posts[indexPath.row]
        performSegue(withIdentifier: "postPage", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postPage" {
            let postPage = segue.destination as! PostVC
            postPage.post = self.selectedPost
        }
    }
}

// MARK: - PostCellDelegate

extension FeedViewController: PostCellDelegate {
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
        self.populatePostsTable()
    }
}

// MARK: - StoriesCollectionViewDataSource & Delegate

extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let user = UsersManager.shared.loggedUser else { return 0 }
        return user.following.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Story", for: indexPath) as! StoryViewCell
        guard let loggedUser = UsersManager.shared.loggedUser else { return cell }
        UsersManager.shared.getUserById(loggedUser.following[indexPath.row]) { (user) in
            cell.storyProfilePictureView.image = UIImage(named: "avatar")
            cell.storyProfilePictureView.makeRounded()
            guard let url = URL(string: user.profilePicURL) else { return }
            cell.storyProfilePictureView.loadImage(from: url)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = UsersManager.shared.loggedUser else { return }
        print("should play \(user.following[indexPath.row])'s story")
    }   
}
