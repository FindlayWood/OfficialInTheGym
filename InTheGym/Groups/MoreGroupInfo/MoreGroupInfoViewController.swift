//
//  MoreGroupInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class MoreGroupInfoViewController: UIViewController {

    var display = MoreGroupInfoView()
    
    var viewModel = MoreGroupInfoViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
   
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initDislay()
        initViewModel()
    }
    
    // MARK: - Init View Model
    func initViewModel() {
        
        viewModel.$isLoading
            .sink { [weak self] in self?.display.setLoading($0)}
            .store(in: &subscriptions)
        
        viewModel.$infoUpdated
            .sink { [weak self] in self?.setSave($0)}
            .store(in: &subscriptions)
        
        viewModel.updatedGroup?
            .sink { [weak self] _ in self?.dismiss(animated: true)}
            .store(in: &subscriptions)
    }
}

// MARK: - Display Setup
extension MoreGroupInfoViewController {
    func initDislay() {
        
        // button targets
        display.cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        display.saveButton.addTarget(self, action: #selector(saveNewInfo), for: .touchUpInside)
        display.groupImageButton.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        display.nameTextField.delegate = self
        display.descriptionTextView.delegate = self
        display.picker.delegate = self
        
        viewModel.monitorTitle(on: display.nameTextField.textPublisher)
        viewModel.monitorDescriptions(on: display.descriptionTextView.textChangedPublisher)
        
        // configure display
        display.configure(with: viewModel.groupModel)
    }
}

private extension MoreGroupInfoViewController {
    func setSave(_ canSave: Bool) {
        if canSave {
            display.saveButton.isEnabled = true
        }
    }
}

// MARK: - Button Targets
extension MoreGroupInfoViewController {
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func presentImagePicker() {
        present(display.picker, animated: true, completion: nil)
    }
    @objc func saveNewInfo() {
//        viewModel.saveNewGroupInfo(from: moreGroupInfo)
        viewModel.save()
    }
}

// MARK: - Textfield delegate
extension MoreGroupInfoViewController {
    func textFieldDidEndEditing(_ textField: UITextField) {
//        display.editNameButton.isEnabled = true
        display.nameTextField.isUserInteractionEnabled = false
//        moreGroupInfo.groupName = textField.text?.trimTrailingWhiteSpaces()
    }
}

// MARK: - TextView Delegate
extension MoreGroupInfoViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
//        display.descriptionTextView.isUserInteractionEnabled = false
//        display.editDescriptionButton.isEnabled = true
//        moreGroupInfo.description = textView.text.trimTrailingWhiteSpaces()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        display.setCharacterCount(numberOfChars)
        return numberOfChars <= 200
    }
}

// MARK: - Image Picker
extension MoreGroupInfoViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {

//            self.moreGroupInfo.headerImage = selectedImage
            self.display.groupImageButton.setImage(selectedImage, for: .normal)
            self.viewModel.newImage = selectedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}
