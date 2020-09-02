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
    @IBOutlet weak var newsRegionPicker: UIPickerView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var url: String = ""
    private var selectedUserId: String?
    private var data = [UITableViewDataSource & SegmentTitle & UITableViewDelegate]()
    private var selectedRegion = Region.us
    private var searchInput = false
    private var searchedUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsRegionPicker.dataSource = self
        newsRegionPicker.delegate = self
        peopleSearchBar.delegate = self
        newsRegionPicker.selectRow(50, inComponent: 0, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    @IBAction func segmentSwitched(_ sender: UISegmentedControl) {
        discoverViewTable.dataSource = data[sender.selectedSegmentIndex]
        discoverViewTable.delegate = data[sender.selectedSegmentIndex]
        updateView()
    }
    
    private func updateView() {
        if discoverSegmentControl.selectedSegmentIndex == 0 {
            UsersManager.shared.loadLoggedUser() { [weak self] in
                self?.loadDataSources() {}
            }
            newsRegionPicker.isHidden = true
            peopleSearchBar.isHidden = false
        } else if discoverSegmentControl.selectedSegmentIndex == 1 {
            peopleSearchBar.isHidden = true
            newsRegionPicker.isHidden = false
        }
        self.discoverViewTable.reloadData()
    }
    
    private func loadDataSources(completion: @escaping () -> ()) {
        var users: [User]?
        var news: [News]?
        
        let completion = { [weak self] in
            guard let self = self else { return }
            guard let users = users, let news = news else { return }
            guard let loggedUser = UsersManager.shared.loggedUser else { return }
            guard let text = self.peopleSearchBar.text else { return }
            
            let usersDataSource = DataSource<User, PeopleTableViewCell>(
                title: "Users",
                data: self.searchInput ? users.filter() {
                    $0.id != AuthManager.shared.userId
                        && !loggedUser.following.contains( $0.id )
                        && (
                            $0.firstName.lowercased()
                            .contains(text.lowercased())
                            || $0.lastName.lowercased()
                                .contains(text.lowercased()))}
                    : users.filter() {
                        $0.id != AuthManager.shared.userId
                            && !loggedUser.following.contains( $0.id )
                },
                configure: { (cell, item) in
                    cell.delegate = self
                    
                    DispatchQueue.main.async {
                        cell.user = item
                        cell.nameLabel.text = "\(item.firstName) \(item.lastName)"
                        cell.profilePictureView.makeRounded()
                        guard let url = URL(string: item.profilePicURL) else { return }
                        cell.profilePictureView.loadImage(from: url)
                    }
            },
                selectionHandler: { (user) in
                    self.selectedUserId = user.id
                    self.performSegue(withIdentifier: "userProfile", sender: self)
            })
            
            let newsDataSource = DataSource<News, NewsTableViewCell>(
                title: "News",
                data: news,
                configure: { [weak self] (cell, item) in
                    cell.delegate = self
                    guard let dateString = item.publishedAt,
                        let source = item.source.name,
                        let urlString = item.urlToImage,
                        let url = URL(string: urlString) else { return }
                    
                    let date = DateManager.shared.formatDateExtended(from: dateString)
                    cell.newsImageView.loadImage(from: url)
                    cell.setArticle(article: item)
                    cell.titleLabel.text = item.title
                    cell.sourceLabel.text = "\(source) | \(date)"
                    cell.descriptionLabel.text = item.description
                },
                selectionHandler: { (new) in
                    guard let url = URL(string: new.url) else { return }
                    self.showSafariVC(for: url)
            })
            
            self.data = [usersDataSource, newsDataSource]
            
            DispatchQueue.main.async {
                self.discoverViewTable.dataSource = usersDataSource
                self.discoverViewTable.reloadData()
                completion()
            }
        }
        
        UsersManager.shared.getAllUsers {
            users = $0
            completion()
        }
        
        NewsManager.shared.getNews(forRegion: selectedRegion) {
            news = NewsManager.shared.news
            completion()
        }
    }
    
    private func setupSegmentedControl() {
        discoverSegmentControl.isHidden = data.isEmpty
        discoverSegmentControl.removeAllSegments()
    }
    
    // MARK: - SafariVC
    
    private func showSafariVC(for url: URL) {
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

// MARK: - PeopleCellDelegate

extension DiscoverViewController {
    func follow(user: User) {
        UsersManager.shared.follow(user: user) {
            self.updateView()
        }
    }
}

// MARK: - UIPickerViewDataSource

extension DiscoverViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Region.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Region.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        indicator.center = discoverViewTable.center
        indicator.isHidden = false
        discoverViewTable.isHidden = true
        indicator.startAnimating()
        selectedRegion = Region.allCases[row]
        loadDataSources() { [weak self] in
            self?.updateView()
            self?.indicator.stopAnimating()
            self?.indicator.isHidden = true
            self?.discoverViewTable.isHidden = false
        }
    }
}

// MARK: - SearchBarDataSource & SearchBarDelegate

extension DiscoverViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.main.async { [weak self] in
            self?.searchInput = searchText.count != 0
            self?.loadDataSources {
                self?.updateView()
            }
        }
    }
}
