//
//  UIViewController+AlertManager.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 3.09.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(
        title: String,
        message: String,
        sender: UIViewController
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(
            title: "Close",
            style: UIAlertAction.Style.default,
            handler: nil)
        )
        sender.present(alert, animated: true, completion: nil)
    }
}
