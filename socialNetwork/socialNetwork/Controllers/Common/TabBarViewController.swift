//
//  TabBarViewController.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 4.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
}
