//
//  FriendsViewController.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 10.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

class ConnectionsViewController: UIViewController {
    class DataSource: NSObject, UITableViewDataSource {
        let title: String
        var data: [String]
        var delegate: ConnectionsViewController?
        
        init(title: String, data: [String]) {
            self.title = title
            self.data = data
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            data.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "connectionCell", for: indexPath) as! ConnectionsTableViewCell
            
            UsersManager.shared.getUserById(data[indexPath.row]) { (user) in
                cell.delegate = self
                cell.user = user
                cell.unfollowButton.isHidden = self.delegate?.connectionsSegmentedControl.selectedSegmentIndex == 1
                cell.nameLabel.text = "\(user.firstName) \(user.lastName)"
                if user.profilePicURL == "" {
                    cell.profilePictureView.image = UIImage(named: "avatar")
                } else {
                    guard let url = URL(string: user.profilePicURL) else { return }
                    cell.profilePictureView.loadImage(from: url)
                }
                
                cell.profilePictureView.makeRounded()
            }
            
            return cell
        }
        
        func unfollow(user: User) {
            UsersManager.shared.unfollow(user: user) {
                UsersManager.shared.loadLoggedUser() {
                    self.delegate?.updateData()
                }
            }
        }
    }
    
    @IBOutlet weak var connectionsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableViewToDisplay: UITableView!
    var dataSources = [DataSource]()
    var dataCell: ConnectionsTableViewCell?
    var selectedUserId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureData()
        tableViewToDisplay.delegate = self
    }
    
    @objc func handleSegmentChange(_ sender: UISegmentedControl) {
        DispatchQueue.main.async {
            self.tableViewToDisplay.dataSource = self.dataSources[sender.selectedSegmentIndex]
            self.tableViewToDisplay.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.updateData()
        }
    }
    
    func updateData() {
        UsersManager.shared.getUserById(AuthManager.shared.userId) { (user) in
            if self.dataSources.count >= self.connectionsSegmentedControl.numberOfSegments {
                self.dataSources[0].data = user.following
                self.dataSources[1].data = user.followers
                self.tableViewToDisplay.reloadData()
            }
        }
    }
    
    func configureData() {
        guard let user = UsersManager.shared.loggedUser else { return }
        
        connectionsSegmentedControl.isHidden = false
        
        dataSources.append(DataSource(title: "Following", data: user.following))
        dataSources.append(DataSource(title: "Followers", data: user.followers))
        
        dataSources.forEach() { $0.delegate = self }
        
        connectionsSegmentedControl.removeAllSegments()
        dataSources.reversed().forEach {
            connectionsSegmentedControl.insertSegment(withTitle: $0.title, at: 0, animated: false)
        }
        
        connectionsSegmentedControl.selectedSegmentIndex = 0
        handleSegmentChange(connectionsSegmentedControl)
        connectionsSegmentedControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
    }
}
// MARK: - TableViewDelegate

extension ConnectionsViewController: UITableViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userProfile" {
            if let viewController = segue.destination as? UserProfileVC {
                guard let id = self.selectedUserId else { return }
                viewController.userId = id
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        getProperUser(index: indexPath.row)
        performSegue(withIdentifier: "userProfile", sender: nil)
    }
    
    func getProperUser(index: Int) {
        guard let user = UsersManager.shared.loggedUser else { return }
        
        switch connectionsSegmentedControl.selectedSegmentIndex {
        case 0:
            selectedUserId = user.following[index]
        case 1:
            selectedUserId = user.followers[index]
        default:
            break
        }
    }
}
