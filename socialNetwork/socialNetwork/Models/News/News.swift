//
//  New.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 10.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import Foundation

struct News: Decodable {
    var source: Source
    var title: String?
    var description: String?
    var urlToImage: String?
    var publishedAt: String?
    var url: String
}

struct Articles: Decodable {
    let articles: [News]
}

struct Source: Decodable {
    let name: String?
}
