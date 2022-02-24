//
//  ProgramCreationDetailViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ProgramCreationDetailViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: ProgramCreationCoordinator?

    var display = ProgramCreationDetailView()
    
    var viewModel = ProgramCreationDetailViewModel()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initNavBarButton()
        initDisplay()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    
    // MARK: - Nav Bar
    func initNavBarButton() {
        let barButtonItem = UIBarButtonItem(title: viewModel.navBarButtonTitle, style: .done, target: self, action: #selector(uploadPressed(_:)))
        navigationItem.rightBarButtonItem = barButtonItem
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    func initLoadingNavBar() {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.startAnimating()
        let barButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = barButton
    }
    
    // MARK: - Display
    func initDisplay() {
        display.workoutTitleField.delegate = self
        display.descriptionTextView.delegate = self
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.$canUpload
            .sink { [weak self] in self?.navigationItem.rightBarButtonItem?.isEnabled = $0 }
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .sink { [weak self] loading in
                self?.display.setInteraction(to: !loading)
                self?.setToLoading(loading)
            }
            .store(in: &subscriptions)
        
        viewModel.successfullyUploaded
            .sink { [weak self] in self?.successfulUpload($0) }
            .store(in: &subscriptions)
    }

}

// MARK: - Actions
private extension ProgramCreationDetailViewController {
    func setToLoading(_ value: Bool) {
        navigationItem.hidesBackButton = value
        if value {
            initLoadingNavBar()
        } else {
            initNavBarButton()
        }
    }
    
    func successfulUpload(_ value: Bool) {
        if value {
            showTopAlert(with: viewModel.uploadMessage)
            display.clearFields()
        } else {
            showTopAlert(with: viewModel.errorMessage)
        }
    }
    
    @objc func uploadPressed(_ sender: UIBarButtonItem) {
        viewModel.upload()
    }
}

// MARK: - Textfield Delegation
extension ProgramCreationDetailViewController: UITextViewDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string).trimTrailingWhiteSpaces()
        if textField == display.workoutTitleField {
            viewModel.updateTitle(with: newString)
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        let newText = textView.text.trimTrailingWhiteSpaces()
        viewModel.updateDescription(with: newText)
    }
}
