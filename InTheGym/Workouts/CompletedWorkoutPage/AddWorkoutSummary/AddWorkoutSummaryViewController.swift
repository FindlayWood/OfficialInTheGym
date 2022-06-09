//
//  AddWorkoutSummaryViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AddWorkoutSummaryViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: CompletedWorkoutCoordinator?
    var display = AddWorkoutSummaryView()
    var viewModel = AddWorkoutSummaryViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
        initViewModel()
    }
    // MARK: - Display
    func initDisplay() {
        display.summaryText.text = viewModel.placeholder
        display.setCharacterCount(0)
        display.summaryText.delegate = self
        display.saveButton.addTarget(self, action: #selector(saveActions(_:)), for: .touchUpInside)
        display.dismissButton.addTarget(self, action: #selector(dismissAction(_:)), for: .touchUpInside)
        display.summaryText.textChangedPublisher
            .sink { [weak self] in self?.viewModel.updateText(with: $0)}
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$canSave
            .sink { [weak self] in self?.display.saveButton.isEnabled = $0 }
            .store(in: &subscriptions)
        viewModel.initSubscriptions()
    }
}
// MARK: - Actions
private extension AddWorkoutSummaryViewController {
    @objc func saveActions(_ sender: UIButton) {
        viewModel.saveAction()
        coordinator?.dismiss()
    }
    @objc func dismissAction(_ sender: UIButton) {
        coordinator?.dismiss()
    }
}
// MARK: - TextView Delegate
extension AddWorkoutSummaryViewController: UITextViewDelegate {
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
        return numberOfChars <= 1000
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = viewModel.placeholder
            textView.textColor = .secondaryLabel
            display.saveButton.isEnabled = false
        }
    }
}
