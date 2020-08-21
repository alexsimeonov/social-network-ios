//
//  EditProfileViewController.swift
//  socialNetwork
//
//  Created by Alexander Simeonov on 3.08.20.
//  Copyright © 2020 Alexander Simeonov. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import Kingfisher

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var backgroundPictureImageView: UIImageView!
    @IBOutlet weak var profilePicSelectButton: UIButton!
    @IBOutlet weak var backgroundPicSelectButton: UIButton!
    
    var delegate: ProfileViewController?
    var user: User?
    var lastClicked: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUser()
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        if let image = profilePictureImageView.image {
            uploadPhoto(imageView: profilePictureImageView)
            delegate?.profilePictureView.image = image
        }
        
        if let image = backgroundPictureImageView.image {
            uploadPhoto(imageView: backgroundPictureImageView)
            delegate?.backgroundPictureView.image = image
        }
        guard let firstName = firstNameField.text, let lastName = lastNameField.text else { return }
        delegate?.updateProfile(firstName: firstName, lastName: lastName)
        self.delegate?.refreshProfile() {
            AlertManager.shared.presentAlert(title: "Success", message: "Profile updated successfully!", sender: self)
        }
    }
    
    @IBAction func profileImagePickerButtonTapped(_ sender: UIButton) {
        lastClicked = profilePicSelectButton
        showImagePickerController()
    }
    
    @IBAction func backgroundImagePickerButtonTapped(_ sender: UIButton) {
        lastClicked = backgroundPicSelectButton
        showImagePickerController()
    }
    
    func configureUser() {
        user = UsersManager.shared.loggedUser
        guard let user = user else { return }
        firstNameField.text = user.firstName
        lastNameField.text = user.lastName
        profilePictureImageView.makeRounded()
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        
        if lastClicked == profilePicSelectButton {
            profilePictureImageView.image = image
        } else if lastClicked == backgroundPicSelectButton {
            backgroundPictureImageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func uploadPhoto(imageView: UIImageView) {
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
                        AlertManager.shared.presentAlert(title: "Error", message: err.localizedDescription, sender: self)
                        return
                    }
                    
                    UserDefaults.standard.set(documentUid, forKey: "uid")
                    imageView.image = UIImage()
                    
                    switch imageView {
                    case self.profilePictureImageView:
                        UsersManager.shared.updateProfilePicture(pictureURL: urlString)
                    case self.backgroundPictureImageView:
                        UsersManager.shared.updateBackgroundPicture(pictureURL: urlString)
                    default:
                        break
                    }
                }
            }
        }
    }
}
