//
//  CommentCell.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 19.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

final class CommentCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet private weak var textView: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var createdAtLabel: UILabel!
        
    func configure(content: String, name: String, createdAt: String) {
        nameLabel.text = name
        createdAtLabel.text = createdAt
        textView.text = content
    }
}
