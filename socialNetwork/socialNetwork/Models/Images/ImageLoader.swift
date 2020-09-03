//
//  ImageLoader.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 11.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

var imageCache = NSCache<AnyObject, AnyObject>()

final class ImageLoader {
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionTask]()
    
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        
        if let image = loadedImages[url] {
            completion(.success(image))
            return nil
        }
        
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            defer { self?.runningRequests.removeValue(forKey: uuid) }
            
            if let data = data, let image = UIImage(data: data) {
                self?.loadedImages[url] = image
                completion(.success(image))
                return
            }
            
            guard let error = error else { return }
            
            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.failure(error))
                return
            }
        }
        
        task.resume()
        runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}

final class UIImageLoader {
    static let loader = UIImageLoader()
    
    private let imageLoader = ImageLoader()
    private var uuidMap = [UIImageView: UUID]()
    
    private init() { }
    
    func load(from url: URL, for imageView: UIImageView, completion: @escaping () -> ()) {
        
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                imageView.image = imageFromCache
                completion()
                return
            }
        }
            
            let token = imageLoader.loadImage(from: url) { [weak self] (result) in
                defer { self?.uuidMap.removeValue(forKey: imageView) }
                do {
                    let image = try result.get()
                    DispatchQueue.main.async {
                        imageView.image = image
                        completion()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            if let token = token {
                uuidMap[imageView] = token
            }
    }
    
    func cancel(for imageView: UIImageView) {
        if let uuid = uuidMap[imageView] {
            imageLoader.cancelLoad(uuid)
            uuidMap.removeValue(forKey: imageView)
        }
    }
}
