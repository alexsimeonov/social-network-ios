//
//  DiscoverViewController.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 10.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit
import SafariServices

protocol SegmentTitle {
    var title: String { get }
}

protocol IdentifiedCell {
    static var identifier: String { get set }
}

class DiscoverViewController: UIViewController {
    class DataSource<T, Cell: UITableViewCell & IdentifiedCell>:
        NSObject,
        UITableViewDataSource,
        UITableViewDelegate,
    SegmentTitle {
        let title: String
        let data: [T]
        let configure: (Cell, T) -> Void
        let selectionHandler: (T) -> Void
        
        init(
            title: String,
            data: [T],
            configure: @escaping (Cell, T) -> Void,
            selectionHandler: @escaping (T) -> Void
        ) {
            self.title = title
            self.data = data
            self.configure = configure
            self.selectionHandler = selectionHandler
            super.init()
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            data.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as! Cell
            let item = data[indexPath.row]
            configure(cell, item)
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectionHandler(data[indexPath.row])
        }
    }
    
    @IBOutlet weak var discoverViewTable: UITableView!
    @IBOutlet weak var discoverSegmentControl: UISegmentedControl!
    @IBOutlet weak var peopleSearchBar: UISearchBar!
    
    
    var url: String = ""
    var selectedUserId: String?
    var data = [UITableViewDataSource & SegmentTitle & UITableViewDelegate]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    func updateView() {
        if discoverSegmentControl.selectedSegmentIndex == 0 {
            UsersManager.shared.loadLoggedUser() {
                self.loadDataSources()
                self.discoverViewTable.reloadData()
            }
        }
    }
    
    @IBAction func segmentSwitched(_ sender: UISegmentedControl) {
        discoverViewTable.dataSource = data[sender.selectedSegmentIndex]
        discoverViewTable.delegate = data[sender.selectedSegmentIndex]
        discoverViewTable.reloadData()
    }
    
    func loadDataSources() {
        var users: [User]?
        var news: [News]?
        
        let completion = { [weak self] in
            guard let users = users, let news = news else { return }
            guard let loggedUser = UsersManager.shared.loggedUser else { return }
            let usersDataSource = DataSource<User, PeopleTableViewCell>(
                title: "Users",
                data: users.filter() { $0.id != AuthManager.shared.userId && !loggedUser.following.contains( $0.id )},
                configure: { (cell, item) in
                    cell.delegate = self
                    cell.configure(item: item)
            },
                selectionHandler: { user in
                    print(user)
                    self?.selectedUserId = user.id
                    self?.performSegue(withIdentifier: "userProfile", sender: self)
            })
            
            let newsDataSource = DataSource<News, NewsTableViewCell>(
                title: "News",
                data: news,
                configure: { (cell, item) in
                    cell.delegate = self
                    cell.configure(item: item)
            },
                selectionHandler: { new in
                    guard let url = URL(string: new.url) else { return }
                    self?.showSafariVC(for: url)
            })
            
            self?.data = [usersDataSource, newsDataSource]
            
            DispatchQueue.main.async {
                self?.discoverViewTable.dataSource = usersDataSource
                self?.discoverViewTable.reloadData()
            }
        }
        
        UsersManager.shared.getAllUsers {
            users = $0
            completion()
        }
        NewsManager.shared.getNews {
            news = NewsManager.shared.news
            completion()
        }
    }
    
    func setupSegmentedControl() {
        discoverSegmentControl.isHidden = data.isEmpty
        discoverSegmentControl.removeAllSegments()
    }
    
    // MARK: - SafariVC (show browser tab through the app)
    
    func showSafariVC(for url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}

// MARK: - NewsCellDelegate

extension DiscoverViewController: NewsCellDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shareNews" {
            let destVC = segue.destination as! WritePostViewController
            destVC.initialText = self.url
        }
        
        if segue.identifier == "userProfile" {
            if let viewController = segue.destination as? UserProfileVC {
                guard let id = self.selectedUserId else { return }
                viewController.userId = id
            }
        }
    }
    
    func shareArticle(url: String) {
        self.url = url
        performSegue(withIdentifier: "shareNews", sender: self)
    }
}
