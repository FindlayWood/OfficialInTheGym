//
//  MoreGroupInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class MoreGroupInfoViewController: UIViewController {

    var display = MoreGroupInfoView()
    
    var delegate: GroupHomePageProtocol!
    
    var apiService = FirebaseAPIGroupService.shared
    
    lazy var viewModel: MoreGroupInfoViewModel = {
        return MoreGroupInfoViewModel(apiService: apiService)
    }()
    
    var adapter: MoreGroupInfoAdapter!
    
    var moreGroupInfo: MoreGroupInfoModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDislay()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top)
        view.addSubview(display)
    }
    
    func initViewModel() {
        if viewModel.isEditingEnabled(for: moreGroupInfo.leaderID) {
            display.editNameButton.isEnabled = true
            display.editDescriptionButton.isEnabled = true
            display.saveButton.isEnabled = true
            display.editPhotoButton.isEnabled = true
        }
        
        viewModel.membersLoadedCallBack = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                let indexSet = IndexSet.init(integer: 1)
                self.display.tableview.reloadSections(indexSet, with: .none)
            }
        }
        viewModel.leaderLoadedCallBack = { [weak self] in
            guard let self = self else {return}
            self.moreGroupInfo.leader = self.viewModel.leader
            DispatchQueue.main.async {
                let indexSet = IndexSet.init(integer: 0)
                self.display.tableview.reloadSections(indexSet, with: .none)
            }
        }
        viewModel.newInfoSavedCallBack = { [weak self] in
            guard let self = self else {return}
            self.delegate.newInfoSaved(self.moreGroupInfo)
            self.dismiss(animated: true, completion: nil)
        }
        if moreGroupInfo.leader == nil {
            viewModel.loadLeader(from: moreGroupInfo)
        }
        viewModel.loadMembers(from: moreGroupInfo)
    }
    
    
}

// MARK: - Display Setup
extension MoreGroupInfoViewController {
    func initDislay() {
        adapter = .init(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.dataSource = adapter
        display.tableview.backgroundColor = .offWhiteColour
        
        // button targets
        display.cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        display.editPhotoButton.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        display.saveButton.addTarget(self, action: #selector(saveNewInfo), for: .touchUpInside)
       // display.editNameButton.addTarget(self, action: #selector(editName), for: .touchUpInside)
       // display.editDescriptionButton.addTarget(self, action: #selector(editDescription), for: .touchUpInside)
        display.nameTextField.delegate = self
        display.descriptionTextView.delegate = self
        display.picker.delegate = self
        
        // configure display
        display.configure(with: moreGroupInfo)
    }
}

// MARK: - Protocol
extension MoreGroupInfoViewController: MoreGroupInfoProtocol {
    func getData(at indexPath: IndexPath) -> String {
        return viewModel.getData(at: indexPath, from: moreGroupInfo)
    }
    func returnLeader() -> Users? {
        return moreGroupInfo.leader
    }
    func isLeaderLoaded() -> Bool {
        if moreGroupInfo.leader != nil {
            return true
        } else {
            return false
        }
    }
    func membersLoaded() -> Bool {
        return viewModel.membersLoadedSuccessfully
    }
    func getMember(at indexPath: IndexPath) -> Users {
        return viewModel.getMember(at: indexPath)
    }
    func numberOfMembers() -> Int {
        return viewModel.membersCount
    }
}

// MARK: - Button Targets
extension MoreGroupInfoViewController {
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func editName() {
        display.nameTextField.becomeFirstResponder()
    }
    @objc func editDescription() {
        display.descriptionTextView.becomeFirstResponder()
    }
    @objc func presentImagePicker() {
        present(display.picker, animated: true, completion: nil)
    }
    @objc func saveNewInfo() {
        viewModel.saveNewGroupInfo(from: moreGroupInfo)
    }
}

// MARK: - Textfield delegate
extension MoreGroupInfoViewController {
    func textFieldDidEndEditing(_ textField: UITextField) {
        display.editNameButton.isEnabled = true
        display.nameTextField.isUserInteractionEnabled = false
        moreGroupInfo.groupName = textField.text?.trimTrailingWhiteSpaces()
    }
}

// MARK: - TextView Delegate
extension MoreGroupInfoViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        display.descriptionTextView.isUserInteractionEnabled = false
        display.editDescriptionButton.isEnabled = true
        moreGroupInfo.description = textView.text.trimTrailingWhiteSpaces()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 200
    }
}

// MARK: - Image Picker
extension MoreGroupInfoViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {

            self.moreGroupInfo.headerImage = selectedImage
            self.display.groupImageView.image = selectedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}
