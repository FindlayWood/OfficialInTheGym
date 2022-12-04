//
//  CreateNewPostViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CreateNewPostViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: CreateNewPostCoordinator?

    var display = CreateNewPostView()
    
    var assignee: Assignable!
    
//    var viewModel = CreateNewPostViewModel()
    
    var viewModel = NewPostViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var childContentView: NewPostView!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .lightColour
//        initDisplay()
        initViewModel()
        initNavBar()
        addChildView()
    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        display.frame = getFullViewableFrame()
//        view.addSubview(display)
//    }
//    override func viewWillAppear(_ animated: Bool) {
////        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
////        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    func initNavBar() {
        let cancelButton = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(cancelTapped))
        let postButton = UIBarButtonItem(customView: display.postButton)
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = postButton
        editNavBarColour(to: .darkColour)
    }
    func initDisplay() {
//        display.cancelButton.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
//        display.postButton.addTarget(self, action: #selector(postTapped(_:)), for: .touchUpInside)
//        display.photoButton.addTarget(self, action: #selector(attachmentTapped(_:)), for: .touchUpInside)
//        display.clipButton.addTarget(self, action: #selector(clipTapped(_:)), for: .touchUpInside)
//        display.postButton.addTarget(self, action: #selector(postTapped(_:)), for: .touchUpInside)
//        display.workoutButton.addTarget(self, action: #selector(workoutTapped(_:)), for: .touchUpInside)
//        display.privacyButton.addTarget(self, action: #selector(togglePrivacy(_:)), for: .touchUpInside)
//        display.messageText.delegate = self
//        if viewModel.postable is GroupPost { display.privacyButton.isHidden = true }
    }
    func addChildView() {
        childContentView = .init(
            viewModel: viewModel,
            isGroup: viewModel.postable is GroupPost,
            post: {
                self.viewModel.postAction()
            }, addAttachments: {
                self.coordinator?.showAttachments(self.viewModel)
            }, changePrivacy: {
                self.coordinator?.showPrivacy(self.viewModel)
            }, cancel: {
                self.cancelTapped()
            })
        addSwiftUIView(childContentView)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.$text
            .map { $0.count > 0 }
            .sink { [weak self] in self?.display.setPostButton(to: $0) }
            .store(in: &subscriptions)
        
        viewModel.$isPrivate
            .sink { [weak self] in self?.display.togglePrivacy(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .sink { [weak self] in self?.display.setLoading(to: $0)}
            .store(in: &subscriptions)
        
//        viewModel.$attachedWorkout
//            .compactMap{ $0 }
//            .sink { [weak self] workoutModel in
//                self?.display.addWorkout(workoutModel)
//                self?.viewModel.updateAttachedWorkout(with: workoutModel)
//            }
//            .store(in: &subscriptions)
//
//        viewModel.succesfullyPostedClosure = { [weak self] in
//            guard let self = self else {return}
//            self.showTopAlert(with: "Successfully posted!")
//            self.display.removeAttachment()
//            self.display.messageText.resignFirstResponder()
//            self.display.messageText.text = ""
//            self.coordinator?.posted()
//        }
//        viewModel.errorPostingClosure = { [weak self] in
//            guard let self = self else {return}
//            self.showTopAlert(with: "Error posting. Try again.")
//        }
    }
}

// MARK: - Actions
extension CreateNewPostViewController {
    @objc func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
//    @objc func postTapped(_ sender: UIButton) {
//        viewModel.postTapped()
//    }
//    @objc func attachmentTapped(_ sender: UIButton) {
//        coordinator?.showImagePicker(completion: { [display] pickedImage in
//            display.addImage(pickedImage)
//        })
//    }
//    @objc func clipTapped(_ sender: UIButton) {
//        coordinator?.showClipPicker()
//    }
//    @objc func workoutTapped(_ sender: UIButton) {
//        coordinator?.showSavedWorkoutPicker(completion: { [display, viewModel] pickedSavedWorkout in
//            display.addSavedWorkout(pickedSavedWorkout)
//            viewModel.updateAttachedSavedWorkout(with: pickedSavedWorkout)
//        })
//    }
//    @objc func togglePrivacy(_ sender: UIButton) {
//        viewModel.isPrivate.toggle()
//    }
}


extension CreateNewPostViewController: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == UIColor.lightGray {
//            textView.text = nil
//            textView.textColor = UIColor.white
//        }
//    }
//    func textViewDidChange(_ textView: UITextView) {
//        if textView.text.trimTrailingWhiteSpaces() == "" {
//            display.postButton.isEnabled = false
//        } else {
//            display.postButton.isEnabled = true
//        }
//    }
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
//        let numberOfChars = newText.count
//        if numberOfChars < 500 {
//            viewModel.updateText(with: newText)
//        }
//        return numberOfChars < 500
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty || textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            textView.text = display.placeholder
//            textView.textColor = UIColor.lightGray
//            display.postButton.isEnabled = false
//        }
//    }
}
