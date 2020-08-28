//
//  SettingsLauncher.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 27.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

protocol PostOptionsLauncherDelegate {
    func reloadData()
    func handleMore(postId: String)
}

class PostOptionsLauncher: NSObject {
    static let shared = PostOptionsLauncher()
    
    private override init() {
        super.init()
    }
    
    private let blackView = UIView()
    private let menu = { () -> UIView in
        let settingsMenu = UIView(frame: .zero)
        settingsMenu.backgroundColor = .white
        return settingsMenu
    }()
    var delegate: PostOptionsLauncherDelegate?
    private var postId = ""
    
    func showSettings(view: UIView, postId: String) {
        
        self.postId = postId
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        view.addSubview(blackView)
        view.addSubview(menu)
        
        menu.frame = CGRect(
            x: 0,
            y: view.frame.height,
            width: view.frame.width,
            height: 250
        )
        blackView.frame = view.frame
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.blackView.alpha = 0.5
            self.menu.alpha = 1
            self.menu.frame = CGRect(
                x: 0,
                y: view.frame.height - 250,
                width: self.menu.frame.width,
                height: self.menu.frame.height
            )
            self.configureMenu()
        }
    }
    
    @objc private func handleDismiss() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.blackView.alpha = 0
            self.menu.frame = CGRect(
                x: 0,
                y: self.blackView.frame.height,
                width: self.menu.frame.width,
                height: self.menu.frame.height
            )
            self.menu.alpha = 0
        }
    }
    
    private func configureMenu() {
        let deleteButton = { () -> UIButton in
            let btn = UIButton(frame: CGRect(x: 10, y: 10, width: menu.frame.width - 20, height: (menu.frame.height / 2) -  50))
            btn.setTitle("Delete", for: .normal)
            btn.backgroundColor = .white
            btn.setTitleColor(.systemBlue, for: .normal)
            btn.addTarget(self, action: #selector(delete), for: .touchUpInside)
            btn.setImage(UIImage(systemName: "bin.xmark.fill"), for: .normal)
            return btn
        }()
        
        let cancelButton = { () -> UIButton in
            let btn = UIButton(frame: CGRect(x: deleteButton.frame.minX, y: deleteButton.frame.maxY + 10, width: menu.frame.width - 20, height: (menu.frame.height / 2) -  50))
            btn.setTitle("Cancel", for: .normal)
            btn.backgroundColor = .systemBlue
            btn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
            return btn
        }()
        
        self.menu.addSubview(deleteButton)
        self.menu.addSubview(cancelButton)
    }
    
    @objc func delete() {
        PostsManager.shared.deletePost(withId: self.postId) {
            self.delegate?.reloadData()
            self.handleDismiss()
        }
    }
    
    @objc func cancel() {
        handleDismiss()
    }
}
