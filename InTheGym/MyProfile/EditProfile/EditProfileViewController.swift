//
//  EditProfileViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class EditProfileViewController: UIViewController {
    
    /// the coordinator for this view
    weak var coordinator: EditProfileCoordinator?
    
    /// the view for this screen
    var display = EditProfileView()
    
    /// the view model
    var viewModel = EditProfileViewModel()
    
    /// hold all combine subscriptions
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func loadView() {
        view = display
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        initViewModel()
        initDisplay()
        display.profileBioTextView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Init Display
    func initDisplay() {
        display.profileImageButton.addTarget(self, action: #selector(selectedNewImage(_:)), for: .touchUpInside)
        display.doneButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        display.setCharacterCount(display.profileBioTextView.text.count)
        display.profileBioTextView.textChangedPublisher
            .sink { [weak self] in self?.viewModel.bioText = $0 }
            .store(in: &subscriptions)
    }
    
    // MARK: - Init View Model
    func initViewModel() {
        
        viewModel.$bioText
            .sink { [weak self] in self?.display.profileBioTextView.text = $0 }
            .store(in: &subscriptions)
        
        viewModel.$profileImage
            .compactMap { $0 }
            .sink { [weak self] in self?.display.profileImageButton.setImage($0, for: .normal)}
            .store(in: &subscriptions)
        
        viewModel.initialLoad()
    }
}
// MARK: - TextView Delegate
extension EditProfileViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        display.setCharacterCount(numberOfChars)
        return numberOfChars <= 200
    }
}
// MARK: - Actions
private extension EditProfileViewController {
    @objc func dismiss(_ sender: UIButton) {
        // make sure to save bio before dismissing
        viewModel.saveBio()
        coordinator?.dismiss()
    }
    @objc func selectedNewImage(_ sender: UIButton) {
        coordinator?.showImagePicker(completion: { [weak self] newImage in
            self?.viewModel.profileImage = newImage
        })
    }
}
