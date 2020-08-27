//
//  NewsTableViewCell.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 7.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

protocol NewsCellDelegate {
    func shareArticle(url: String)
}

class NewsTableViewCell: UITableViewCell, IdentifiedCell {
        
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    static var identifier = "newsCell"

    var delegate: NewsCellDelegate?
    private var article: News!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        newsImageView.image = nil
        newsImageView.cancelImageLoad()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        delegate?.shareArticle(url: self.article.url)
    }
    
    func setArticle(article: News) {
        self.article = article
    }
}
