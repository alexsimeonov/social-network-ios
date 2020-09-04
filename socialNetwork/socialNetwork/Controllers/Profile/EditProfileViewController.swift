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

final class EditProfileViewController: UIViewController {
    
    @IBOutlet private weak var firstNameField: UITextField!
    @IBOutlet private weak var lastNameField: UITextField!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var backgroundPictureImageView: UIImageView!
    @IBOutlet private weak var profilePicSelectButton: UIButton!
    @IBOutlet private weak var backgroundPicSelectButton: UIButton!

    private var lastClicked: UIButton?
    var delegate: ProfileViewController?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUser()
    }
    
    @IBAction private func editButtonTapped(_ sender: UIButton) {
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
            self.showAlert(title: "Success", message: "Profile updated successfully!", sender: self)
        }
    }
    
    @IBAction private func profileImagePickerButtonTapped(_ sender: UIButton) {
        lastClicked = profilePicSelectButton
        showImagePickerController()
    }
    
    @IBAction private func backgroundImagePickerButtonTapped(_ sender: UIButton) {
        lastClicked = backgroundPicSelectButton
        showImagePickerController()
    }
    
    private func configureUser() {
        user = UsersManager.shared.loggedUser
        guard let user = user else { return }
        firstNameField.text = user.firstName
        lastNameField.text = user.lastName
        profilePictureImageView.makeRounded()
    }
}

// MARK: - UIImagePickerDelegate & UINavigationControllerDelegate

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        
        if lastClicked == profilePicSelectButton {
            profilePictureImageView.image = image
        } else if lastClicked == backgroundPicSelectButton {
            backgroundPictureImageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func uploadPhoto(imageView: UIImageView) {
        ImagesManager.shared.uploadPhoto(sender: self, imageView: imageView)
    }
}
