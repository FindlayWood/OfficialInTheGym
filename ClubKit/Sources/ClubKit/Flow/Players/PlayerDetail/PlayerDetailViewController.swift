//
//  PlayerDetailViewController.swift
//  
//
//  Created by Findlay Wood on 10/12/2023.
//

import UIKit

class PlayerDetailViewController: UIViewController {
    
    var coordinator: PlayersFlow?

    var viewModel: PlayerDetailViewModel
    private lazy var display = PlayerDetailView(viewModel: viewModel)
    
    init(viewModel: PlayerDetailViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addDisplay()
        initViewModel()
        initNavBar(to: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Player Detail"
        editNavBarColour(to: .darkColour)
    }
    func addDisplay() {
        addSwiftUIView(display)
    }
    // MARK: - Nav bar
    func initNavBar(to cancel: Bool) {
        if cancel {
            let barButton = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(cancelAction))
            navigationItem.rightBarButtonItem = barButton
        } else {
            let barButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(edit))
            navigationItem.rightBarButtonItem = barButton
        }
    }
    
    // MARK: - Actions
    @objc func edit(_ sender: UIBarButtonItem) {
        viewModel.isEditing = true
        initNavBar(to: true)
    }
    @objc func cancelAction(_ sender: UIBarButtonItem) {
        viewModel.isEditing = false
        initNavBar(to: false)
    }
    func initViewModel() {
        viewModel.linkActionCallback = { [weak self] in
            guard let self else { return }
            self.coordinator?.goToLinkPlayer(for: self.viewModel.playerModel)
        }
    }
}
