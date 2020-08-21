//
//  PeopleTableViewCell.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 10.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

class PeopleTableViewCell: UITableViewCell, IdentifiedCell {
    
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    static var identifier = "peopleCell"
    var user: User?
    var delegate: DiscoverViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        guard let user = user else { return }
        UsersManager.shared.follow(user: user) {
            self.delegate?.updateView()
        }
    }
    
    func configure(item: User) {
        DispatchQueue.main.async {
            self.user = item
            self.nameLabel.text = "\(item.firstName) \(item.lastName)"
            self.profilePictureView.makeRounded()
            guard let url = URL(string: item.profilePicURL) else { return }
            self.profilePictureView.loadImage(from: url)
        }
    }
}
