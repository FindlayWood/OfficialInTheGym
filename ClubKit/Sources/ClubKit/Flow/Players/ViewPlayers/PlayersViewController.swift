//
//  PlayersViewController.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import UIKit

class PlayersViewController: UIViewController {
    
    var coordinator: PlayersFlow?
    
    var viewModel: PlayersViewModel
    private lazy var display = PlayersView(viewModel: viewModel)
    
    init(viewModel: PlayersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
        view.backgroundColor = .systemBackground
        addDisplay()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = viewModel.clubModel.clubName + "'s Players"
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Nav bar
    func initNavBar() {
        let barButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .done, target: self, action: #selector(addNewPlayer))
        navigationItem.rightBarButtonItem = barButton
    }
    
    // MARK: - Actions
    @objc func addNewPlayer(_ sender: UIBarButtonItem) {
        coordinator?.addNewPlayer()
    }
    
    // MARK: - Display
    func addDisplay() {
        addSwiftUIViewWithNavBar(display)
    }
}
