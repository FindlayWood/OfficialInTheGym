//
//  DescriptionUploadViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DescriptionUploadViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: ExerciseDescriptionCoordinator?
    
    var display = DescriptionUploadView()
    
    var viewModel = DescriptionUploadViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        initViewModel()
        initTargets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
        display.descriptionTextView.delegate = self
    }

    // MARK: - View Model
    func initViewModel() {
        
        viewModel.$canPost
            .sink { [weak self] in self?.display.uploadButton.isEnabled = $0 }
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .sink { [weak self] in self?.display.setLoading(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.postedPublisher
            .filter { $0 }
            .sink { [weak self] _ in self?.dismiss(animated: true)}
            .store(in: &subscriptions)
    }
    
    // MARK: - Targets
    func initTargets() {
        display.uploadButton.addTarget(self, action: #selector(uploadTapped(_:)), for: .touchUpInside)
        display.cancelButton.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc func uploadTapped(_ sender: UIButton) {
        viewModel.upload()
    }
    @objc func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - TextView Delegate
extension DescriptionUploadViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        if numberOfChars < 300 {
            viewModel.updateText(with: newText)
        }
        return numberOfChars < 300
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = display.placeholder
            textView.textColor = UIColor.lightGray
            display.uploadButton.isEnabled = false
        }
    }
}
