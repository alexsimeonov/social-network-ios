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
    
    override func prepareForReuse() {
        profilePictureView.image = nil
        nameLabel.text = nil
        profilePictureView.cancelImageLoad()
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        guard let user = user else { return }
        self.delegate?.follow(user: user)
    }
}
