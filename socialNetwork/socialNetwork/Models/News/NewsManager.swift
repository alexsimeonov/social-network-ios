//
//  NewsManager.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 10.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

final class NewsManager {
    static let shared = NewsManager()
    
    private init() { }
    
    private(set) var news = [News]()
    private(set) var image = UIImage()
    
    func getNews(forRegion region: Region, completion: @escaping () -> ()) {
        let urlString = "https://newsapi.org/v2/top-headlines?country=\(region)&apiKey=e3898603c0b84e69887eef5607fe27f5"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, res, err) in
            defer { completion() }
            guard let data = data else {
                guard let err = err else { return }
                print(err.localizedDescription)
                return
            }
            
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(Articles.self,  from: data) {
                self?.news = json.articles
            }
        }
        task.resume()
    }
    
    func loadImage(from urlString: String) -> UIImage{
        let url = URL(string: urlString)
        var image: UIImage?
        if let url = url {
            let task = URLSession.shared.dataTask(with: url) { (data, res, err) in
                guard let imageData = data else { return }
                image = UIImage(data: imageData)
            }
            task.resume()
        }
        guard let img = image else { return UIImage(named: "background")! }
        
        return img
    }
}
