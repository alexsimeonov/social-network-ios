//
//  FriendsTableViewCell.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 4.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

final class ConnectionsTableViewCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var unfollowButton: UIButton!
    
    var delegate: ConnectionsViewController.DataSource?
    var user: User?

    @IBAction func unfollowButtonTapped(_ sender: UIButton) {
        guard let user = user else { return }
        self.delegate?.unfollow(user: user)
    }
    
    func configure(name: String) {
        nameLabel.text = name
    }
}
