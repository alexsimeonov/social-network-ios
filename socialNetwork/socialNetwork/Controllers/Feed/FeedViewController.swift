//
//  FeedViewController.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 3.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController {
    
    @IBOutlet weak var postsView: UITableView!
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    var posts = [Post]()
    var selectedPost: Post?
    
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
    
    @objc func writePost() {
        self.performSegue(withIdentifier: "toWritePost", sender: nil)
    }
    
    // MARK: - Configure
    
    func configureNavigation() {
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
    
    func configurePosts() {
        postsView.dataSource = self
        postsView.delegate = self
    }
    
    func configureStories() {
        storiesCollectionView.dataSource = self
        storiesCollectionView.delegate = self
    }
    
    func populatePostsTable() {
        PostsManager.shared.getFollowingPosts() { (followingPosts) in
            self.posts = followingPosts
        }
        PostsManager.shared.getLoggedUserPosts() { (userPosts) in
            DispatchQueue.main.async {
                self.posts = (self.posts + userPosts)
                    .sorted() { $0.dateCreated > $1.dateCreated }
                self.reloadData()
            }
        }
    }
}

// MARK: - TableViewDataSource -> PostsTableView

extension FeedViewController: UITableViewDataSource, UITableViewDelegate, PostCellDelegate {
    
    func showComments(post: Post) {
        self.selectedPost = post
        performSegue(withIdentifier: "postPage", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        cell.delegate = self
        let post = posts[indexPath.row]
        UsersManager.shared.getUserById(post.userId) { (user) in
            DispatchQueue.main.async {
                cell.nameLabel.text = "\(user.firstName) \(user.lastName)"
                cell.timeStampLabel.text = DateManager.shared.formatDate(post.dateCreated as AnyObject)
                cell.postContentView.text = post.content
                cell.profilePictureView.makeRounded()
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
    
    func reloadData() {
        self.postsView.reloadData()
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
        UsersManager.shared.getUserById(loggedUser.following[indexPath.row]) { user in
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
