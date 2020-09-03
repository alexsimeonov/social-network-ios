//
//  ImagesManager.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 24.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class ImagesManager {
    static let shared = ImagesManager()
    
    private init() { }
    
    func uploadPhoto(sender: EditProfileViewController, imageView: UIImageView) {
        guard let image = imageView.image, let data = image.jpegData(compressionQuality: 1.0) else { return }
        
        let imageName = UUID().uuidString
        
        let imageRef = Storage.storage().reference().child("ImagesFolder").child(imageName)
        
        imageRef.putData(data, metadata: nil) { (metadata, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            imageRef.downloadURL { (url, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                
                guard let url = url else { return }
                let urlString = url.absoluteString
                
                let dataRef = Firestore.firestore().collection("images").document()
                let documentUid = dataRef.documentID
                
                let data = [
                    "uid": documentUid,
                    "imageURL": urlString
                ]
                
                dataRef.setData(data) { (error) in
                    if let err = error {
                        sender.showAlert(title: "Error", message: err.localizedDescription, sender: sender)
                        return
                    }
                    
                    UserDefaults.standard.set(documentUid, forKey: "uid")
                    imageView.image = UIImage()
                    switch imageView {
                    case sender.profilePictureImageView:
                        UsersManager.shared.updateProfilePicture(pictureURL: urlString)
                    case sender.backgroundPictureImageView:
                        UsersManager.shared.updateBackgroundPicture(pictureURL: urlString)
                    default:
                        break
                    }
                }
            }
        }
    }
}
