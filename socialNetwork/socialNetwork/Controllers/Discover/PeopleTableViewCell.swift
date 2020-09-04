//
//  PeopleTableViewCell.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 10.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

final class PeopleTableViewCell: UITableViewCell, IdentifiedCell {
    static var identifier = "peopleCell"

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var profilePictureView: UIImageView!
    
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
        self.delegate?.follow(user: user)
    }
    
    override func prepareForReuse() {
        profilePictureView.image = UIImage(named: "avatar")
        nameLabel.text = nil
        profilePictureView.cancelImageLoad()
    }
}
