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

final class NewsTableViewCell: UITableViewCell, IdentifiedCell {
    static var identifier = "newsCell"
        
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    
    private var article: News!
    var delegate: NewsCellDelegate?

    override func prepareForReuse() {
        newsImageView.image = nil
        newsImageView.cancelImageLoad()
    }
    
    @IBAction private func shareButtonTapped(_ sender: UIButton) {
        delegate?.shareArticle(url: self.article.url)
    }
    
    func setArticle(article: News) {
        self.article = article
    }
    
    func configure(title: String?, source: String?, description: String?) {
        titleLabel.text = title
        sourceLabel.text = source
        descriptionLabel.text = description
    }
}
