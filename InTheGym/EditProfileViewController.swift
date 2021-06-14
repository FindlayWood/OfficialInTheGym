//
//  EditProfileViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//
// edit profile
// edit profile photo & profile bio


import UIKit
import Firebase
import Photos

class EditProfileViewController: UIViewController, Storyboarded, UITextViewDelegate {
    
    @IBOutlet weak var profilePhoto:UIImageView!
    @IBOutlet weak var profileBIO:UITextView!
    
    @IBOutlet weak var saveButton:UIButton!
    
    var theImage:UIImage?
    var theText:String?
    
    var theImageToUpload:UIImage?
    
    var delegate : MyProfileProtocol!
    
    var photoChanged:Bool = false{
        didSet{
            if photoChanged{
                self.saveButton.isUserInteractionEnabled = true
                self.saveButton.setTitleColor(Constants.darkColour, for: .normal)
            }else if !bioChanged{
                self.saveButton.isUserInteractionEnabled = false
                self.saveButton.setTitleColor(.white, for: .normal)
            }
        }
    }
    var bioChanged:Bool = false{
        didSet{
            if bioChanged{
                self.saveButton.isUserInteractionEnabled = true
                self.saveButton.setTitleColor(Constants.darkColour, for: .normal)
            }else if !photoChanged{
                self.saveButton.isUserInteractionEnabled = false
                self.saveButton.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    let userID = Auth.auth().currentUser?.uid
    var DBRef:DatabaseReference!
    var placeholder:String = "profile bio..."

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.saveButton.isUserInteractionEnabled = false
        self.saveButton.setTitleColor(.white, for: .normal)
        
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.bounds.width / 2.0
        
        
        self.profilePhoto.image = theImage
        if theText == placeholder {
            profileBIO.text = placeholder
            profileBIO.textColor = UIColor.lightGray
            
        }
        self.profileBIO.text = theText
        self.profileBIO.delegate = self
        profileBIO.tintColor = Constants.darkColour
        profileBIO.textContainer.maximumNumberOfLines = 8
        profileBIO.textContainer.lineBreakMode = .byTruncatingTail
        
        DBRef = Database.database().reference().child("users").child(userID!)
    
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func dismiss(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeProfilePhoto(_ sender:UIButton){
//        let authorised = PHPhotoLibrary.authorizationStatus()
//        if authorised == .notDetermined {
//            print("no no no")
//        }
//        PHPhotoLibrary.requestAuthorization { status in
//            switch status {
//            case .authorized:
//                print("auth")
//            case .denied:
//                print("denied")
//            default:
//                break
//            }
//        }
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            print("allowed access")
//        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    

    @IBAction func saveProfile(_ sender:UIButton){
        if bioChanged{
            let bioText = profileBIO.text!
            self.DBRef.updateChildValues(["profileBio" : bioText])
            self.DBRef.updateChildValues(["profileBio" : bioText]) { (error, snapshot) in
                if let error = error {
                    //DisplayTopView.displayTopView(with: "Error. Try Again.", on: self)
                    print(error.localizedDescription)
                } else {
                    //DisplayTopView.displayTopView(with: "Updated Profile", on: self)
                    self.bioChanged = false
                    self.delegate.changedBio(to: bioText)
                }
            }

        }
        if photoChanged{
            
            guard let imageData = theImageToUpload!.jpegData(compressionQuality: 0.4) else {
                return
            }
            
            let storageRef = Storage.storage().reference()
            let storageProfileRef = storageRef.child("ProfilePhotos").child(userID!)
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            storageProfileRef.putData(imageData, metadata: metaData) { (storage, error) in
                if let error = error{
                    print(error.localizedDescription as Any)
                    //DisplayTopView.displayTopView(with: "Error. Try Again", on: self)
                    return
                } else {
                    //DisplayTopView.displayTopView(with: "Updated Profile Photo", on: self)
                    ImageAPIService.shared.profileImageCache.removeObject(forKey: self.userID! as NSString)
                    ImageAPIService.shared.profileImageCache.setObject(self.theImageToUpload!, forKey: self.userID! as NSString)
                    self.photoChanged = false
                    self.delegate.changedProfilePhoto(to: self.theImageToUpload!)
                }
                
//                storageProfileRef.downloadURL { (url, error) in
//                    if let metaImageURL = url?.absoluteString{
//                        self.DBRef.updateChildValues(["profilePhotoURL": metaImageURL]) { (error, snapshot) in
//                            if let error = error {
//                                DisplayTopView.displayTopView(with: "Error. Try again.", on: self)
//                                print(error.localizedDescription)
//                            } else {
//                                DisplayTopView.displayTopView(with: "Updated Profile Photo", on: self)
//                                ImageAPIService.shared.profileImageCache.removeObject(forKey: self.userID! as NSString)
//                                ImageAPIService.shared.profileImageCache.setObject(self.theImageToUpload!, forKey: self.userID! as NSString)
//                                self.photoChanged = false
//                                self.delegate.changedProfilePhoto(to: self.theImageToUpload!)
//                            }
//                        }
//                    }
//                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if profileBIO.textColor == UIColor.lightGray {
            profileBIO.text = nil
            profileBIO.textColor = UIColor.white
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if profileBIO.text.isEmpty || profileBIO.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            profileBIO.text = placeholder
            profileBIO.textColor = UIColor.lightGray
            self.bioChanged = false
        }else{
            self.bioChanged = true
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = .white
        
    }
    

}
extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.theImageToUpload = selectedImage
            self.photoChanged = true
            self.profilePhoto.image = selectedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}
