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
    
    static var identifier = "newsCell"
    
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var onReuse: () -> Void = {}
    var delegate: NewsCellDelegate?
    var article: News!
    
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
    
    func setArticle(article: News) {
        self.article = article
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        delegate?.shareArticle(url: self.article.url)
    }
    
    func configure(item: News) {
        guard let dateString = item.publishedAt,
            let source = item.source.name,
            let urlString = item.urlToImage,
            let url = URL(string: urlString) else { return }

        let date = DateManager.shared.formatDateExtended(from: dateString)
        self.newsImageView.loadImage(from: url)
        self.setArticle(article: item)
        self.titleLabel.text = item.title
        self.sourceLabel.text = "\(source) | \(date)"
        self.descriptionLabel.text = item.description
    }
}
