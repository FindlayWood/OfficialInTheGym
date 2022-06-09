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
    // MARK: - Coordinator
    weak var coordinator: DescriptionFlow?
    // MARK: - Properties
    var display = DescriptionUploadView()
    var viewModel = DescriptionUploadViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        initDisplay()
        initViewModel()
        initTargets()
    }
    // MARK: - Display
    func initDisplay() {
        display.descriptionTextView.delegate = self
        display.descriptionTextView.text = viewModel.placeholder
        display.setCharacterCount(0)
        display.descriptionTextView.textChangedPublisher
            .sink { [weak self] in self?.viewModel.updateText(with: $0)}
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$canPost
            .sink { [weak self] in self?.display.uploadButton.isEnabled = $0 }
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .sink { [weak self] in self?.display.setLoading(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.listener?
            .sink { [weak self] _ in self?.coordinator?.uploadedNewDescription()}
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
        coordinator?.dismiss()
    }
}
// MARK: - TextView Delegate
extension DescriptionUploadViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondaryLabel {
            textView.text = nil
            textView.textColor = .label
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        display.setCharacterCount(numberOfChars)
        return numberOfChars <= 500
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = viewModel.placeholder
            textView.textColor = .secondaryLabel
            display.uploadButton.isEnabled = false
        }
    }
}
