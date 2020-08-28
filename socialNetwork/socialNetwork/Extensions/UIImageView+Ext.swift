//
//  UIImageViewExtension.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 20.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL) {
        let indicator = UIActivityIndicatorView()
        DispatchQueue.main.async {
            indicator.center = self.center
            self.addSubview(indicator)
            indicator.startAnimating()
        }
        UIImageLoader.loader.load(from: url, for: self) {
            indicator.stopAnimating()
            indicator.isHidden = true
        } 
    }
    
    func cancelImageLoad() {
        UIImageLoader.loader.cancel(for: self)
    }
    
    func makeRounded() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
