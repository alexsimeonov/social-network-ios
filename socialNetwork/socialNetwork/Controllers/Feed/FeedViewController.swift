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
        postsView.prefetchDataSource = self
    }
    
    func configureStories() {
        storiesCollectionView.dataSource = self
        storiesCollectionView.delegate = self
    }
    
    func populatePostsTable() {
        UsersManager.shared.loadLoggedUser() { }
        DispatchQueue.main.async {
            PostsManager.shared.getFollowingPosts() { (followingPosts) in
                PostsManager.shared.getLoggedUserPosts() { (userPosts) in
                    self.posts = (followingPosts + userPosts)
                        .sorted() { $0.dateCreated > $1.dateCreated }
                    self.postsView.reloadData()
                }
            }
        }
    }
}

// MARK: - TableViewPrefetch

extension FeedViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        for indexPath in indexPaths {
//
//        }
    }
}

// MARK: - TableViewDataSource -> PostsTableView

extension FeedViewController: UITableViewDataSource, UITableViewDelegate, PostCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.delegate = self
        DispatchQueue.main.async {
            cell.resetCellDefaultData()
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
            cell.likeButton?.titleLabel?.text = "(\(post.likes.count))"
            cell.updateLike()
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
        cell.configure(index: indexPath.row)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = UsersManager.shared.loggedUser else { return }
        print("should play \(user.following[indexPath.row])'s story")
    }
}
